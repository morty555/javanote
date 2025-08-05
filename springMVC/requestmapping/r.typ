requestmapping可以在类和方法上使用,但是不能有一样的。

#image("easyway.png")

可以在类上加公共路径，方法上用特殊路径

如这个就是前端发送请求/product/detail 就会绑定到productDetail方法上

requestmapping 有value，path属性，可以指定多个路径绑定到该方法上

value属性本身是string字符串数组类型

#image("value.png")

这个就是绑定到testval1和testval2

如果只有一个值，可以省略大括号

如果只有一个属性value，value也可以省略

#image("antvalue.png")

#image("attention1.png")

#image("attention2.png")

#image("restfulcode.png")

requestmapping注解还有method属性，指定get，post等请求方式

method也是数组，可以指定多个请求方式

衍生mapping postmapping getmapping等等

form表单只发送get

#image("differenceinpg.png")

#image("choosepg.png")

#image("param.png")

#image("headers.png")

#image("requestparam.png")

required属性可以设置为false 则不是必需那个属性 即使前端不提供 也不会报400错误 但因为没有数据 所以后端变量接收null

defaultvalue给参数赋默认值 若前端没有传属性则后端接收默认值

#image("controlrequestparam.png")

如果形参名和前端的name不一致，该数据则为null

#image("POJO.png")

