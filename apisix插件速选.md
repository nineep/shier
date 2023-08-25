# apisix插件速选

[HTTP | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP)

https://apisix.apache.org/zh/docs/apisix/plugins/redirect/

## 数据转换类

响应重写

- response-rewrite：修改上游服务或apisix 返回的 body和header

代理重写【请求重写】

- proxy-rewrite：修改请求上游时的 uri、method、header等

body转换

- body-transformer：请求或响应的 body格式转换，例如JSON转XML

协议转换 

- grpc-transcode：HTTP和gRPC请求之间进行转换

- degraphql：解码RESTful API为 GraphQL

测试【自定义响应】

- fault-injection：故障注入，直接返回指定的相应码且终止其他插件，或者延迟某个请求且执行配置的插件

- mocking：随机返回指定格式的模拟数据， 且请求不会转发到upstream

## 通用类

重定向

- redirect： URI重定向

真实ip

- real-ip： 动态改变传递到 apisix的客户端的IP地址和端口，与ngx_http_realip_module一样

压缩

- gzip： 动态设置NGINX的压缩行为

external插件钩子 

- ext-plugin-pre-req

- ext-plugin-post-req

- ext-plugin-post-resp

流量控制：

- workflow：uri路径级别的流量控制

## 认证类

基础访问认证

- basic-auth:  将基础认证添加到 route或者service中

OIDC三方认证

- openid-connect：对接支持OIDC协议的 身份认证服务

## 安全风控类

跨域资源共享

- cors：服务端启用CORS的响应headers

CSRF攻击【较少用到】

- csrf ： 保护API免于CSRF攻击

请求拦截和限制

- uri-blocker：匹配uri，来限制用户请求

- ip-restriction：访问ip的黑白名单

- ua-restriction：User-Agent的黑白名单

- referer-restriction：referer的黑白名单

- consumer-resriction：consumer的黑白名单

## 限流类

请求流量限制

- limit-req：限制单个客户端的请求速率

- limit-conn：限制客户端对单个服务的并发请求数

- limit-count：限制单个客户端在指定的时间范围内对服务的总请求数

api熔断过载保护

- api-breaker： API熔断，保护上游业务服务

分流 

- 路由分流：支持通过请求头，请求参数、Cookie 进行路由匹配，可应用于灰度发布，蓝绿测试等场景

- 上游负载均衡分流：支持ip:port + weight

- 服务内分流：支持更丰富的匹配规则，来分流
  
  - traffic-split：更灵活的匹配规则

请求验证【较少使用】

- request-validation：提前验证向上游服务转发的请求，验证body、header的数据

- request-id：给请求添加unique ID，用于追中API请求【也可在请求重写中实现】

代理侧设置

- proxy-cache：缓存后端响应的数据，支持基于磁盘和内存

- proxy-mirror：镜像客户端请求，将线上的真实流量拷贝到镜像服务中，在不影响线上服务的情况下，对线上流量或请求内容 进行具体分析

- proxy-control：动态的控制NGINX代理的行为

## 可观测类

tracer、metrics、loggers对接了主流的开源项目，可以将 经过 apisix的请求响应流量的 事件、监控、日志 推送到三方

另外，对于可观测的增强可以使用： request-id添加trace id

## serverless 类

serverless 这块大致是一个 钩子函数的，支持自定义，同时也支持像aws-lambda这样的函数服务。 在["rewrite", "access", "header_filter", "body_filter", "log", "before_proxy"] 六个阶段前后执行函数

这个插件基本上能实现以上全部插件能实现功能了

- serverless：
  
  - serverless-pre-function
  
  - serverless-post-function
