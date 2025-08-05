scope属性的值不止两个，它一共包括8个选项：

● singleton：默认的，单例。

● prototype：原型。每调用一次getBean()方法则获取一个新的Bean对象。或每次注入的时候都是新对象。

● request：一个请求对应一个Bean。仅限于在WEB应用中使用。

● session：一个会话对应一个Bean。仅限于在WEB应用中使用。

● global session：portlet应用中专用的。如果在Servlet的WEB应用中使用global session的话，和session一个效果。（portlet和servlet都是规范。servlet运行在servlet容器中，例如Tomcat。portlet运行在portlet容器中。）

● application：一个应用对应一个Bean。仅限于在WEB应用中使用。

● websocket：一个websocket生命周期对应一个Bean。仅限于在WEB应用中使用。

● 自定义scope：很少使用。

接下来咱们自定义一个Scope，线程级别的Scope，在同一个线程中，获取的Bean都是同一个。跨线程则是不同的对象：

● 第一步：自定义Scope。（实现Scope接口）
○ spring内置了线程范围的类：org.springframework.context.support.SimpleThreadScope，可以直接用。

● 第二步：将自定义的Scope注册到Spring容器中

#image("scopespro.png")

第三步：使用Scope
#image("use.png")

测试如下：
#image("test.png")

#image("result.png")
可见不同线程的对象不同 同线程的相同
