Spring对AOP的实现包括以下3种方式：

● 第一种方式：Spring框架结合AspectJ框架实现的AOP，基于注解方式。

● 第二种方式：Spring框架结合AspectJ框架实现的AOP，基于XML方式。

● 第三种方式：Spring框架自己实现的AOP，基于XML配置方式。

实际开发中，都是Spring+AspectJ来实现AOP。所以我们重点学习第一种和第二种方式。

什么是AspectJ？（Eclipse组织的一个支持AOP的框架。AspectJ框架是独立于Spring框架之外的一个框架，Spring框架用了AspectJ） 

#image("dependency.png")

#image("namespace.png")

15.4.2 基于AspectJ的AOP注解式开发

第一步：定义目标类以及目标方法
#image("targetclass.png")


第二步：定义切面类
#image("cutclass.png")

#image("step34.png")

#image("info.png")

#image("add.png")

注解Before表示前置通知

#image("autoagent.png")

#image("test.png")

#image("infotype.png")

#image("show.png")

#image("order.png")

#image("faultprocess.png")

我们知道，业务流程当中不一定只有一个切面，可能有的切面控制事务，有的记录日志，有的进行安全控制，如果多个切面的话，顺序如何控制：可以使用Order注解来标识切面类，为Order注解的value指定一个整数型的数字，数字越小，优先级越高。

#image("result.png")

第一张图youraspect为order1 myaspect为order2

以上代码切点表达式重复写了多次，没有得到复用。可以这样做：将切点表达式单独的定义出来，在需要的位置引入即可。
#image("improver.png")
注意这个Pointcut注解标注的方法随意，只是起到一个能够让Pointcut注解编写的位置

#image("anotationaop.png")

#image("xmlaop.png")

#image("xmlproperties.png")

#image("testxml.png")