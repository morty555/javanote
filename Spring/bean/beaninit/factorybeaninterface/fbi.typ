以上的第三种方式中，factory-bean是我们自定义的，factory-method也是我们自己定义的。

在Spring中，当你编写的类直接实现FactoryBean接口之后，factory-bean不需要指定了，factory-method也不需要指定了。

factory-bean会自动指向实现FactoryBean接口的类，factory-method会自动指向getObject()方法。

第一步：定义一个Bean

package com.powernode.spring6.bean;

public class Person {
}

第二步：编写一个类实现FactoryBean接口
#image("fbi.png")

第三步：在Spring配置文件中配置FactoryBean
#image("properties.png")

我们实现的factorybean接口是spring提供的，内置了两个抽象方法和判断单例的具体方法（spring中默认是单例）。由于我们编写的这个类实现了接口因此不需要再指定factory-bean和factory-method

FactoryBean在Spring中是一个接口。被称为“工厂Bean”。“工厂Bean”是一种特殊的Bean。所有的“工厂Bean”都是用来协助Spring框架来创建其他Bean对象的。

BeanFactory和FactoryBean的区别：

Spring IoC容器的顶级对象，BeanFactory被翻译为“Bean工厂”，在Spring的IoC容器中，“Bean工厂”负责创建Bean对象。
BeanFactory是工厂。

FactoryBean：它是一个Bean，是一个能够辅助Spring实例化其它Bean对象的一个Bean。

在Spring中，Bean可以分为两类：

● 第一类：普通Bean

● 第二类：工厂Bean（记住：工厂Bean也是一种Bean，只不过这种Bean比较特殊，它可以辅助Spring实例化其它Bean对象。）
