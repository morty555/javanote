#image("githubpro.png")

在github上寻找spring6配置文件并在pom文件中配置

junit

spring配置文件 在resources 自定义configuration

bean：
1.id 标识
2.class 类的全路径

#image("bean.png")

#image("startspring.png")

在配置中设置bean 并在test中通过上下文applicationcontext对象中的方法调用

在user中创建无参构造方法 spring会根据bean的id通过getBean函数调用无参构造方法

spring的xml文件可以有多个 因为classpathxmlapplicationcontext对象有实现多个xml参数的函数

#image("savewhere.png")

bean的返回类型可以通过强转或者参数调整

#image("fatherinterface.png")

#image("createobject.png")

实现原理：通过property标签获取到属性名：userDao
通过属性名推断出set方法名：setUserDao
通过反射机制调用setUserDao()方法给属性赋值
property标签的name是属性名。
property标签的ref是要注入的bean对象的id。
