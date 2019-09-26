[TOC]

### 前言

> 1. redis3.0版本之前只支持单例模式，在3.0版本及以后才支持集群，我这里用的是redis4.0.10版本
> 2. redis集群采用P2P模式，是完全去中心化的，不存在中心节点或者代理节点
> 3. redis集群是没有统一的入口的，客户端（client）连接集群的时候连接集群中的任意节点（node）即可，集群内部的节点是相互通信的（PING-PONG机制），每个节点都是一个redis实例
> 4. 为了实现集群的高可用，即判断节点是否健康（能否正常使用），redis-cluster有这么一个投票容错机制：如果集群中超过半数的节点投票认为某个节点挂了，那么这个节点就挂了（fail）。这是判断节点是否挂了的方法
> 5. 那么如何判断集群是否挂了呢? -> 如果集群中任意一个节点挂了，而且该节点没有从节点（备份节点），那么这个集群就挂了。这是判断集群是否挂了的方法
> 6. 那么为什么任意一个节点挂了（没有从节点）这个集群就挂了呢？
>    因为集群内置了16384个slot（哈希槽），并且把所有的物理节点映射到了这16384[0-16383]个slot上，或者说把这些slot均等的分配给了各个节点。当需要在Redis集群存放一个数据（key-value）时，redis会先对这个key进行crc16算法，然后得到一个结果。再把这个结果对16384进行求余，这个余数会对应[0-16383]其中一个槽，进而决定key-value存储到哪个节点中。所以一旦某个节点挂了，该节点对应的slot就无法使用，那么就会导致集群无法正常工作
> 7. 综上所述，每个Redis集群理论上最多可以有16384个节点
> 8. Redis集群至少需要3个节点，因为投票容错机制要求超过半数节点认为某个节点挂了该节点才是挂了，所以2个节点无法构成集群
> 9. 要保证集群的高可用，需要每个节点都有从节点，也就是备份节点，所以Redis集群至少需要6台服务器。因为我没有那么多服务器，也启动不了那么多虚拟机，所在这里搭建的是伪分布式集群，即一台服务器虚拟运行6个redis实例，修改端口号为（7001-7006），当然实际生产环境的Redis集群搭建和这里是一样的

---

### 安装前的准备

> 1. 安装好一个redis实例（此过程不再赘述）
> 2. redis5版本前，搭建一个集群是通过ruby脚本文件，所以这个工具的运行需要ruby的运行环境，就相当于java语言的运行需要在jvm上。所以需要安装ruby

---

### 安装ruby

~~~shell
# 安装 ruby，centos 默认的版本是 2.0.0，版本太低，需要升级版本
# 具体升级到多少版本，执行 gem install redis 指令看提示信息
yum install ruby rubygems -y

# 采用 rvm 来更新 ruby
# 安装 curl
yum -y install curl

# 安装 rvm
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

curl -L get.rvm.io | bash -s stable

# 修改 rvm下载 ruby 的源，到 Ruby China 的镜像
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/

# 更新下配置
source  /etc/profile.d/rvm.sh

# 查看 rvm 库中已知的 ruby 版本
rvm list known

# 安装一个 ruby 版本(版本号看上一条指令)
rvm install 2.3

# 查看 ruby 的版本
ruby --version

# 安装 gem redis模块(执行 redis-trib.rb 命令需要的环境)
gem install redis
~~~

---

### 正式搭建 redis 集群

> 进入 /usr/local 目录，创建文件夹 rediscluster

~~~shell
cd /usr/local

mkdir rediscluster
~~~

> 进入 rediscluster 目录，创建六个节点的目录

~~~shell
cd rediscluster

mkdir redis01 redis02 redis03 redis04 redis05 redis06
~~~

> 将之前安装好的 redis 实例下的 配置文件复制到六个节点目录下(我的 redis 实例在 /usr/local/redis 目录下)

~~~shell
# 任意位置都可执行以下命令，因为使用的是绝对路径
cp /usr/local/redis/redis.conf /usr/local/rediscluster/redis01
cp /usr/local/redis/redis.conf /usr/local/rediscluster/redis02
cp /usr/local/redis/redis.conf /usr/local/rediscluster/redis03
cp /usr/local/redis/redis.conf /usr/local/rediscluster/redis04
cp /usr/local/redis/redis.conf /usr/local/rediscluster/redis05
cp /usr/local/redis/redis.conf /usr/local/rediscluster/redis06
~~~

> 修改各节点的配置文件

~~~shell
# 端口号
port [port]

# 将 cluster-enabled yes 的注释打开
cluster-enabled yes

