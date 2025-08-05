idea配置tomcat

默认创建的maven web应用没有java和resources目录

自己手动加上。

引入的依赖包括：mybatis，mysql驱动，junit，logback，servlet。

● 引入相关配置文件，放到resources目录下（全部放到类的根路径下）

○ mybatis-config.xml

○ AccountMapper.xml

○ logback.xml

○ jdbc.properties

#image("jdbcproperties.png")

#image("configxml.png")

#image("indexhtml.png")

#image("package.png")

#image("pojo.png") 修改底层数据

#image("daointerface.png") 操作底层数据接口（增删查改等）

#image("daoimpl.png") 实现dao接口

#image("sql.png") 我们在配置文件中mapper绑定了accountmapper.xml文件
而且在daoimpl文件中编写了mybatis代码，mybatis根据配置中的mapper获取sql语句

#image("exceptionm.png")
#image("appexception.png")
#image("serviceinterface.png")

定义service接口，并自定义异常抛出.

#image("serviceimpl.png")

实现service接口,在类中实现transfer功能，包括查询余额和修改功能。
同时在实现类中抛出具体异常信息。（自定义异常时有msq有参构造方法）

#image("controller.png")

具体和网页交互的类。通过request请求获取账户信息，并实例化一个serviceimpl对象调用transfer方法

`@WebServlet("/transfer")`是指定网页地址

`PrintWriter out = response.getWriter();`

response对象是返回到页面的信息，` out.print("<h1>转账成功！！！</h1>");`输出到页面。

若有异常则输出getmessage中的内容

`   response.setContentType("text/html;charset=UTF-8");`则是设置返回到页面内容的格式

！！6.4 MyBatis对象作用域以及事务问题

SqlSessionFactoryBuilder

这个类可以被实例化、使用和丢弃，一旦创建了 SqlSessionFactory，就不再需要它了。 因此 SqlSessionFactoryBuilder 实例的最佳作用域是方法作用域（也就是局部方法变量）。 你可以重用 SqlSessionFactoryBuilder 来创建多个 SqlSessionFactory 实例，但最好还是不要一直保留着它，以保证所有的 XML 解析资源可以被释放给更重要的事情。

SqlSessionFactory

SqlSessionFactory 一旦被创建就应该在应用的运行期间一直存在，没有任何理由丢弃它或重新创建另一个实例。 使用 SqlSessionFactory 的最佳实践是在应用运行期间不要重复创建多次，多次重建 SqlSessionFactory 被视为一种代码“坏习惯”。因此 SqlSessionFactory 的最佳作用域是应用作用域。 有很多方法可以做到，最简单的就是使用单例模式或者静态单例模式。

SqlSession

每个线程都应该有它自己的 SqlSession 实例。SqlSession 的实例不是线程安全的，因此是不能被共享的，所以它的最佳的作用域是请求或方法作用域。 绝对不能将 SqlSession 实例的引用放在一个类的静态域，甚至一个类的实例变量也不行。 也绝不能将 SqlSession 实例的引用放在任何类型的托管作用域中，比如 Servlet 框架中的 HttpSession。 如果你现在正在使用一种 Web 框架，考虑将 SqlSession 放在一个和 HTTP 请求相似的作用域中。 换句话说，每次收到 HTTP 请求，就可以打开一个 SqlSession，返回一个响应后，就关闭它。 这个关闭操作很重要，为了确保每次都能执行关闭操作，你应该把这个关闭操作放到 finally 块中。 下面的示例就是一个确保 SqlSession 关闭的标准模式：

`try (SqlSession session = sqlSessionFactory.openSession()) {
  // 你的应用逻辑代码
}`

原本的update函数里，有事务的提交和回滚函数操作。

#image("newtransaction.png")

我们在代码里新加一个sqlsession，就会导致该事务和update函数里即service和dao中使用的SqlSession对象不是同一个。

为了保证service和dao中使用的SqlSession对象是同一个，可以将SqlSession对象存放到ThreadLocal当中。

#image("threadlocal.png")

如图，新加threadlocal对象，sqlsession从local中得到，就能保证每次对象都是同一个

#image("final.png")

但是我们原本在dao和serviceimpl函数中有回滚（关闭）事务的操作，我们删去那段代码后就要在外面实现这个操作，于是在controller类中添加close函数关闭事务。

我们不难发现，这个dao实现类中的方法代码很固定，基本上就是一行代码，通过SqlSession对象调用insert、delete、update、select等方法，这个类中的方法没有任何业务逻辑，既然是这样，这个类我们能不能动态的生成，以后可以不写这个类吗？答案：可以。
