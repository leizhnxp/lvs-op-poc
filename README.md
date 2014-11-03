## 虚拟机搞下LVS派对

### 假设

* 看官都知道vagrant是怎么回事，了解，会基本使用
* 能用google搜索LVS个大概其，知道存在DR、NAT、TUN，大致是咋回事

### POC要点

* 要做TCP和UDP端点的负载均衡
	* 7层LB路人皆曰nginx
* 表达基础设施层面的最简配置要求
* 负载均衡基础上的高可用
	* 这才是问题域最终目标
	* 最终目标会归结为LVS LB调度器的高可用问题
	* 这个还没搞，就是keepalived，和LVS貌似属于一个族群的技术，之前已经有同事搞过了，这里不做重点

### 过程记录简要

* 本来直观首选NAT，官网主要的[文档库](http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-NAT.html)里也算含蓄的误导

> This method was used for the first LVS. If you want to set up a test LVS, this requires no modification of the realservers and is still probably the simplest setup.

* 那个[连接](http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-NAT.html)后面基本上就在讲各种坑

* 选NAT主要是因为直觉上觉得对realserver无需任何改动，但综合配置简约和性能各方面最常用的，**据说**，是DR

* NAT搏斗过程——此处省略10000字，精疲力尽，提供的DR的示例

### 环境结构概述

* 其实看Vagrant配置文件基本上明了，除了，下一条，后面都可以当成...废话
* Vagrantfile中配置的box的名字可以用configure_box里的方法获得并准备好
* 一共4台
	* 负载均衡器一台，通常都叫director，ds
	* 功能服务器两台，通常叫realserver，rs，我这里叫actor和actress
	* 服务消费方一台，一般叫client，我这里就叫cs和fans了
* 所有的机器为了调试时候方便，tcpdump traceroute nmap等一堆工具都装上了，可以看vagrant的provision脚本
* 两个rs上分别用ncat写了一个简单地tcp server，有客户端连上就自报家门，基本上可以当成一个短连接的实现
* cs上直接用nc 10.0.0.10 8964 就行了，会打印具体rs返回的信息，10.0.0.10就是传说中的VIP，这个ip和端口8964可以看几个provision脚本中怎么配置的

### 后续

* 一个长连接的service演示，其实蛮简单地：ncat -lk 8964 -c "xargs -n1 echo "，反而是现在那个短连接其实我现在不太理解是为什么，同样是echo，xargs之后就不会断了连接，还没深究
* provision是不是每次reload或者up就執行，這個我还不确定，找机会得试下，这会影响PoC里的Mock Service的启动，这问题纯为完美
* 加keepalived，防止LVS单点

### 

* 不理会ARP问题，会失败的很落魄...一开始以为是软毛病，因为头两次都是女演员有时候不听宣，这个很奇怪，前两次出现时候，重新用ipvsadm配置一次就好了，第三次再出现...然后就感觉再没好过
	* [这里](http://www.linuxvirtualserver.org/docs/arp.html)写的很详细
	* 我采用的是它称谓的很cute的方法

### 番外

* 首先是事情的目标在最后一刻发生了变化
	* 不是真的发生了变化，而是一开始就跑偏，不过好在最后形成了这堆配置
	* 最重要的其实还是HA，LB是另一个副产品——有个备机，不如生产时候也用一下
	* 针对LB，据敝人直接沟通，OP那边实际关心的**只是**负载调度策略，这个和业务系统多少有点关系，主要是根据业务特点，控制一下压力，我觉得这种玩意儿就是轮转，其他除非真的有规模，否则很有可能事与愿违
	* 针对HA，这才是最重要的，直接上ldirectord，对rs检活，否则keepalived完事了，不用LB这个副产品
* 这个过程中发现有人也像我一样把[这个过程](https://github.com/shkh/lvs-vagrant)置在github上，我参考了，甚至一度想在它[上面改](https://github.com/leizhnxp/lvs-vagrant)，但是它那个貌似不好用，而且脚本中每个步骤不甚明了，特别是特么的NAT的还改了路由表，这玩意儿那还能有意义吗？而且vagrant里它没有client，对VIP问题表达的不直接，所以放弃使用他的了
* box的问题
	* 一开始怎么整都不行的时候，难免以为自己制作的box有问题，毕竟心虚啊
	* 后来用vagrant es上提供的box成功后换成自己的box发现应该没关系
	* vagrant cloud资源非常丰富，1.6.X之后比es好用，只是虽然没直接被墙，但是真够慢的
