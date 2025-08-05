#image("@component.png")
#image("@controller.png")
#image("@repo.png")
#image("@service.png")
也就是说：这四个注解的功能都一样。用哪个都可以。

只是为了增强程序的可读性，建议：

● 控制器类上使用：Controller

● service类上使用：Service

● dao类上使用：Repository

他们都是只有一个value属性。value属性用来指定bean的id，也就是bean的名字。
#image("use.png")
#image("use2.png")

如果注解的属性名是value，那么value是可以省略的。

如果把value属性彻底去掉，spring会被Bean自动取名吗？会的。并且默认名字的规律是：Bean类名首字母小写即可。

#image("nameset.png")

如果是多个包怎么办？有两种解决方案：

● 第一种：在配置文件中指定多个包，用逗号隔开。
#image("twopackage.png")

● 第二种：指定多个包的共同父包。
#image("tp.png")

假设在某个包下有很多Bean，有的Bean上标注了Component，有的标注了Controller，有的标注了Service，有的标注了Repository，现在由于某种特殊业务的需要，只允许其中所有的Controller参与Bean管理，其他的都不实例化。这应该怎么办呢？

我只想实例化bean3包下的Controller。配置文件这样写：

#image("singlebean.png")
也可以将use-default-filters设置为true（不写就是true），并且采用exclude-filter方式排出哪些注解标注的Bean不参与实例化：

#image("singglebean2.png")

接下来我们看一下，如何给Bean的属性赋值。给Bean属性赋值需要用到这些注解：

#image("@value.png")
#image("testvalue.png")

#image("@valueonsetter.png")

如果提供setter方法，并且在setter方法上添加Value注解，可以完成注入

通过测试得知：Value注解可以出现在属性上、setter方法上、以及构造方法的形参上。

#image("autowirecode.png")

源码中有两处需要注意
：
● 第一处：该注解可以标注在哪里？

○ 构造方法上

○ 方法上

○ 形参上

○ 属性上

○ 注解上
● 第二处：该注解有一个required属性，默认值是true，表示在注入的时候要求被注入的Bean必须是存在的，如果不存在则报错。如果required属性设置为false，表示注入的Bean存在或者不存在都没关系，存在的话就注入，不存在的话，也不报错。

autowired可以标注在属性，setter方法，构造方法，构造方法的形参上，若构造方法的形参只有一个，则可以省略autowired

Autowired注解默认是byType进行注入的，也就是说根据类型注入的，如果以上程序中，UserDao接口还有另外一个实现类，会出现问题吗？

#image("wrong.png")

错误信息中说：不能装配，UserDao这个Bean的数量大于1.

怎么解决这个问题呢？当然要byName，根据名称进行装配了。

Autowired注解和Qualifier注解联合起来才可以根据名称进行装配

在Qualifier注解中指定Bean名称。

#image("qualifier.png")

#image("@resource.png")

#image("@resourcecode.png")

注意，resource的name是bean的名字，只是默认为属性名字

当通过name找不到的时候，自然会启动byType进行注入。

#image("allanotation.png")
