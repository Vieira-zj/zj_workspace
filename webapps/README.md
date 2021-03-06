# Web Demo

- Front:

```
nginx 8081
```

- Backend:

```
mockserver docker instance => 17891
tomcatserver1 docker instance => 8082
tomcatserver2 docker instance => 8083
```

## host config

```
/etc/hosts: 127.0.0.1 helloworld.zj.com mockserver.zj.com vueserver.zj.com
```

URI

```
# simple static reverse proxy, helloworld
http://t1.helloworld.zj.com:8081
http://t2.helloworld.zj.com:8081
http://helloworld.zj.com:8081/public/helloworld.html
http://helloworld.zj.com:8081/static/pics/1.jpg
```

```
# simple reverse proxy, mockserver
http://mockserver.zj.com:8081/images/1.jpg // static
http://mockserver.zj.com:8081/access // mockserver
http://mockserver.zj.com:8081/post/cdnrefresh
http://mockserver.zj.com:8081/index?isFile=false&wait=1
```

```
# vueserver on tomcat
http://vueserver.zj.com:8081
http://vueserver.zj.com:8081/vue.html // static vue
http://vueserver.zj.com:8081/vueapp/vue.html // vue on tomcat
```

