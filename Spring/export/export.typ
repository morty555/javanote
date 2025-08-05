我们都知道编写数据源的时候是需要连接数据库的信息的，例如：driver url username password等信息。这些信息可以单独写到一个属性配置文件中吗，这样用户修改起来会更加的方便。当然可以。

第一步：写一个数据源类，提供相关属性。
#image("dataresource.png")

第二步：在类路径下新建jdbc.properties文件，并配置信息。
#image("properties.png")

第三步：在spring配置文件中引入context命名空间。
#image("context.png")

第四步：在spring中配置使用jdbc.properties文件。
#image("propertiesinxml.png")