#image("xmlbyname.png")

这个配置起到关键作用：
● UserService Bean中需要添加autowire="byName"，表示通过名称进行装配。
● UserService类中有一个UserDao属性，而UserDao属性的名字是aaa，对应的set方法是setAaa()，正好和UserDao Bean的id是一样的。这就是根据名称自动装配。

#image("xmlbytype.png")

自动装配基于set方法  不能有两个类型一样的bean
