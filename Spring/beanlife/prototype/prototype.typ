如果想让Spring的Bean对象以多例的形式存在，可以在bean标签中指定scope属性的值为：prototype，这样Spring会在每一次执行getBean()方法的时候创建Bean对象，调用几次则创建几次。

#image("properties.png")

#image("test.png")

#image("test2.png")
可以看到这一次在初始化Spring上下文的时候，并没有创建Bean对象。而是在调用getbean创建对象时实例化

那你可能会问：scope如果没有配置，它的默认值是什么呢？默认值是singleton，单例的。
