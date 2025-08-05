16.1 事务概述

● 什么是事务

○ 在一个业务流程当中，通常需要多条DML（insert delete update）语句共同联合才能完成，这多条DML语句必须同时成功，或者同时失败，这样才能保证数据的安全。

○ 多条DML要么同时成功，要么同时失败，这叫做事务。

○ 事务：Transaction（tx）

● 事务的四个处理过程：

○ 第一步：开启事务 (start transaction)

○ 第二步：执行核心业务代码

○ 第三步：提交事务（如果核心业务处理过程中没有出现异常）(commit transaction)

○ 第四步：回滚事务（如果核心业务处理过程中出现异常）(rollback transaction)

● 事务的四个特性：

○ A 原子性：事务是最小的工作单元，不可再分。

○ C 一致性：事务要求要么同时成功，要么同时失败。事务前和事务后的总量不变。

○ I 隔离性：事务和事务之间因为有隔离性，才可以保证互不干扰。

○ D 持久性：持久性是事务结束的标志。

16.3 Spring对事务的支持

Spring实现事务的两种方式

● 编程式事务

○ 通过编写代码的方式来实现事务的管理。

● 声明式事务

○ 基于注解方式

○ 基于XML配置方式

Spring事务管理API

Spring对事务的管理底层实现方式是基于AOP实现的。采用AOP的方式进行了封装。所以Spring专门针对事务开发了一套API，API的核心接口如下：

PlatformTransactionManager接口：spring事务管理器的核心接口。在Spring6中它有两个实现：

● DataSourceTransactionManager：支持JdbcTemplate、MyBatis、Hibernate等事务管理。

● JtaTransactionManager：支持分布式事务管理。

如果要在Spring6中使用JdbcTemplate，就要使用DataSourceTransactionManager来管理事务。（Spring内置写好了，可以直接用。）

#image("step123.png")

● 第四步：在service类上或方法上添加Transactional注解
在类上添加该注解，该类中所有的方法都有事务。在某个方法上添加该注解，表示只有这个方法使用事务。


事务中的重点属性：

● 事务传播行为

什么是事务的传播行为？

在service类中有a()方法和b()方法，a()方法上有事务，b()方法上也有事务，当a()方法执行过程中调用了b()方法，事务是如何传递的？合并到一个事务里？还是开启一个新的事务？这就是事务传播行为。

事务传播行为在spring框架中被定义为枚举类型：
#image("spreadway.png")

● 事务隔离级别
#image("desperate.png")

隔离级别在spring中以枚举类型存在

● 事务超时
#image("timeexceed.png")
#image("timeexceed2.png")

● 只读事务
#image("onlyread.png")

● 设置出现哪些异常回滚事务

● 设置出现哪些异常不回滚事务
#image("rollback.png")
