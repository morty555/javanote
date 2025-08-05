springboot简化了spring框架的配置，只需要导入springboot依赖即可

springboot的配置一般用properties和yml

#image("properties.png")

port指定端口号，path指定虚拟路径（默认是/）

#image("arrays.png")

#image("useproperties.png")

yml配置key和value之间要有空格

#image("configurationproperties.png")

可以使用configurationproperties来简化配置信息，但是需要保证key一致

#image("beanscan.png")

#image("beansacn2.png")
springbootapplication注解包含了三个注解

其中componentscan注解扫描包中的注解 但是默认的没有指定包，所以只能扫描springbootapplication所在的包下 如果需要扫描其他的包则需要添加componentscan注解

如果要注册的对象来自第三方，无法使用component及衍生注解

所以要使用bean

#image("beanannotation.png")

#image("beananotation2.png")

#image("configuration.png")

不建议在启动类放置bean注册对象 所以要配置类，配置类要和启动类在同一个包下

如果配置类不在同一包下，则需要import

import可以导入多个配置类 可以使用数组

为了代码优雅，可以用importselect返回一个数组，然后通过import导入继承的importselect类

#image("importselecter.png")

#image("importsele.png")

为了方便阅读类

可定义个专门存放配置类的文件

#image("readpropetries.png")

然后在importselecter文件读取配置文件并返回数组

#image("return.png")

若注解太多，可以定义组合注解

#image("setvalue.png")

我们给要注入的对象赋值 并在配置类里配置信息

#image("info.png")

注册条件

#image("conditionalonproperty.png")

#image("conditionalonmissingbean.png")

#image("conditionalonclass.png")

#image("conditionalonclassshow.png")

#image("autoconfig.png")

#image("autoconfig2.png")

#image("starter.png")

starter自定义，首先创建一个自动配置类，在该类中配置bean对象，然后创建文件夹导入import文件，import文件中写入自动配置类的全类名，因为在主启动类中包含了enableautoconfiguration注解，该注解包含了import注解导入了autoconfigurationimportselector类，该类实现了selectimports方法会读取import文件，然后通过import文件中的全类名定位到自动配置类，然后解析该类的注册条件并把满足条件的bean对象注入

