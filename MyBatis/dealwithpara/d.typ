简单类型包括：

● byte short int long float double char

● Byte Short Integer Long Float Double Character

● String

● java.util.Date

● java.sql.Date

需求：根据name查、根据id查、根据birth查、根据sex查

通过测试得知，简单类型对于mybatis来说都是可以自动类型识别的：

● 也就是说对于mybatis来说，它是可以自动推断出ps.setXxxx()方法的。ps.setString()还是ps.setInt()。它可以自动推断。

其实SQL映射文件中的配置比较完整的写法是：

`<select id="selectByName" resultType="student" parameterType="java.lang.String">
  select * from t_student where name = #{name, javaType=String, jdbcType=VARCHAR}
</select>`

其中sql语句中的javaType，jdbcType，以及select标签中的parameterType属性，都是用来帮助mybatis进行类型确定的。不过这些配置多数是可以省略的。因为mybatis它有强大的自动类型推断机制。

● javaType：可以省略

● jdbcType：可以省略

● parameterType：可以省略

如果参数只有一个的话，\#{} 里面的内容就随便写了。对于 \${} 来说，注意加单引号。

10.2 Map参数

需求：根据name和age查询

#image("map.png")

10.3 实体类参数

#image("class.png")

10.4 多参数

#image("wrong.png")

这样会报错

异常信息描述了：name参数找不到，可用的参数包括[arg1, arg0, param1, param2]

修改StudentMapper.xml配置文件：尝试使用[arg1, arg0, param1, param2]去参数

#image("true.png")

通过测试可以看到：

● arg0 是第一个参数

● param1是第一个参数

● arg1 是第二个参数

● param2是第二个参数

实现原理：实际上在mybatis底层会创建一个map集合，以arg0/param1为key，以方法上的参数为value

例如以下代码：

`Map<String,Object> map = new HashMap<>();
map.put("arg0", name);
map.put("arg1", sex);
map.put("param1", name);
map.put("param2", sex);

// 所以可以这样取值：#{arg0} #{arg1} #{param1} #{param2}
// 其本质就是#{map集合的key}`

10.5 \@Param注解（命名参数）
#image("@param.png")