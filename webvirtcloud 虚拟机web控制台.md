## 虚拟机web控制台

### 项目地址：https://github.com/retspen/webvirtcloud/blob/master/README.md



### 修改配置文件

<img width="650" alt="image" src="https://github.com/nineep/shier/assets/20335786/4a565933-5a3e-4bb9-982f-7674d427d71d">



### docker 部署

docker run -d --name webvirtcloud -p 80:80 -p 6080:6080 nineep/webvirtcloud-docker:v1.0



### web

[http://virtcloud.ksord.com:8090/](http://virtcloud.ksord.com:8090/)

admin

ruBsj5DBm2ryj24



### ssh连接宿主

在 /var/www/.ssh生成密钥对，修改权限

chown -R www-data:www-data /var/www/

将公钥copy到 宿主



### 参考

[快速搭建 kvm web 管理工具 WebVirtMgr – SRE运维博客](https://www.cnsre.cn/posts/211117937177/)

[Debian 10 安装 webvirtcloud管理KVM并安装windows server 2019虚拟机，映射远程桌面，服务器篇_weixin_46668484的博客-CSDN博客](https://blog.csdn.net/weixin_46668484/article/details/130610842)

[WebVirtCloud--KVM管理工具的部署及使用详细文档 | Nes的草稿箱](https://nestealin.com/25f60e5a/#toc-heading-8)

[基于KVM、VNC和webvirtcloud的自建虚拟平台](https://baijiahao.baidu.com/s?id=1641370894958619458)
