[TOC]

## 安装前说明

>大部分软件的默认安装路径为 /usr/local/ 目录下，除非服务器挂载其他大容量硬盘，则安装各程序以此目录，避免不必要的麻烦。

## nginx

### 安装依赖

~~~shell
yum -y install gcc zlib zlib-devel pcre-devel openssl openssl-devel
~~~

### 解压tar包

> 解压目录如下：

~~~shell
[root@lejiashopecs nginx]# pwd
/usr/local/nginx
[root@lejiashopecs nginx]# ll
total 784
drwxr-xr-x 6   1001 1001   4096 Jan 15 10:03 auto
drwxr-xr-x 2   1001 1001   4096 Jan 15 10:13 conf
-rwxr-xr-x 1   1001 1001   2502 Apr 17  2018 configure
drwxr-xr-x 4   1001 1001   4096 Jan 15 10:03 contrib
drwx------ 2 nobody root   4096 Jan 15 10:13 fastcgi_temp
drwxr-xr-x 2   1001 1001   4096 Jan 15 10:03 html
-rw-r--r-- 1   1001 1001   1397 Apr 17  2018 LICENSE
drwxr-xr-x 2 root   root   4096 Jan 15 10:13 logs
-rw-r--r-- 1 root   root    376 Jan 15 10:04 Makefile
drwxr-xr-x 2   1001 1001   4096 Jan 15 10:03 man
drwxr-xr-x 3 root   root   4096 Jan 15 10:05 objs
drwxr-xr-x 2 root   root   4096 Jan 15 10:06 sbin
drwxr-xr-x 9   1001 1001   4096 Jan 15 10:03 src
......
~~~

> 在nginx目录下新建logs文件夹 

~~~shell
mkdir logs
~~~

### 安装nginx

~~~shell
进入nginx目录
./configure --with-http_ssl_module		#加参数初始化ssl模块，为了以后配置https
make
make install
~~~

### 隐藏nginx版本号

> 打开nginx目录下conf文件夹，编辑nginx.conf文件，在http标签下加入如下内容

~~~xml
server_tokens  off;
~~~

> 编辑同目录下的fastcgi.conf文件

~~~xml
fastcgi_param SERVER_SOFTWARE nginx/$nginx_version;
改为
fastcgi_param SERVER_SOFTWARE nginx;
~~~

### 启动服务

~~~shell
/usr/local/nginx/sbin/nginx
~~~

### 其他命令

~~~shell
nginx -s reload|reopen|stop|quit  #重新加载配置|重启|停止|退出 nginx
nginx -t   						  #测试配置是否有语法错误
~~~



### nginx配置https

> 准备好两个文件

~~~
******.pem #(证书公钥)
******.key #(证书私钥)
~~~

> 在nginx目录下新建文件夹cert

~~~shell
mkdir cert
~~~

> 配置nginx.conf文件

~~~xml
server {
        listen       443;
        server_name  www.wanzhongsmart.cn;
        ssl on;

        index index.html index.htm;
        ssl_certificate      /usr/local/nginx/cert/******.pem;
        ssl_certificate_key  /usr/local/nginx/cert/******.key;

        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;

        location / {
            root   html;
            index  index.html index.htm;
        }
		#自定义配置
		location /*** {
            ******
        }
        
    }
~~~

