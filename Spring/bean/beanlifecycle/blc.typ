8.1 什么是Bean的生命周期

● Spring其实就是一个管理Bean对象的工厂。它负责对象的创建，对象的销毁等。

● 所谓的生命周期就是：对象从创建开始到最终销毁的整个过程。

● 什么时候创建Bean对象？

● 创建Bean对象的前后会调用什么方法？

● Bean对象什么时候销毁？

● Bean对象的销毁前后调用什么方法？

8.2 为什么要知道Bean的生命周期

● 其实生命周期的本质是：在哪个时间节点上调用了哪个类的哪个方法。

● 我们需要充分的了解在这个生命线上，都有哪些特殊的时间节点。

● 只有我们知道了特殊的时间节点都在哪，到时我们才可以确定代码写到哪。

● 我们可能需要在某个特殊的时间点上执行一段特定的代码，这段代码就可以放到这个节点上。当生命线走到这里的时候，自然会被调用。

ean生命周期可以粗略的划分为五大步：

● 第一步：实例化Bean

● 第二步：Bean属性赋值

● 第三步：初始化Bean

● 第四步：使用Bean

● 第五步：销毁Bean

#image("user.png")

#image("properties.png")

#image("test.png")

需要注意的：

● 第一：只有正常关闭spring容器，bean的销毁方法才会被调用。

● 第二：ClassPathXmlApplicationContext类才有close()方法。

● 第三：配置文件中的init-method指定初始化方法。destroy-method指定销毁方法。

在以上的5步中，第3步是初始化Bean，如果你还想在初始化前和初始化后添加代码，可以加入“Bean后处理器”。

编写一个类实现BeanPostProcessor类，并且重写before和after方法：

#image("bfinit.png")

#image("propertiesafter.png")

如果根据源码跟踪，可以划分更细粒度的步骤，10步：

#image("beanten.png")

上图中检查Bean是否实现了Aware的相关接口是什么意思？

Aware相关的接口包括：BeanNameAware、BeanClassLoaderAware、BeanFactoryAware

● 当Bean实现了BeanNameAware，Spring会将Bean的名字传递给Bean。

● 当Bean实现了BeanClassLoaderAware，Spring会将加载该Bean的类加载器传递给Bean。

● 当Bean实现了BeanFactoryAware，Spring会将Bean工厂对象传递给Bean。
测试以上10步，可以让User类实现5个接口，并实现所有方法：

● BeanNameAware

● BeanClassLoaderAware

● BeanFactoryAware

● InitializingBean

● DisposableBean

具体就是检查spring有没有实现某些接口

Spring 根据Bean的作用域来选择管理方式。

● 对于singleton作用域的Bean，Spring 能够精确地知道该Bean何时被创建，何时初始化完成，以及何时被销毁；

● 而对于 prototype 作用域的 Bean，Spring 只负责创建，当容器创建了 Bean 的实例后，Bean 的实例就交给客户端代码管理，Spring 容器将不再跟踪其生命周期。

我们把之前User类的spring.xml文件中的配置scope设置为prototype：

#image("changeprototype.png")

有些时候可能会遇到这样的需求，某个java对象是我们自己new的，然后我们希望这个对象被Spring容器管理，怎么实现？

#image("newbymyself.png")
