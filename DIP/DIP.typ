
依赖倒置原则（Dependency Inversion Principle，DIP）的定义可以总结为以下两点：

a. 高层模块不应该依赖于低层模块，两者都应该依赖于抽象。

b. 抽象不应该依赖于细节；细节应该依赖于抽象。

#image("image.png")

如此图 注释的代码导致 UserServiceImpl依赖 UserDaoImplForMySQL
而修改后不依赖

因此可降低耦合度  
