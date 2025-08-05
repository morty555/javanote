#image("configuration.png")

● onfiguration：根标签，表示配置信息。

● environments：环境（多个），以“s”结尾表示复数，也就是说mybatis的环境可以配置多个数据源。

○ default属性：表示默认使用的是哪个环境，default后面填写的是

environment的id。default的值只需要和environment的id值一致即可。

● environment：具体的环境配置（主要包括：事务管理器的配置 + 数据源的配置）

○ id：给当前环境一个唯一标识，该标识用在environments的default后面，用来指定默认环境的选择。

● transactionManager：配置事务管理器

○ type属性：指定事务管理器具体使用什么方式，可选值包括两个

■ JDBC：使用JDBC原生的事务管理机制。底层原理：事务开启conn.setAutoCommit(false); ...处理业务...事务提交conn.commit();

■ MANAGED：交给其它容器来管理事务，比如WebLogic、JBOSS等。如果没有管理事务的容器，则没有事务。没有事务的含义：只要执行一条DML语句，则提交一次。

● dataSource：指定数据源

○ type属性：用来指定具体使用的数据库连接池的策略，可选值包括三个

■ UNPOOLED：采用传统的获取连接的方式，虽然也实现Javax.sql.
DataSource接口，但是并没有使用池的思想。

● property可以是：

○ driver 这是 JDBC 驱动的 Java 类全限定名。

○ url 这是数据库的 JDBC URL 地址。

○ username 登录数据库的用户名。

○ password 登录数据库的密码。

○ defaultTransactionIsolationLevel 默认的连接事务隔离级别。

○ defaultNetworkTimeout 等待数据库操作完成的默认网络超时时间（单位：毫秒）

■ POOLED：采用传统的javax.sql.DataSource规范中的连接池，mybatis中有针对规范的实现。

● property可以是（除了包含UNPOOLED中之外）：

○ poolMaximumActiveConnections 在任意时间可存在的活动（正在使用）连接数量，默认值：10

○ poolMaximumIdleConnections 任意时间可能存在的空闲连接数。
○ 其它....

■ JNDI：采用服务器提供的JNDI技术实现，来获取DataSource对象，不同的服务器所能拿到DataSource是不一样。如果不是web或者maven的war工程，JNDI是不能使用的。

● property可以是（最多只包含以下两个属性）：

○ initial_context 这个属性用来在 InitialContext 中寻找上下文（即，initialContext.lookup(initial_context)）这是个可选属性，如果忽略，那么将会直接从 InitialContext 中寻找 data_source 属性。

○ data_source 这是引用数据源实例位置的上下文路径。提供了 initial_context 配置时会在其返回的上下文中进行查找，没有提供时则直接在 InitialContext 中查找。

● mappers：在mappers标签中可以配置多个sql映射文件的路径。


● mapper：配置某个sql映射文件的路径

○ resource属性：使用相对于类路径的资源引用方式

○ url属性：使用完全限定资源定位符（URL）方式

  使用默认数据库

  SqlSessionFactory sqlSessionFactory = sqlSessionFactoryBuilder.build(Resources.getResourceAsStream("mybatis-config.xml"));

  使用指定数据库

SqlSessionFactory sqlSessionFactory1 = sqlSessionFactoryBuilder.build(Resources.getResourceAsStream("mybatis-config.xml"), "dev");

#image("transaction.png")

dataSource:

通过测试得出：UNPOOLED不会使用连接池，每一次都会新建JDBC连接对象。POOLED会使用数据库连接池。【这个连接池是mybatis自己实现的。】

JNDI的方式：表示对接JNDI服务器中的连接池。这种方式给了我们可以使用第三方连接池的接口。如果想使用dbcp、c3p0、druid（德鲁伊）等，需要使用这种方式。

这种再重点说一下type="POOLED"的时候，它的属性有哪些？

poolMaximumActiveConnections：最大的活动的连接数量。默认值10

poolMaximumIdleConnections：最大的空闲连接数量。默认值5

poolMaximumCheckoutTime：强行回归池的时间。默认值20秒。

poolTimeToWait：当无法获取到空闲连接时，每隔20秒打印一次日志，避免因代码配置有误，导致傻等。（时长是可以配置的）

当然，还有其他属性。对于连接池来说，以上几个属性比较重要。

最大的活动的连接数量就是连接池连接数量的上限。默认值10，如果有10个请求正在使用这10个连接，第11个请求只能等待空闲连接。

最大的空闲连接数量。默认值5，如何已经有了5个空闲连接，当第6个连接要空闲下来的时候，连接池会选择关闭该连接对象。来减少数据库的开销。

需要根据系统的并发情况，来合理调整连接池最大连接数以及最多空闲数量。充分发挥数据库连接池的性能。【可以根据实际情况进行测试，然后调整一个合理的数量。】

properties:

mybatis提供了更加灵活的配置，连接数据库的信息可以单独写到一个属性资源文件中，假设在类的根路径下创建jdbc.properties文件，配置如下：

`jdbc.driver=com.mysql.cj.jdbc.Driver`

`jdbc.url=jdbc:mysql://localhost:3306/powernode`

#image("properties.png")

properties两个属性：

resource：这个属性从类的根路径下开始加载。【常用的。】

url：从指定的url加载，假设文件放在d:/jdbc.properties，这个url可以写成：`file:///d:/jdbc.properties。注意是三个斜杠哦。`
                                                      /// 
注意：如果不知道mybatis-config.xml文件中标签的编写顺序的话，可以有两种方式知道它的顺序：

● 第一种方式：查看dtd约束文件。

● 第二种方式：通过idea的报错提示信息。【一般采用这种方式】

mapper:
