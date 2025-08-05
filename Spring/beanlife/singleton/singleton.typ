默认情况下，Spring的IoC容器创建的Bean对象是单例的.

#image("test.png")
这里我们在xml文件中配置一个bean对象，接着在test中生成两个对应的springbean对象并print 结果指向同一个值

#image("result.png")

这个对象在什么时候创建的呢？可以为SpringBean提供一个无参数构造方法

#image("constuctor.png")

#image("init.png")
通过测试得知，默认情况下，Bean对象的创建是在初始化Spring上下文的时候就完成的。
