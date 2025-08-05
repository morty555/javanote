#image("rules.png")

外部注入和内部注入
#image("bean.png")

简单类型注入
#image("simpletype.png")

Date：一般开发不会把Date类型当作简单类型 而是使用ref赋值

数据源

#image("datasource.png")

#image("datasourcexml.png")

级联属性

#image("jilian.png")

数组的赋值

简单类型：
#image("array.png", height: 160pt)

非简单类型：
#image("complexarray.png")

list:有序可重复
#image("list.png")

set:无序不可重复
#image("set.png")

map:
#image("map.png")

properties:java.util.Properties继承java.util.Hashtable，所以Properties也是一个Map集合。
#image("properties.png")

注入null和空字符串

空字符串：#image("empty.png")

null:#image("null1.png")
#image("null2.png")

特殊符号：● 第一种：特殊符号使用转义字符代替。

● 第二种：将含有特殊符号的字符串放到：<![CDATA[]]> 当中。因为放在CDATA区中的数据不会被XML文件解析器解析。
#image("specialchar.png")

CDATA:
#image("cdata.png")

p命名空间注入:
#image("p.png")

多一行配置：xmlns：p

