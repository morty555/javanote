引入依赖

`<dependency>
  <groupId>org.javassist</groupId>
  <artifactId>javassist</artifactId>
  <version>3.29.1-GA</version>
</dependency>`

#image("test.png")

运行要注意：加两个参数，要不然会有异常。

● --add-opens java.base/java.lang=ALL-UNNAMED

● --add-opens java.base/sun.net.util=ALL-UNNAMED