# 修改 redis 进程文件名
pidfile /var/run/redis_[port].pid

# 修改 rdb 文件名
dbfilename dump-[port].rdb

# 各节点的数据( node_dir 为各节点的目录名)
dir /usr/local/rediscluster/[node_dir]/
~~~

> 启动 redis 节点

~~~shell
# 在 rediscluster 目录下执行以下命令
/usr/local/redis/bin/redis-server redis01/redis.conf
/usr/local/redis/bin/redis-server redis02/redis.conf
/usr/local/redis/bin/redis-server redis03/redis.conf
/usr/local/redis/bin/redis-server redis04/redis.conf
/usr/local/redis/bin/redis-server redis05/redis.conf
/usr/local/redis/bin/redis-server redis06/redis.conf
~~~

> 查看各节点是否正常启动

~~~shell
ps -ef|grep redis

#root 14079 1  0 11:43 ? 00:00:12 /usr/local/redis/bin/redis-server *:7001 [cluster]
#root 14505 1  0 11:44 ? 00:00:13 /usr/local/redis/bin/redis-server *:7002 [cluster]
#root 14984 1  0 11:44 ? 00:00:12 /usr/local/redis/bin/redis-server *:7003 [cluster]
#root 15071 1  0 11:44 ? 00:00:14 /usr/local/redis/bin/redis-server *:7004 [cluster]
#root 15130 1  0 11:44 ? 00:00:14 /usr/local/redis/bin/redis-server *:7005 [cluster]
#root 15189 1  0 11:44 ? 00:00:14 /usr/local/redis/bin/redis-server *:7006 [cluster]
~~~

> 进入 redis 实例的 src 目录，将脚本 redis-trib.rb 复制到 rediscluster 目录下

~~~shell
cp redis-trib.rb /usr/local/rediscluster/
~~~

> 进入 /usr/local/rediscluster 目录下，执行以下命令

~~~shell
./redis-trib.rb create --replicas 1 192.168.181.128:7001 192.168.181.128:7002 192.168.181.128:7003 192.168.181.128:7004 192.168.181.128:7005 192.168.181.128:7006

# 如出现以下类似日志，说明集群搭建成功
#M: 21dbb4034832a4d44c34a062f04cdb28da5b41d2 192.168.181.128:7001
#   slots:0-5460 (5461 slots) master
#   1 additional replica(s)
#M: 0bf5700eca8b803f41fc7abafe3b6a0303e1daad 192.168.181.128:7003
#   slots:10923-16383 (5461 slots) master
#   1 additional replica(s)
#S: accc2dc7f66ec1be045fb1ece48ef56543151536 192.168.181.128:7006
#   slots: (0 slots) slave
#   replicates 0bf5700eca8b803f41fc7abafe3b6a0303e1daad
#S: be65a23484ba67146508aa99457d2906480223a0 192.168.181.128:7004
#   slots: (0 slots) slave
#   replicates 21dbb4034832a4d44c34a062f04cdb28da5b41d2
#S: 669add2ac4ff65064850c2023ce0cb672dbb33d6 192.168.181.128:7005
#   slots: (0 slots) slave
#   replicates 280bc49c84afd2fa0badd6a2641bcf2518a06916
#M: 280bc49c84afd2fa0badd6a2641bcf2518a06916 192.168.181.128:7002
#   slots:5461-10922 (5462 slots) master
#   1 additional replica(s)
~~~

### 访问 redis 集群，任意节点

~~~shell
# 如果设置了密码，需要加上 -a *** 的参数连接，不然每一次跳到其他节点操作 redis 都需要重新输入密码
/usr/local/redis/bin/redis-cli -c -h 127.0.0.1 -p 7001 -a redis
~~~

### 可能出现的错误

> 执行 redis-trib.rb 脚本时，可能出现这个错误：Sorry, can't connect to node

~~~shell
# 解决方案
# 修改以下文件
/usr/local/rvm/gems/ruby-2.4.1/gems/redis-4.0.1/lib/redis/client.rb
# 大家可能路径不一样，查一下
find / -name client.rb

# 如果设置了 redis 密码，将以下 password 修改成 redis 密码
# 如果没有设置密码，password 置为 nil 或者注释这一行
DEFAULTS = {
      :url => lambda { ENV["REDIS_URL"] },
      :scheme => "redis",
      :host => "127.0.0.1",
      :port => 6379,
      :path => nil,
      :timeout => 5.0,
      :password => "xxxxxx",
      :db => 0,
      :driver => nil,
      :id => nil,
      :tcp_keepalive => 0,
      :reconnect_attempts => 1,
      :inherit_socket => false
    }
~~~



