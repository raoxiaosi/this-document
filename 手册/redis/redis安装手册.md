[TOC]

### redis 安装前准备

> 1. 准备安装包 redis-xxx.tar.gz
> 2. 确认系统已经安装 c 的环境（因为 redis 是 c 写的，需要编译）

---

### 安装 c 环境

~~~shell
yum install -y gcc-c++
~~~

---

### 安装 redis

> 解压 redis 安装包到 /usr/local 目录下

~~~shell
tar -zxvf redis-xxx.tar.gz -C /usr/local
~~~

> 进入 /usr/local 目录 重命名 redis 目录 （新的名字以 redis_端口）

~~~shell
mv redis-xxx redis-6379
~~~

> 进入redis目录，安装redis（设置 PREFIX 目录，生成的 redis 相关脚本存放在 PREFIX/bin 目录下）

~~~shell
# 编译
make

# 安装
make PREFIX=/usr/local/redis-6379/ install
~~~

### redis 常规配置

~~~shell
# 只允许本地客户端连接，一般注释
#bind 127.0.0.1

# redis 的启动端口，默认是 6379，可自行设置
port 6379

# 设置后台启动
daemonize yes

# 这是 redis 访问密码
requirepass yourpassword
~~~

### redis 启动停止相关

~~~shell
# 启用 redis 服务
redis-server redis.conf

# 连接 redis 服务
redis-cli -c -h [host] -p [port] -a [password]

# 关闭 redis 服务
# 生产环境中切勿使用进程号关闭 redis,这样redis不会进行持久化操作
# 除此之外，还会造成缓冲区等资源不能优雅关闭，极端情况下会造成AOF和复制丢失数据的情况
redis-cli -h [host] -p [port] -a [password] shutdown
~~~

