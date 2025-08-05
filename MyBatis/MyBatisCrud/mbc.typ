在MyBatis中可以这样做：

在Java程序中，将数据放到Map集合中

在sql语句中使用 \#{map集合的key} 来完成传值，\#{} 等同于JDBC中的 ? ，#{}就是占位符

Java程序这样写：

#image("mbc.png")

若key为空（不存在），不过 `#{kk}` 的写法导致无法获取到map集合中的数据，最终导致数据库表car_num插入了NULL。

如果将map集合换成pojo属性传参，结果仍是可以插入

经过测试得出结论：

如果采用map集合传参，#{} 里写的是map集合的key，如果key不存在不会报错，数据库表中会插入NULL。

如果采用POJO传参，#{} 里写的是get方法的方法名去掉get之后将剩下的单词首字母变小写（例如：getAge对应的是\#{age}，getUserName对应的是\#{userName}），如果这样的get方法不存在会报错。

注意：其实传参数的时候有一个属性parameterType，这个属性用来指定传参的数据类型，不过这个属性是可以省略的

#image("delete.png")

#image("update.png")

以上的异常大致的意思是：对于一个查询语句来说，你需要指定它的“结果类型”或者“结果映射”。

所以说，你想让mybatis查询之后返回一个Java对象的话，至少你要告诉mybatis返回一个什么类型的Java对象，可以在`<select>`标签中添加resultType属性，用来指定查询要转换的类型：

#image("select.png")

运行后之前的异常不再出现了，这说明添加了resultType属性之后，解决了之前的异常，可以看出resultType是不能省略的。

仔细观察控制台的日志信息，不难看出，结果查询出了一条。并且每个字段都查询到值了：Row: 1, 100, 宝马520Li, 41.00, 2022-09-01, 燃油车

但是奇怪的是返回的Car对象，只有id和brand两个属性有值，其它属性的值都是null，这是为什么呢？我们来观察一下查询结果列名和Car类的属性名是否能一一对应：

查询结果集的列名：id, car_num, brand, guide_price, produce_time, car_type

Car类的属性名：id, carNum, brand, guidePrice, produceTime, carType
通过观察发现：只有id和brand是一致的，其他字段名和属性名对应不上，这是不是导致null的原因呢？我们尝试在sql语句中使用as关键字来给查询结果列名起别名试试：

#image("as.png")

#image("selectmore.png")

如果sql语句存在同名，要么加命名空间namespcae，要么改名字。

`<mapper namespace="car2">`

test中则为List<Object> cars = sqlSession.selectList("car2.selectCarAll");
