> 官方拉取镜像

    docker pull postgres

> 在本地建立一个数据存放目录

    /home/rudy/pro/postgresql/data

> docker中数据目录是

    /var/lib/postgresql/data

>下面是启动命令

    
   docker run  --name rails-pg -e POSTGRES_PASSWORD=123456 -e PGDATA=/var/lib/postgresql/data/pgdata  -v /home/rudy/pro/docker/databases/postgresql/data:/var/lib/postgresql/data -p 5432:5432 -dit postgres:latest



> 查看错误日志使用

    docker logs rails-pg

> 进入容器

    docker exec -it rails-pg bash
    su - postgres

    psql
    \du



> 然后打开新终端登录创建用户，devpg是用户名，密码也是devpg， 不是超级管理员，拥有创建数据库权限，登录权限，继承拥有角色权限

    create user devpg with NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN  PASSWORD 'devpg' ;

>查看

    \du

>然后再创建一个数据库，指定拥有者是devpg


    create  database exampledb OWNER devpg;

>这时可以使用devpg来登录exampledb
