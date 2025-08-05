项目中的事务控制是在所难免的。在一个业务流程当中，可能需要多条DML语句共同完成，为了保证数据的安全，这多条DML语句要么同时成功，要么同时失败。这就需要添加事务控制的代码。

#image("controltransaction.png")

#image("targetclass.png")

注意，以上两个业务类已经纳入spring bean的管理，因为都添加了component注解。

接下来我们给以上两个业务类的4个方法添加事务控制代码，使用AOP来完成：

#image("transaction.png")

#image("test.png")