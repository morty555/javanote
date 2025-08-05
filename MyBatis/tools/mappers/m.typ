9.3 mappers

SQL映射文件的配置方式包括四种：

● resource：从类路径中加载

● url：从指定的全限定资源路径中加载

● class：使用映射器接口实现类的完全限定类名

● package：将包内的映射器接口实现全部注册为映射器

resource

这种方式是从类路径中加载配置文件，所以这种方式要求SQL映射文件必须放在resources目录下或其子目录下。

`<mappers>
  <mapper resource="org/mybatis/builder/AuthorMapper.xml"/>
  <mapper resource="org/mybatis/builder/BlogMapper.xml"/>
  <mapper resource="org/mybatis/builder/PostMapper.xml"/>
</mappers>`

url

这种方式显然使用了绝对路径的方式，这种配置对SQL映射文件存放的位置没有要求，随意。

`<mappers>
  <mapper url="file:///var/mappers/AuthorMapper.xml"/>
  <mapper url="file:///var/mappers/BlogMapper.xml"/>
  <mapper url="file:///var/mappers/PostMapper.xml"/>
</mappers>`

class

如果使用这种方式必须满足以下条件：

● SQL映射文件和mapper接口放在同一个目录下。

● SQL映射文件的名字也必须和mapper接口名一致。

`<mappers>
  <mapper class="org.mybatis.builder.AuthorMapper"/>
  <mapper class="org.mybatis.builder.BlogMapper"/>
  <mapper class="org.mybatis.builder.PostMapper"/>
</mappers>`

package

如果class较多，可以使用这种package的方式，但前提条件和上一种方式一样。

`<!-- 将包内的映射器接口实现全部注册为映射器 -->
<mappers>
  <package name="com.powernode.mybatis.mapper"/>
</mappers>`

#image("ideaconfigure.png")

9.5 插入数据时获取自动生成的主键

前提是：主键是自动生成的。

业务背景：一个用户有多个角色。

#image("table.png")

插入一条新的记录之后，自动生成了主键，而这个主键需要在其他表中使用时。
插入一个用户数据的同时需要给该用户分配角色：需要将生成的用户的id插入到角色表的user_id字段上。

第一种方式：可以先插入用户数据，再写一条查询语句获取id，然后再插入user_id字段。【比较麻烦】

第二种方式：mybatis提供了一种方式更加便捷。

#image("way.png")