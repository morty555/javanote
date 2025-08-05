第一步：定义一个Bean

#image("beaninit.png")

第二步：编写简单工厂模式当中的工厂类

#image("factory.png")

第三步：在Spring配置文件中指定创建该Bean的方法（使用factory-method属性指定）

#image("beanproperties.png")

这里不会创建VipFactory这个类所对应的对象，直接调用工厂类的静态方法创建Vip对象

底层仍是自动调用无参构造方法

若vip类中重写了无参构造方法，也会自动调用重写无参构造方法中的函数
#image("test.png")
