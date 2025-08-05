#image("maven.png")
#image("configuration.png")
注意1：mybatis核心配置文件的文件名不一定是mybatis-config.xml，可以是其它名字。

注意2：mybatis核心配置文件存放的位置也可以随意。这里选择放在resources根下，相当于放到了类的根路径下
#image("carmapper.png")
注意1：sql语句最后结尾可以不写“;”

注意2：CarMapper.xml文件的名字不是固定的。可以使用其它名字。

注意3：CarMapper.xml文件的位置也是随意的。这里选择放在resources根
下，相当于放到了类的根路径下。

注意4：将CarMapper.xml文件路径配置到mybatis-config.xml：

#image("config.png")

#image("buildsql.png")

注意1：默认采用的事务管理器是：JDBC。JDBC事务默认是不提交的，需要手动提交。

封装工具类utils
#image("utils.png")
#image("test.png")
