\#{}：先编译sql语句，再给占位符传值，底层是PreparedStatement实现。可以防止sql注入，比较常用。

#image("#.png")

\${}：先进行sql语句拼接，然后再编译sql语句，底层是Statement实现。存在sql注入现象。只有在需要进行sql语句关键字拼接的情况下才会用到。

#image("$.png")

`  car_type = '${carType}'`

通过以上测试，可以看出，对于以上这种需求来说，还是建议使用 #{} 的方式。
原则：能用 \#{} 就不用 \${}

什么情况下必须使用\${}

当需要进行sql语句关键字拼接的时候。必须使用\${}

需求：通过向sql语句中注入asc或desc关键字，来完成数据的升序或降序排列。

先使用\#{}尝试：

#image("descwrong.png")

#image("desctrue.png")

拼接表名

业务背景：实际开发中，有的表数据量非常庞大，可能会采用分表方式进行存储，比如每天生成一张表，表的名字与日期挂钩，例如：2022年8月1日生成的表：t_user20220108。2000年1月1日生成的表：t_user20000101。此时前端在进行查询的时候会提交一个具体的日期，比如前端提交的日期为：2000年1月1日，那么后端就会根据这个日期动态拼接表名为：t_user20000101。有了这个表名之后，将表名拼接到sql语句当中，返回查询结果。

那么大家思考一下，拼接表名到sql语句当中应该使用#{} 还是 \${} 呢？

使用\#{}会是这样：select \* from 't_car'

使用\${}会是这样：select \* from t_car

批量删除

业务背景：一次删除多条记录。

对应的sql语句：

● delete from t_user where id = 1 or id = 2 or id = 3;

● delete from t_user where id in(1, 2, 3);

假设现在使用in的方式处理，前端传过来的字符串：1, 2, 3

如果使用mybatis处理，应该使用\#{} 还是 \${}

使用\#{} ：delete from t_user where id in('1,2,3') 执行错误：1292 - Truncated incorrect DOUBLE value: '1,2,3'

使用\${} ：delete from t_user where id in(1, 2, 3)

#image("selectunclear.png")

#image("concat.png")

#image("doubleq.png")

