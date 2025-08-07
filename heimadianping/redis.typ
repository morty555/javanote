#set text(size:2em)
- redis基础
  - key value

    - value可以为字符串，数值，json
  - NoSQL
  - 结构化和非结构化

    - 传统关系型数据库是结构化数据，严格约束信息，而NoSQL则对数据库格式没有约束，可以是键值型，也可以是文档型，甚至是图格式
  - 关联和非关联

    传统数据库的表与表之间往往存在关联，例如外键约束

    而非关系型数据库不存在关联关系，要维护关系要么靠代码中的业务逻辑，要么靠数据之间的耦合
  - 事务
    传统关系型数据库能满足事务的ACID原则(原子性、一致性、独立性及持久性)

    而非关系型数据库不支持事务，或者不能要个保证ACID的特性，只能实现基本的一致性  
  #image("Screenshot_20250731_164302.png")
  - 存储方式
    - 关系型数据库基于磁盘进行存储，会有大量的磁盘IO，对性能有一定影响
    - 非关系型数据库，他们的操作更多的是依赖于内存来操作，内存的读写速度会非常快，性能自然会好一些
  - 扩展性
    - 关系型数据库集群模式一般是主从，主从数据一致，起到数据备份的作用，称为垂直扩展。
    - 非关系型数据库可以将数据拆分，存储在不同机器上，可以保存海量数据，解决内存大小有限的问题。称为水平扩展。
    - 关系型数据库因为表之间存在关联关系，如果做水平扩展会给数据查询带来很多麻烦（如join操作，事务一致性，SQL 在单库环境下的优势（如复杂查询、聚合、排序、子查询），为了避免频繁跨库 JOIN，系统可能会把用户信息复制到订单表中（反规范化），增加了冗余和一致性维护成本。）
  - 特点
    - 键值(Key-Value)型，Value支持多种不同的数据结构，功能丰富
    - 单线程，每个命令具有原子性
    - 低延迟，速度快(基于内存、IO多路复用、良好的编码)
    - 支持数据持久化
    - 支持主从集群、分片集群
    - 支持多语言客户端
  - 常用命令
    #image("Screenshot_20250731_165106.png")
  - String类型
    - String类型，也就是字符串类型，是Redis中最简单的存储类型
      其value是字符串，不过根据字符串的格式不同，又可以分为3类
      - string：普通字符串
      - int：整数类型，可以做自增、自减操作
      - float：浮点类型，可以做自增、自减操作
      - 不管是哪种格式，底层都是字节数组形式存储，只不过是编码方式不同，字符串类型的最大空间不能超过512M
    - 常用命令
      #image("Screenshot_20250731_165332.png")
  - key结构
    #image("Screenshot_20250731_165723.png")
  - Hash
    - Hash类型，也叫散列，其中value是一个无序字典，类似于Java中的HashMap结构
    - String结构是将对象序列化为JSON字符串后存储，当我们要修改对象的某个属性值的时候很不方便
    - Hash结构可以将对象中的每个字段独立存储，可以针对单个字段做CRUD
    #image("Screenshot_20250731_165921.png")
    - 常用命令
    #image("Screenshot_20250731_170019.png")
  - List
    - Redis中的List类型与Java中的LinkedList类似，可以看做是一个双向链表结构。既可以支持正向检索和也可以支持反向检索。
    - 特征也与LinkedList类似：
      - 有序
      - 元素可以重复
      - 插入和删除快
      - 查询速度一般
    - 常用来存储一个有序数据，例如：朋友圈点赞列表，评论列表等。
    - 常用命令
      #image("Screenshot_20250731_170752.png")
  - set
    - Redis的Set结构与Java中的HashSet类似，可以看做是一个value为null的HashMap。因为也是一个hash表，因此具备与HashSet类似的特征
     - 无序
     - 元素不可重复
     - 查找快
     - 支持交集、并集、差集等功能
    - 常见命令
      #image("Screenshot_20250731_171232.png")
  - sortedset
    - Redis的SortedSet是一个可排序的set集合，与Java中的TreeSet有些类似，但底层数据结构却差别很大。SortedSet中的每一个元素都带有一个score属性，可以基于score属性对元素排序，底层的实现是一个跳表（SkipList）加 hash表。
    - SortedSet具备下列特性：
      - 可排序
      - 元素不重复 
      - 查询速度快
    - 因为SortedSet的可排序特性，经常被用来实现排行榜这样的功能。
    - 常见命令
      #image("Screenshot_20250731_171634.png")
        - 注意：所有的排名默认都是升序，如果要降序则在命令的Z后面添加REV即可，例如：

      升序获取sorted set 中的指定元素的排名：ZRANK key member
      降序获取sorted set 中的指定元素的排名：ZREVRANK key memeber
  - redis的java客户端
    - jedis
    - springdataredis
      - 导入依赖
        ```java
              <!--redis依赖-->
      <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-data-redis</artifactId>
      </dependency>
      <!--common-pool-->
      <dependency>
          <groupId>org.apache.commons</groupId>
          <artifactId>commons-pool2</artifactId>
      </dependency>
      <!--Jackson依赖-->
      <dependency>
          <groupId>com.fasterxml.jackson.core</groupId>
          <artifactId>jackson-databind</artifactId>
      </dependency>
      <!--lombok-->
      <dependency>
          <groupId>org.projectlombok</groupId>
          <artifactId>lombok</artifactId>
          <optional>true</optional>
      </dependency>
      <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-test</artifactId>
          <scope>test</scope>
      </dependency>

        ```
        - 配置Redis
        ```java
            spring:
      redis:
        host: 101.42.225.160
        port: 6379
        password: root
        lettuce:
          pool:
            max-active: 8
            max-idle: 8
            min-idle: 0
            max-wait: 100ms

        ```
        - 注入redistemplate
        ```java
        @Autowired
        private RedisTemplate redisTemplate;
        ```
        - 编写测试方法
        - 自定义序列化
          

           - RedisTemplate可以接收任意Object作为值写入Redis
          只不过写入前会把Object序列化为字节形式，默认是采用JDK序列化，得到的结果是这样的
          - 缺点：
            - 可读性差
            - 内存占用大
          - 我们可以自定义RedisTemplate的序列化方式，代码如下
          在com.blog.config包下编写对应的配置类
          ```java
                      @Configuration
            public class RedisConfig {

                @Bean
                public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
                    // 创建RedisTemplate对象
                    RedisTemplate<String, Object> template = new RedisTemplate<>();
                    // 设置连接工厂
                    template.setConnectionFactory(connectionFactory);
                    // 创建JSON序列化工具
                    GenericJackson2JsonRedisSerializer jsonRedisSerializer =
                            new GenericJackson2JsonRedisSerializer();
                    // 设置Key的序列化
                    template.setKeySerializer(RedisSerializer.string());
                    template.setHashKeySerializer(RedisSerializer.string());
                    // 设置Value的序列化
                    template.setValueSerializer(jsonRedisSerializer);
                    template.setHashValueSerializer(jsonRedisSerializer);
                    // 返回
                    return template;
                }
            }

          ```
          - 这里采用了JSON序列化来代替默认的JDK序列化方式。最终结果如下
           ```
          {
            "@class": "com.blog.entity.User",
            "name": "张三",
            "age": 18
          }```
          - 整体可读性有了很大提升，并且能将Java对象自动的序列化为JSON字符串，并且查询时能自动把JSON反序列化为Java对象。不过，其中记录了序列化时对应的class名称，目的是为了查询时实现自动反序列化。这会带来额外的内存开销。
      - stringredistemplate
        - 为了节省内存空间，我们可以不使用JSON序列化器来处理value，而是统一使用String序列化器，要求只能存储String类型的key和value。当需要存储Java对象时，手动完成对象的序列化和反序列化。
        - 因为存入和读取时的序列化及反序列化都是我们自己实现的，SpringDataRedis就不会将class信息写入Redis了
        - 这种用法比较普遍，因此SpringDataRedis就提供了RedisTemplate的子类：StringRedisTemplate，它的key和value的序列化方式默认就是String方式。源码如下
        ```java
        public class StringRedisTemplate extends RedisTemplate<String, String> {
    public StringRedisTemplate() {
        this.setKeySerializer(RedisSerializer.string());
        this.setValueSerializer(RedisSerializer.string());
        this.setHashKeySerializer(RedisSerializer.string());
        this.setHashValueSerializer(RedisSerializer.string());
    }

        ```
        - 省去了我们自定义RedisTemplate的序列化方式的步骤（可以将之前配置的RedisConfig删除掉），而是直接使用：
        ```java
                @Test
            void stringTest() throws JsonProcessingException {
            //创建对象
            User user = new User("张三", 18);
            //手动序列化
            String json = mapper.writeValueAsString(user);
            //写入数据
            stringRedisTemplate.opsForValue().set("userdata", json);
            //获取数据
            String userdata = stringRedisTemplate.opsForValue().get("userdata");
            //手动反序列化
            User readValue = mapper.readValue(userdata, User.class);
            System.out.println(readValue);
        }

        ```
        - 存入Redis中是这样的
        ```
                  {
            "name": "张三",
            "age": 18
          }
        ```
- 短信登录
  - nginx
    - 若使用传统java,从浏览器通过http发送请求到nginx到tomcat，然后再通过java代码联系redis或数据库
      - 意味着每次请求都要开一个tomcat
    - 如果引入lua，就是客户端 → Nginx + Lua → Redis
    - 一台4核8G的Tomcat，在优化和处理简单业务的加持下，大不了就处理1000左右的并发，nginx可以轻松抗上万并发
    - ginx在部署了前端项目后，更是可以做到动静分离，进一步降低Tomcat服务的压力，
  - mysql压力
    - 在Tomcat支撑起并发流量后，我们如果让Tomcat直接去访问Mysql，根据经验Mysql企业级服务器只要上点并发，一般是16或32 核心cpu，32 或64G内存，像企业级mysql加上固态硬盘能够支撑的并发，大概就是4000起~7000左右，上万并发， 瞬间就会让Mysql服务器的cpu，硬盘全部打满，容易崩溃，所以我们在高并发场景下，会选择使用mysql集群，同时为了进一步降低Mysql的压力，同时增加访问的性能，我们也会加入Redis，同时使用Redis集群使得Redis对外提供更好的服务。
  - 基于session实现登录流程
    - 发送验证码
      
      用户在提交手机号后，会校验手机号是否合法，如果不合法，则要求用户重新输入手机号

      如果手机号合法，后台此时生成对应的验证码，同时将验证码进行保存，然后再通过短信的方式将验证码发送给用户
    - 短信验证码登录、注册
      
      用户将验证码和手机号进行输入，后台从session中拿到当前验证码，然后和用户输入的验证码进行校验，如果不一致，则无法通过校验，如果一致，则后台根据手机号查询用户，如果用户不存在，则为用户创建账号信息，保存到数据库，无论是否存在，都会将用户信息保存到session中，方便后续获得当前登录信息
    - 校验登录状态
      
      用户在请求的时候，会从cookie中携带JsessionId到后台，后台通过JsessionId从session中拿到用户信息，如果没有session信息，则进行拦截，如果有session信息，则将用户信息保存到threadLocal中，并放行

      - 在服务器端一个 Session 中保存多个数据
        ```java
        session.setAttribute("user", userObject);
        session.setAttribute("cart", cartObject);
        session.setAttribute("preferences", prefsObject);
        ```
      - 一个浏览器（同一个域名）只能持有一个 JSESSIONID，即一个会话。
    - 实现发送验证码
    - 实现登陆校验（拦截器）
    - 隐藏敏感信息（新建一个类，删去敏感信息）
    - session共享问题
      
      每个tomcat中都有一份属于自己的session,假设用户第一次访问第一台tomcat，并且把自己的信息存放到第一台服务器的session中，但是第二次这个用户访问到了第二台tomcat，那么在第二台服务器上，肯定没有第一台服务器存放的session，所以此时 整个登录拦截功能就会出现问题，我们能如何解决这个问题呢？早期的方案是session拷贝，就是说虽然每个tomcat上都有不同的session，但是每当任意一台服务器的session修改时，都会同步给其他的Tomcat服务器的session，这样的话，就可以实现session的共享了

      但是这种方案具有两个大问题
      - 每台服务器中都有完整的一份session数据，服务器压力过大。
      - session拷贝数据时，可能会出现延迟
      所以我们后面都是基于Redis来完成，我们把session换成Redis，Redis数据本身就是共享的，就可以避免session共享的问题了
    - Redis替代session的业务流程
      - 设计key结构
        
        由于存入的数据比较简单，我们可以使用String或者Hash

        如果使用String，以JSON字符串来保存数据，会额外占用部分空间

        如果使用Hash，则它的value中只会存储数据本身
      - 设计key的具体细节
        
        我们这里就采用的是简单的K-V键值对方式

        但是对于key的处理，不能像session一样用phone或code来当做key

        因为Redis的key是共享的，code可能会重复，phone这种敏感字段也不适合存储到Redis中

        在设计key的时候，我们需要满足两点 
        - key要有唯一性
        - key要方便携带

        所以我们在后台随机生成一个token，然后让前端带着这个token就能完成我们的业务逻辑了
       - 整体访问流程
         
          当注册完成后，用户去登录，然后校验用户提交的手机号/邮箱和验证码是否一致

          如果一致，则根据手机号查询用户信息，不存在则新建，最后将用户数据保存到Redis，并生成一个token作为Redis的key

          当我们校验用户是否登录时，回去携带着token进行访问，从Redis中获取token对应的value，判断是否存在这个数据

              如果不存在，则拦截

              如果存在，则将其用户信息(userDto)保存到
              threadLocal中，并放行
        - 基于Redis实现短信登录
          ```java 
                              @PostMapping("/login")
                    public Result login(@RequestBody LoginFormDTO loginForm, HttpSession session) {
                        // TODO 实现登录功能
                        //获取登录账号
                        String phone = loginForm.getPhone();
                        //获取登录验证码
                        String code = loginForm.getCode();
                        //获取redis中的验证码
                        String cacheCode = stringRedisTemplate.opsForValue().get(LOGIN_CODE_KEY + phone);

                        //1. 校验邮箱
                        if (RegexUtils.isEmailInvalid(phone)) {
                            //2. 不符合格式则报错
                            return Result.fail("邮箱格式不正确！！");
                        }
                        //3. 校验验证码
                        log.info("code:{},cacheCode{}", code, cacheCode);
                        if (cacheCode == null || !cacheCode.equals(code)) {
                            // 不一致，报错
                            return Result.fail("验证码错误");
                        }
                        //5. 根据账号查询用户是否存在
                        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
                        queryWrapper.eq(User::getPhone, phone);
                        User user = userService.getOne(queryWrapper);
                        //6. 如果不存在则创建
                        if (user == null) {
                            user = createUserWithPhone(phone);
                        }
                        //7. 保存用户信息到session中
                        //7. 保存用户信息到Redis中
                        //7.1 随机生成token，作为登录令牌
                        String token = UUID.randomUUID().toString();
                        //7.2 将UserDto对象转为HashMap存储
                        UserDTO userDTO = BeanUtil.copyProperties(user, UserDTO.class);
                        HashMap<String, String > userMap = new HashMap<>();
                        userMap.put("icon", userDTO.getIcon());
                        userMap.put("id", String.valueOf(userDTO.getId()));
                        userMap.put("nickName", userDTO.getNickName());
                        //高端写法，现在我还学不来，工具类还不太了解，只能自己手动转换类型然后put了
                //        Map<String, Object> userMap = BeanUtil.beanToMap(userDTO, new HashMap<>(),
                //                CopyOptions.create()
                //                        .setIgnoreNullValue(true)
                //                        .setFieldValueEditor((fieldName, fieldValue) -> fieldValue.toString()));
                        //7.3 存储
                        String tokenKey = LOGIN_USER_KEY + token;
                        stringRedisTemplate.opsForHash().putAll(tokenKey, userMap);
                        //7.4 设置token有效期为30分钟
                        stringRedisTemplate.expire(tokenKey, 30, TimeUnit.MINUTES);
                        //7.5 登陆成功则删除验证码信息
                        stringRedisTemplate.delete(LOGIN_CODE_KEY + phone);
                        //8. 返回token
                        return Result.ok(token);
                    }
          
          ```
        - 解决状态登录刷新问题

          - 我们可以通过拦截器拦截到的请求，来证明用户是否在操作，如果用户没有任何操作30分钟，则token会消失，用户需要重新登录
          通过查看请求，我们发现我们存的token在请求头里，那么我们就在拦截器里来刷新token的存活时间

           在这个方案中，他确实可以使用对应路径的拦截，同时刷新登录token令牌的存活时间，但是现在这个拦截器他只是拦截需要被拦截的路径，假设当前用户访问了一些不需要拦截的路径，那么这个拦截器就不会生效，所以此时令牌刷新的动作实际上就不会执行，所以这个方案他是存在问题的

          - 既然之前的拦截器无法对不需要拦截的路径生效，那么我们可以添加一个拦截器，在第一个拦截器中拦截所有的路径，把第二个拦截器做的事情放入到第一个拦截器中，同时刷新令牌，因为第一个拦截器有了threadLocal的数据，所以此时第二个拦截器只需要判断拦截器中的user对象是否存在即可，完成整体刷新功能。

          新建一个RefreshTokenInterceptor类，其业务逻辑与之前的LoginInterceptor类似，就算遇到用户未登录，也继续放行，交给LoginInterceptor处理
        - 登录功能实现大致思路为

          注册时前端传来phone生成随机code放到redis中

          登录时从前端传来的表单中拿到phone和code然后去redis中查到验证码并进行匹配，若匹配就到数据库中用phone查用户，并且生成一个token用来检验登录状态，后续都用token检验登录状态

          前端每次访问接口都会将带token的request传到后端被RefreshTokenInterceptor拦截

          登录的时候LoginInterceptor不拦截登录接口，但是RefreshTokenInterceptor会拦截，所以在登录的代码执行完后，redis中就有该用户的数据，然后对某个接口访问时，因为refreshtokeninterceptor的order(0)先被拦截，先把用户信息从redis中拿到放到threadlocal 然后logininterceptor再拦截就有用户信息就能访问了，并且每次访问接口时都会刷新ttl
        - jwt和session和redis的工作流程与优缺点
          - jwt工作形式就是 前端提交用户信息表单 然后后端进行jwt加密存储到本地 同时返回jwt给前端 之后每次请求前端在请求中携带jwt 后端用密钥解析jwt获得数据

            JWT 本身是一种无状态认证机制，适合高并发、微服务架构，避免频繁读写 Redis 或 Session 服务器，但失去了续期和服务端控制的灵活性。无状态，不依赖 Redis

          - session工作形式是 前端提交用户信息表单 后端创建session保存用户信息 并且通过Set-Cookie返回sessionid给前端 浏览器自动保存 Cookie 前端后续请求自动携带 Cookie 后端从 Cookie 中取出 sessionId 到服务器的 Session 存储中查找该 ID 对应的数据。
            
            每个浏览器都要一个session,开销大，而且需要共享session
          - redis适合分布式存储，Redis 挂了全系统挂，Redis 连接数有限、单线程瓶颈
  - 商户查询缓存
    - 为什么使用缓存
      
      - 言简意赅：速度快，好用
      缓存数据存储于代码中，而代码运行在内存中，内存的读写性能远高于磁盘，缓存可以大大降低用户访问并发量带来的服务器读写压力
      实际开发中，企业的数据量，少则几十万，多则几千万，这么大的数据量，如果没有缓存来作为避震器系统是几乎撑不住的，所以企业会大量运用缓存技术
      但是缓存也会增加代码复杂度和运营成本
      - 缓存的作用
        + 降低后端负载
        + 提高读写效率，降低响应时间
      - 缓存的成本
        + 数据一致性成本
        + 代码维护成本
        + 运维成本（一般采用服务器集群，需要多加机器，机器就是钱）
      - 实现思路
        
        如果Redis缓存里有数据，那么直接返回，如果缓存中没有，则去查询数据库，然后存入Redis
      - 缓存更新策略
        - 内存淘汰

          Redis自动进行，当Redis内存大于我们设定的max-memery时，会自动触发淘汰机制，淘汰掉一些不重要的数据（可以自己设置策略方式）
        - 超时剔除

          当我们给Redis设置了过期时间TTL之后，Redis会将超时的数据进行删除，方便我们继续使用缓存
        - 主动更新

          我们可以手动调用方法把缓存删除掉，通常用于解决缓存和数据库不一致问题
        #image("Screenshot_20250804_144231.png")
      - 数据库和缓存不一致解决方案

        由于我们的缓存数据源来自数据库，而数据库的数据是会发生变化的，因此，如果当数据库中数据发生变化，而缓存却没有同步，此时就会有一致性问题存在，其后果是

        用户使用缓存中的过时数据，就会产生类似多线程数据安全问题，从而影响业务，产品口碑等

        那么如何解决这个问题呢？有如下三种方式  
        + Cache Aside Pattern 人工编码方式：缓存调用者在更新完数据库之后再去更新缓存，也称之为双写方案
        + 缓存与数据库整合为一个服务，由服务来维护一致性。调用者调用该服务，无需关心缓存一致性问题。但是维护这样一个服务很复杂，市面上也不容易找到这样的一个现成的服务，开发成本高
        + 调用者只操作缓存，其他线程去异步处理数据库，最终实现一致性。但是维护这样的一个异步的任务很复杂，需要实时监控缓存中的数据更新，其他线程去异步更新数据库也可能不太及时，而且缓存服务器如果宕机，那么缓存的数据也就丢失了
      - 数据库和缓存不一致采用什么方案
        - 如果采用方案一，假设我们每次操作完数据库之后，都去更新一下缓存，但是如果中间并没有人查询数据，那么这个更新动作只有最后一次是有效的，中间的更新动作意义不大，所以我们可以把缓存直接删除，等到有人再次查询时，再将缓存中的数据加载出来
        - 对比删除缓存与更新缓存
          + 更新缓存：每次更新数据库都需要更新缓存，无效写操作较多
          + 删除缓存：更新数据库时让缓存失效，再次查询时更新缓存
        - 如何保证缓存与数据库的操作同时成功/同时失败
          - 单体系统：将缓存与数据库操作放在同一个事务
          - 分布式系统：利用TCC等分布式事务方案
        -  先操作缓存还是先操作数据库？
          - 先删除缓存，再操作数据库

            删除缓存的操作很快，但是更新数据库的操作相对较慢，如果此时有一个线程2刚好进来查询缓存，由于我们刚刚才删除缓存，所以线程2需要查询数据库，并写入缓存，但是我们更新数据库的操作还未完成，所以线程2查询到的数据是脏数据，出现线程安全问题   
          - 先操作数据库，再删除缓存
            
            线程1在查询缓存的时候，缓存TTL刚好失效，需要查询数据库并写入缓存，这个操作耗时相对较短（相比较于上图来说），但是就在这么短的时间内，线程2进来了，更新数据库，删除缓存，但是线程1虽然查询完了数据（更新前的旧数据），但是还没来得及写入缓存，所以线程2的更新数据库与删除缓存，并没有影响到线程1的查询旧数据，写入缓存，此时缓存中是旧数据，而数据库中是线程2插入的新数据，造成线程安全问题
          - 虽然这二者都存在线程安全问题，但是相对来说，后者窗口时间小，出现线程安全问题的概率相对较低，所以我们最终采用后者先操作数据库，再删除缓存的方案
      - 实现商铺缓存与数据库双写一致
        - 核心思路：
          + 根据id查询店铺时，如果缓存未命中，则查询数据库，并将数据库结果写入缓存，并设置TTL
          + 根据id修改店铺时，先修改数据库，再删除缓存
      - 缓存穿透
        - 缓存穿透是指客户端请求的数据在缓存中和数据库中都不存在，这样缓存永远都不会生效（只有数据库查到了，才会让redis缓存，但现在的问题是查不到），会频繁的去访问数据库。
        - 解决方案
          + 缓存空对象 
            - 优点：实现简单，维护方便
            - 缺点：额外的内存消耗，可能造成短期的不一致
            - 缓存空对象思路分析：当我们客户端访问不存在的数据时，会先请求redis，但是此时redis中也没有数据，就会直接访问数据库，但是数据库里也没有数据，那么这个数据就穿透了缓存，直击数据库。但是数据库能承载的并发不如redis这么高，所以如果大量的请求同时都来访问这个不存在的数据，那么这些请求就会访问到数据库，简单的解决方案就是哪怕这个数据在数据库里不存在，我们也把这个这个数据存在redis中去（这就是为啥说会有额外的内存消耗），这样下次用户过来访问这个不存在的数据时，redis缓存中也能找到这个数据，不用去查数据库。可能造成的短期不一致是指在空对象的存活期间，我们更新了数据库，把这个空对象变成了正常的可以访问的数据，但由于空对象的TTL还没过，所以当用户来查询的时候，查询到的还是空对象，等TTL过了之后，才能访问到正确的数据，不过这种情况很少见罢了
            - 为什么更新后还会有空对象脏数据：很多系统中只在更新/删除数据时做缓存删除，新增操作默认没有清理缓存。
          + 布隆过滤
            - 优点：内存占用少，没有多余的key
            - 缺点：实现复杂，可能存在误判
            - 布隆过滤思路分析：布隆过滤器其实采用的是哈希思想来解决这个问题，通过一个庞大的二进制数组，根据哈希思想去判断当前这个要查询的数据是否存在，如果布隆过滤器判断存在，则放行，这个请求会去访问redis，哪怕此时redis中的数据过期了，但是数据库里一定会存在这个数据，从数据库中查询到数据之后，再将其放到redis中。如果布隆过滤器判断这个数据不存在，则直接返回。这种思想的优点在于节约内存空间，但存在误判，误判的原因在于：布隆过滤器使用的是哈希思想，只要是哈希思想，都可能存在哈希冲突
      - 编码解决缓存穿透
        - 在原来的逻辑中，我们如果发现这个数据在MySQL中不存在，就直接返回一个错误信息了，但是这样存在缓存穿透问题
        - 现在的逻辑是：如果这个数据不存在，将这个数据写入到Redis中，并且将value设置为空字符串，然后设置一个较短的TTL，返回错误信息。当再次发起查询时，先去Redis中判断value是否为空字符串，如果是空字符串，则说明是刚刚我们存的不存在的数据，直接返回错误信息
      - 缓存雪崩
        - 缓存雪崩是指在同一时间段，大量缓存的key同时失效，或者Redis服务宕机，导致大量请求到达数据库，带来巨大压力
        - 解决方案：
          + 给不同的Key的TTL添加随机值，让其在不同时间段分批失效
          + 利用Redis集群提高服务的可用性（使用一个或者多个哨兵(Sentinel)实例组成的系统，对redis节点进行监控，在主节点出现故障的情况下，能将从节点中的一个升级为主节点，进行故障转义，保证系统的可用性。 ）
          + 给缓存业务添加降级限流策略
          + 给业务添加多级缓存（浏览器访问静态资源时，优先读取浏览器本地缓存；访问非静态资源（ajax查询数据）时，访问服务端；请求到达Nginx后，优先读取Nginx本地缓存；如果Nginx本地缓存未命中，则去直接查询Redis（不经过Tomcat）；如果Redis查询未命中，则查询Tomcat；请求进入Tomcat后，优先查询JVM进程缓存；如果JVM进程缓存未命中，则查询数据库）
      - 缓存击穿问题及解决思路
        - 缓存击穿也叫热点Key问题，就是一个被高并发访问并且缓存重建业务较复杂的key突然失效了，那么无数请求访问就会在瞬间给数据库带来巨大的冲击
        - 逻辑分析：假设线程1在查询缓存之后未命中，本来应该去查询数据库，重建缓存数据，完成这些之后，其他线程也就能从缓存中加载这些数据了。但是在线程1还未执行完毕时，又进来了线程2、3、4同时来访问当前方法，那么这些线程都不能从缓存中查询到数据，那么他们就会在同一时刻访问数据库，执行SQL语句查询，对数据库访问压力过大
        - 解决方案：
          + 互斥锁
            
            - 利用锁的互斥性，假设线程过来，只能一个人一个人的访问数据库，从而避免对数据库频繁访问产生过大压力，但这也会影响查询的性能，将查询的性能从并行变成了串行，我们可以采用tryLock方法+double check来解决这个问题
            - 线程1在操作的时候，拿着锁把房门锁上了，那么线程2、3、4就不能都进来操作数据库，只有1操作完了，把房门打开了，此时缓存数据也重建好了，线程2、3、4直接从redis中就可以查询到数据。

          + 逻辑过期

            - 方案分析：我们之所以会出现缓存击穿问题，主要原因是在于我们对key设置了TTL，如果我们不设置TTL，那么就不会有缓存击穿问题，但是不设置TTL，数据又会一直占用我们的内存，所以我们可以采用逻辑过期方案
            - 其实就是在写入redis的json格式的数据里加入一个过期时间（不是用redis自带的ttl），这样判断是否过期只要比较当下时间和设置时间的大小关系，而且redis存储的key也不会消失
        - 利用互斥锁解决
          - 核心思路就是利用redis的setnx方法来表示获取锁，如果redis没有这个key，则插入成功，返回1，如果已经存在这个key，则插入失败，返回0。在StringRedisTemplate中返回true/false，我们可以根据返回值来判断是否有线程成功获取到了锁
          - ```java
                 //获取互斥锁
+       boolean flag = tryLock(LOCK_SHOP_KEY + id);
+       //判断是否获取成功
+       if (!flag) {
+           //失败，则休眠并重试
+           Thread.sleep(50);
+           return queryWithMutex(id);
+       }
          ```
          - 在把数据库中的数据写入redis后再释放锁
        - 利用逻辑过期解决
          - 思路分析：
            - 当用户开始查询redis时，判断是否命中 
              - 如果没有命中则直接返回空数据，不查询数据库
              - 如果命中，则将value取出，判断value中的过期时间是否满足 
                - 如果没有过期，则直接返回redis中的数据
                - 如果过期，则在开启独立线程后，直接返回之前的数据，独立线程去重构数据，重构完成后再释放互斥锁
            - 封装数据：因为现在redis中存储的数据的value需要带上过期时间，此时要么你去修改原来的实体类，要么新建一个类包含原有的数据和过期时间
          ```java
          //这里需要声明一个线程池，因为下面我们需要新建一个现成来完成重构缓存
            private static final ExecutorService CACHE_REBUILD_EXECUTOR = Executors.newFixedThreadPool(10);

            @Override
            public Shop queryWithLogicalExpire(Long id) {
                //1. 从redis中查询商铺缓存
                String json = stringRedisTemplate.opsForValue().get(CACHE_SHOP_KEY + id);
                //2. 如果未命中，则返回空
                if (StrUtil.isBlank(json)) {
                    return null;
                }
                //3. 命中，将json反序列化为对象
                RedisData redisData = JSONUtil.toBean(json, RedisData.class);
                //3.1 将data转为Shop对象
                JSONObject shopJson = (JSONObject) redisData.getData();
                Shop shop = JSONUtil.toBean(shopJson, Shop.class);
                //3.2 获取过期时间
                LocalDateTime expireTime = redisData.getExpireTime();
                //4. 判断是否过期
                if (LocalDateTime.now().isBefore(time)) {
                    //5. 未过期，直接返回商铺信息
                    return shop;
                }
                //6. 过期，尝试获取互斥锁
                boolean flag = tryLock(LOCK_SHOP_KEY + id);
                //7. 获取到了锁
                if (flag) {
                    //8. 开启独立线程
                    CACHE_REBUILD_EXECUTOR.submit(() -> {
                        try {
                            this.saveShop2Redis(id, LOCK_SHOP_TTL);
                        } catch (Exception e) {
                            throw new RuntimeException(e);
                        } finally {
                            unlock(LOCK_SHOP_KEY + id);
                        }
                    });
                    //9. 直接返回商铺信息
                    return shop;
                }
                //10. 未获取到锁，直接返回商铺信息
                return shop;
            }

          ```
          - 重构完成前用户只能获得脏数据，因为获取锁之后的重构操作是异步执行的
          #image("Screenshot_20250804_172952.png")
  - 优惠券秒杀
    - Redis实现全局唯一ID
      - 在各类购物App中，都会遇到商家发放的优惠券
        当用户抢购商品时，生成的订单会保存到tb_voucher_order表中，而订单表如果使用数据库自增ID就会存在一些问题 
        + id规律性太明显
        + 受单表数据量的限制
      - 全局id生成器
        - 全局ID生成器是一种在分布式系统下用来生成全局唯一ID的工具，一般要满足以下特性
          - 唯一性
          - 高可用
          - 高性能
          - 递增性
          - 安全性
        - 为了增加ID的安全性，我们可以不直接使用Redis自增的数值，而是拼接一些其他信息
        - ID组成部分 
          - 符号位：1bit，永远为0
          - 时间戳：31bit，以秒为单位，可以使用69年（2^31秒约等于69年）
          - 序列号：32bit，秒内的计数器，支持每秒传输2^32个不同ID
    - 添加优惠券
      - 平价券由于优惠力度并不是很大，所以是可以任意领取
      - 而代金券由于优惠力度大，所以像第二种券，就得限制数量，从表结构上也能看出，特价券除了具有优惠券的基本信息以外，还具有库存，抢购时间，结束时间等等字段
      - 秒杀券可以看做是一种特殊的普通券，将普通券信息保存到普通券表中，同时将秒杀券的数据保存到秒杀券表中，通过券的ID进行关联
    - 实现秒杀下单
      - 流程
        + 提交优惠券id,查询优惠券信息
        + 判断秒杀时间是否开始
        + 判断是否有库存
        + 有库存删除一个库存
        + 创建订单
        + 无库存返回错误信息
        + 没开始返回错误信息
      - 超卖问题
        - 假设现在只剩下一张优惠券，线程1过来查询库存，判断库存数大于1，但还没来得及去扣减库存，此时库线程2也过来查询库存，发现库存数也大于1，那么这两个线程都会进行扣减库存操作，最终相当于是多个线程都进行了扣减库存，那么此时就会出现超卖问题
        - 超卖问题是典型的多线程安全问题，针对这一问题的常见解决方案就是加锁：而对于加锁，我们通常有两种解决方案 
          + 悲观锁
            - 悲观锁认为线程安全问题一定会发生，因此在操作数据之前先获取锁，确保线程串行执行
            - 例如Synchronized、Lock等，都是悲观锁
            - 悲观锁可以实现对于数据的串行化执行，比如syn，和lock都是悲观锁的代表，同时，悲观锁中又可以再细分为公平锁，非公平锁，可重入锁，等等

          + 乐观锁
            - 乐观锁认为线程安全问题不一定会发生，因此不加锁，只是在更新数据的时候再去判断有没有其他线程对数据进行了修改 
            - 如果没有修改，则认为自己是安全的，自己才可以更新数据
            - 如果已经被其他线程修改，则说明发生了安全问题，此时可以重试或者异常
            - 乐观锁会有一个版本号，每次操作数据会对版本号+1，再提交回数据时，会去校验是否比之前的版本大1 ，如果大1 ，则进行操作成功，这套机制的核心逻辑在于，如果在操作过程中，版本号只比原来大1 ，那么就意味着操作过程中没有人对他进行过修改，他的操作就是安全的，如果不大1，则数据被修改过，当然乐观锁还有一些变种的处理方式比如CAS
            - 乐观锁的典型代表：就是CAS(Compare-And-Swap)，利用CAS进行无锁化机制加锁，var5 是操作前读取的内存值，while中的var1+var2 是预估值，如果预估值 == 内存值，则代表中间没有被人修改过，此时就将新值去替换 内存值
            ```java
            //5. 扣减库存
              boolean success = seckillVoucherService.update()
            .setSql("stock = stock - 1")
            .eq("voucher_id", voucherId)
            .eq("stock",seckillVoucher.getStock())
            .update();
            ```
            - 这里的eq("stock",seckillVoucher.getStock())实现了乐观锁，用库存当作版本号
            - 但是，只要我扣减库存时的库存和之前我查询到的库存是一样的，就意味着没有人在中间修改过库存，那么此时就是安全的，但是以上这种方式通过测试发现会有很多失败的情况，失败的原因在于：在使用乐观锁过程中假设100个线程同时都拿到了100的库存，然后大家一起去进行扣减，但是100个人中只有1个人能扣减成功，其他的人在处理时，他们在扣减时，库存已经被修改过了，所以此时其他线程都会失败
            - 那么我们继续完善代码，修改我们的逻辑，在这种场景，我们可以只判断是否有剩余优惠券，即只要数据库中的库存大于0，都能顺利完成扣减库存操作
             ```java 
                //5. 扣减库存
              boolean success = seckillVoucherService.update()
            .setSql("stock = stock - 1")
            .eq("voucher_id", voucherId)
            .eq("stock",seckillVoucher.getStock())
            .gt("stock", 0)
            .update();
             ```
             - 一人一单
               - 具体操作逻辑如下：我们在判断库存是否充足之后，根据我们保存的订单数据，判断用户订单是否已存在 
               - 存在问题：如果这个用户故意开多线程抢优惠券，那么在判断库存充足之后，执行一人一单逻辑之前，在这个区间如果进来了多个线程，还是可以抢多张优惠券的，那我们这里使用悲观锁来解决这个问题
               - 但是这样加锁，锁的细粒度太粗了，在使用锁的过程中，控制锁粒度是一个非常重要的事情，因为如果锁的粒度太大，会导致每个线程进来都会被锁住，现在的情况就是所有用户都公用这一把锁，串行执行，效率很低，我们现在要完成的业务是一人一单，所以这个锁，应该只加在单个用户上，用户标识可以用userId
               ```java 
                // 一人一单逻辑
                 Long userId = UserHolder.getUser().getId();
                 synchronized (userId.toString().intern()) {
                  int count = query().eq("voucher_id", voucherId).eq("user_id", userId).count();
                  if (count > 0) {
                      return Result.fail("你已经抢过优惠券了哦");
                  }
               ```
             - 由于toString的源码是new String，new是在堆中，所以如果我们只用userId.toString()拿到的也不是同一个用户，需要使用intern()，如果字符串常量池中已经包含了一个等于这个string对象的字符串（由equals（object）方法确定），那么将返回池中的字符串。否则，将此String对象添加到池中，并返回对此String对象的引用。
             - 但是以上代码还是存在问题，问题的原因在于当前方法被Spring的事务控制，如果你在内部加锁，可能会导致当前方法事务还没有提交，但是锁已经释放了，这样也会导致问题，所以我们选择将当前方法整体包裹起来，确保事务不会出现问题
             #image("Screenshot_20250804_221248.png")
             - 但是以上做法依然有问题，因为你调用的方法，其实是this.的方式调用的，事务想要生效，还得利用代理来生效，所以这个地方，我们需要获得原始的事务对象， 来操作事务，这里可以使用AopContext.currentProxy()来获取当前对象的代理对象，然后再用代理对象调用方法，记得要去IVoucherOrderService中创建createVoucherOrder方法
             ```java
             Long userId = UserHolder.getUser().getId();
            synchronized (userId.toString().intern()) {
                IVoucherOrderService proxy = (IVoucherOrderService) AopContext.currentProxy();
                return proxy.createVoucherOrder(voucherId);
              } 
             ```
             - 但是该方法会用到一个aspectjweaver依赖，我们需要导入一下
             
             - 同时在启动类上加上EnableAspectJAutoProxy(exposeProxy = true)注解
        - 集群环境下的并发问题
          - 由于我们部署了多个Tomcat，每个Tomcat都有一个属于自己的jvm，那么假设在服务器A的Tomcat内部，有两个线程，即线程1和线程2，这两个线程使用的是同一份代码，那么他们的锁对象是同一个，是可以实现互斥的。但是如果在另一个Tomcat的内部，又有两个线程，但是他们的锁对象虽然写的和服务器A一样，但是锁对象却不是同一个，所以线程3和线程4可以实现互斥，但是却无法和线程1和线程2互斥
          - 这就是集群环境下，syn锁失效的原因，在这种情况下，我们需要使用分布式锁来解决这个问题，让锁不存在于每个jvm的内部，而是让所有jvm公用外部的一把锁（Redis）
  
- 分布式锁    
  - 定义：满足分布式系统或集群模式下多线程课件并且可以互斥的锁
  - 分布式锁的核心思想就是让大家共用同一把锁，那么我们就能锁住线程，不让线程进行，让程序串行执行，这就是分布式锁的核心思路
  - 分布式锁满足的条件
    - 可见性：多个线程都能看到相同的结果。
      
      注意：这里说的可见性并不是并发编程中指的内存可见性，只是说多个进程之间都能感知到变化的意思
    -  互斥：互斥是分布式锁的最基本条件，使得程序串行执行
    - 高可用：程序不易崩溃，时时刻刻都保证较高的可用性
    - 高性能：由于加锁本身就让性能降低，所以对于分布式锁需要他较高的加锁性能和释放锁性能
    - 安全性：安全也是程序中必不可少的一环
  - 常见的分布式锁
    + MySQL：MySQL本身就带有锁机制，但是由于MySQL的性能一般，所以采用分布式锁的情况下，使用MySQL作为分布式锁比较少见
    + Redis：Redis作为分布式锁是非常常见的一种使用方式，现在企业级开发中基本都是用Redis或者Zookeeper作为分布式锁，利用SETNX这个方法，如果插入Key成功，则表示获得到了锁，如果有人插入成功，那么其他人就回插入失败，无法获取到锁，利用这套逻辑完成互斥，从而实现分布式锁
    + Zookeeper：Zookeeper也是企业级开发中较好的一种实现分布式锁的方案，但本文是学Redis的，所以这里就不过多阐述了
    #image("Screenshot_20250805_145922.png")
  - Redis分布式锁的实现核心思路
    + 获取锁 
      - 互斥：确保只能有一个线程获取锁
      - 非阻塞：尝试一次，成功返回true，失败返回false
    + 释放锁
      - 手动释放
      - 超时释放：获取锁的时候添加一个超时时间
    + 核心思路

    我们利用redis的SETNX方法，当有多个线程进入时，我们就利用该方法来获取锁。第一个线程进入时，redis 中就有这个key了，返回了1，如果结果是1，则表示他抢到了锁，那么他去执行业务，然后再删除锁，退出锁逻辑，没有抢到锁（返回了0）的线程，等待一定时间之后重试
  - Redis分布式锁误删情况
    - 逻辑说明

      持有锁的线程1在锁的内部出现了阻塞，导致他的锁TTL到期，自动释放

      此时线程2也来尝试获取锁，由于线程1已经释放了锁，所以线程2可以拿到

      但是现在线程1阻塞完了，继续往下执行，要开始释放锁了
      
      那么此时就会将属于线程2的锁释放，这就是误删别人锁的情况
    - 解决方案
      
      解决方案就是在每个线程释放锁的时候，都判断一下这个锁是不是自己的，如果不属于自己，则不进行删除操作。

      假设还是上面的情况，线程1阻塞，锁自动释放，线程2进入到锁的内部执行逻辑，此时线程1阻塞完了，继续往下执行，开始删除锁，但是线程1发现这把锁不是自己的，所以不进行删除锁的逻辑，当线程2执行到删除锁的逻辑时，如果TTL还未到期，则判断当前这把锁是自己的，于是删除这把锁
  - 解决Redis分布式锁误删问题
    - 在获取锁的时候存入线程标识（用UUID标识，在一个JVM中，ThreadId一般不会重复，但是我们现在是集群模式，有多个JVM，多个JVM之间可能会出现ThreadId重复的情况），在释放锁的时候先获取锁的线程标识，判断是否与当前线程标识一致 
  - 分布式锁的原子性问题
    - 为极端的误删逻辑说明

      假设线程1已经获取了锁，在判断标识一致之后，准备释放锁的时候，又出现了阻塞（例如JVM垃圾回收机制）

      于是锁的TTL到期了，自动释放了

      那么现在线程2趁虚而入，拿到了一把锁

      但是线程1的逻辑还没执行完，那么线程1就会执行删除锁的逻辑

      但是在阻塞前线程1已经判断了标识一致，所以现在线程1把线程2的锁给删了

      那么就相当于判断标识那行代码没有起到作用

      这就是删锁时的原子性问题

      因为线程1的拿锁，判断标识，删锁，不是原子操作，所以我们要防止刚刚的情况
    - Lua脚本解决多条命令原子性问题
      
      - Redis提供了Lua脚本功能，在一个脚本中编写多条Redis命令，确保多条命令执行时的原子性。
      - 如果脚本中的key和value不想写死，可以作为参数传递，key类型参数会放入KEYS数组，其他参数会放入ARGV数组，在脚本中可以从KEYS和ARGV数组中获取这些参数。在Lua中，数组下标从1开始
      #image("Screenshot_20250805_152159.png")
      #image("Screenshot_20250805_152223.png")
    - 利用java代码调用Lua脚本改造分布式锁
      ```java
            private static final DefaultRedisScript<Long> UNLOCK_SCRIPT;

      static {
          UNLOCK_SCRIPT = new DefaultRedisScript();
          UNLOCK_SCRIPT.setLocation(new ClassPathResource("unlock.lua"));
          UNLOCK_SCRIPT.setResultType(Long.class);
      }

      @Override
      public void unlock() {
          stringRedisTemplate.execute(UNLOCK_SCRIPT,
                  Collections.singletonList(KEY_PREFIX + name),
                  ID_PREFIX + Thread.currentThread().getId());
      }

      ```
   
- 分布式锁-Redisson
  - 基于SETNX实现的分布式锁存在以下问题 
    + 重入问题
      
      重入问题是指获取锁的线程，可以再次进入到相同的锁的代码块中，可重入锁的意义在于防止死锁，例如在HashTable这样的代码中，它的方法都是使用synchronized修饰的，加入它在一个方法内调用另一个方法，如果此时是不可重入的，那就死锁了。所以可重入锁的主要意义是防止死锁，我们的synchronized和Lock锁都是可重入的
    + 不可重试 
      
      我们编写的分布式锁只能尝试一次，失败了就返回false，没有重试机制。但合理的情况应该是：当线程获取锁失败后，他应该能再次尝试获取锁
    + 超时释放 
      
      我们在加锁的时候增加了TTL，这样我们可以防止死锁，但是如果卡顿(阻塞)时间太长，也会导致锁的释放，因此也有多个线程拿到同一把锁的情况
    + 主从一致性
      
      如果Redis提供了主从集群，那么当我们向集群写数据时，主机需要异步的将数据同步给从机，万一在同步之前，主机宕机了(主从同步存在延迟，虽然时间很短，但还是发生了)，那么就会选取从节点作为新节点，但是新节点没有锁，就会导致多个线程都拿到锁
  - 什么是redisson
    
    Redisson是一个在Redis的基础上实现的Java驻内存数据网格(In-Memory Data Grid)。它不仅提供了一系列的分布式Java常用对象，还提供了许多分布式服务，其中就包含了各种分布式锁的实现
  - Redis提供了分布式锁的多种功能
    
    + 可重入锁
    + 公平锁
    + 联锁
    + 红锁
    + 读写锁
    + 信号量
    + 可过期性信号量
    + 闭锁
  - Redisson入门
    - 导入依赖
    - 在config包下新建redissonconfig类
    - 用Rlock接受redissonclient自带的api函数getlock的返回类型

  - Redisson可重入锁原理
    - 在lock锁中，借助于voalitile的一个state变量来记录重入状态
      - 如果当前没有人持有这把锁，那么state = 0
      - 如果有人持有这把锁，那么state = 1
        - 如果持有者把锁的人再次持有这把锁，那么state会+1
      - 如果对于synchronize而言，他在c语言代码中会有一个count
      - 原理与state类似，也是重入一次就+1，释放一次就-1，直至减到0，表示这把锁没有被人持有
    - 在redisson中，我们也支持可重入锁
      - 在分布式锁中，它采用hash结构来存储锁，其中外层key表示这把锁是否存在，内层key则记录当前这把锁被哪个线程持有

       method1在方法内部调用method2，method1和method2出于同一个线程，那么method1已经拿到一把锁了，想进入method2中拿另外一把锁，必然是拿不到的，于是就出现了死锁
      - 所以我们需要额外判断，method1和method2是否处于同一线程，如果是同一个线程，则可以拿到锁，但是state会+1，之后执行method2中的方法，释放锁，释放锁的时候也只是将state进行-1，只有减至0，才会真正释放锁
       由于我们需要额外存储一个state，所以用字符串型SET NX EX是不行的，需要用到Hash结构，但是Hash结构又没有NX这种方法，所以我们需要将原有的逻辑拆开，进行手动判断
      - 为了保证原子性，所以流程图中的业务逻辑也是需要我们用Lua来实现的 
      - 获取锁
      ```java 
                local key = KEYS[1]; -- 锁的key
          local threadId = ARGV[1]; -- 线程唯一标识
          local releaseTime = ARGV[2]; -- 锁的自动释放时间
          -- 锁不存在
          if (redis.call('exists', key) == 0) then
              -- 获取锁并添加线程标识，state设为1
              redis.call('hset', key, threadId, '1');
              -- 设置锁有效期
              redis.call('expire', key, releaseTime);
              return 1; -- 返回结果
          end;
          -- 锁存在，判断threadId是否为自己
          if (redis.call('hexists', key, threadId) == 1) then
              -- 锁存在，重入次数 +1，这里用的是hash结构的incrby增长
              redis.call('hincrby', key, thread, 1);
              -- 设置锁的有效期
              redis.call('expire', key, releaseTime);
              return 1; -- 返回结果
          end;
          return 0; -- 代码走到这里，说明获取锁的不是自己，获取锁失败

      ```
      - 删除锁
      ```java 
              local key = KEYS[1];
        local threadId = ARGV[1];
        local releaseTime = ARGV[2];
        -- 如果锁不是自己的
        if (redis.call('HEXISTS', key, threadId) == 0) then
            return nil; -- 直接返回
        end;
        -- 锁是自己的，锁计数-1，还是用hincrby，不过自增长的值为-1
        local count = redis.call('hincrby', key, threadId, -1);
        -- 判断重入次数为多少
        if (count > 0) then
            -- 大于0，重置有效期
            redis.call('expire', key, releaseTime);
            return nil;
        else
            -- 否则直接释放锁
            redis.call('del', key);
            return nil;
        end;

      ```
      - 因为 Lua 脚本在 Redis 内部是串行、原子执行的，不会并发。
  - Redisson锁重试和WatchDog机制
    - 如果没有指定释放时间时间，则指定默认释放时间为getLockWatchdogTimeout，底层源码显示是30*1000ms，也就是30秒
      ```java
          public boolean tryLock(long waitTime, long leaseTime, TimeUnit unit) throws InterruptedException {
            long time = unit.toMillis(waitTime);
            long current = System.currentTimeMillis();
            long threadId = Thread.currentThread().getId();
            Long ttl = this.tryAcquire(waitTime, leaseTime, unit, threadId);
            //判断ttl是否为null
            if (ttl == null) {
                return true;
            } else {
                //计算当前时间与获取锁时间的差值，让等待时间减去这个值
                time -= System.currentTimeMillis() - current;
                //如果消耗时间太长了，直接返回false，获取锁失败
                if (time <= 0L) {
                    this.acquireFailed(waitTime, unit, threadId);
                    return false;
                } else {
                    //等待时间还有剩余，再次获取当前时间
                    current = System.currentTimeMillis();
                    //订阅别人释放锁的信号
                    RFuture<RedissonLockEntry> subscribeFuture = this.subscribe(threadId);
                    //在剩余时间内，等待这个信号
                    if (!subscribeFuture.await(time, TimeUnit.MILLISECONDS)) {
                        if (!subscribeFuture.cancel(false)) {
                            subscribeFuture.onComplete((res, e) -> {
                                if (e == null) {
                                    //取消订阅
                                    this.unsubscribe(subscribeFuture, threadId);
                                }

                            });
                        }
                        //剩余时间内没等到，返回false
                        this.acquireFailed(waitTime, unit, threadId);
                        return false;
                    } else {
                        try {
                            //如果剩余时间内等到了别人释放锁的信号，再次计算当前剩余最大等待时间
                            time -= System.currentTimeMillis() - current;
                            if (time <= 0L) {
                                //如果剩余时间为负数，则直接返回false
                                this.acquireFailed(waitTime, unit, threadId);
                                boolean var20 = false;
                                return var20;
                            } else {
                                boolean var16;
                                do {
                                    //如果剩余时间等到了，dowhile循环重试获取锁
                                    long currentTime = System.currentTimeMillis();
                                    ttl = this.tryAcquire(waitTime, leaseTime, unit, threadId);
                                    if (ttl == null) {
                                        var16 = true;
                                        return var16;
                                    }

                                    time -= System.currentTimeMillis() - currentTime;
                                    if (time <= 0L) {
                                        this.acquireFailed(waitTime, unit, threadId);
                                        var16 = false;
                                        return var16;
                                    }

                                    currentTime = System.currentTimeMillis();
                                    if (ttl >= 0L && ttl < time) {
                                        ((RedissonLockEntry)subscribeFuture.getNow()).getLatch().tryAcquire(ttl, TimeUnit.MILLISECONDS);
                                    } else {
                                        ((RedissonLockEntry)subscribeFuture.getNow()).getLatch().tryAcquire(time, TimeUnit.MILLISECONDS);
                                    }

                                    time -= System.currentTimeMillis() - currentTime;
                                } while(time > 0L);

                                this.acquireFailed(waitTime, unit, threadId);
                                var16 = false;
                                return var16;
                            }
                        } finally {
                            this.unsubscribe(subscribeFuture, threadId);
                        }
                    }
                }
            }
        }

      ```
      - 这里其他函数都可以看一下源码 不做过多记录

  - Redisson锁的Mutilock原理
    
    - 为了提高Redis的可用性，我们会搭建集群或者主从，现在以主从为例

    - 此时我们去写命令，写在主机上，主机会将数据同步给从机，但是假设主机还没来得及把数据写入到从机去的时候，主机宕机了

    - 哨兵会发现主机宕机了，于是选举一个slave(从机)变成master(主机)，而此时新的master(主机)上并没有锁的信息，那么其他线程就可以获取锁，又会引发安全问题

    - 为了解决这个问题。Redisson提出来了MutiLock锁，使用这把锁的话，那我们就不用主从了，每个节点的地位都是一样的，都可以当做是主机，那我们就需要将加锁的逻辑写入到每一个主从节点上，只有所有的服务器都写入成功，此时才是加锁成功，假设现在某个节点挂了，那么他去获取锁的时候，只要有一个节点拿不到，都不能算是加锁成功，就保证了加锁的可靠性
    
    - 这里深入了解一下联锁的源码，也不做过多记录
  - 小结
    #image("Screenshot_20250805_170316.png")
- 秒杀优化
  - 当用户发起请求，此时会先请求Nginx，Nginx反向代理到Tomcat，而Tomcat中的程序，会进行串行操作，分为如下几个步骤
    + 查询优惠券
    + 判断秒杀库存是否足够
    + 查询订单
    + 校验是否一人一单
    + 扣减库存
    + 创建订单
  - 在这六个步骤中，有很多操作都是要去操作数据库的，而且还是一个线程串行执行，这样就会导致我们的程序执行很慢，所以我们需要异步程序执行，那么如何加速呢？
  - 优化方案：我们将耗时较短的逻辑判断放到Redis中，例如：库存是否充足，是否一人一单这样的操作，只要满足这两条操作，那我们是一定可以下单成功的，不用等数据真的写进数据库，我们直接告诉用户下单成功就好了。然后后台再开一个线程，后台线程再去慢慢执行队列里的消息，这样我们就能很快的完成下单业务。
  - 但是这里还存在两个难点：
    + 怎么在Redis中快速校验是否一人一单，还有库存判断
    + 校验一人一单和将下单数据写入数据库，这是两个线程，我们怎么知道下单是否完成。 
  - 我们现在来看整体思路：当用户下单之后，判断库存是否充足，只需要取Redis中根据key找对应的value是否大于0即可，如果不充足，则直接结束。如果充足，则在Redis中判断用户是否可以下单，如果set集合中没有该用户的下单数据，则可以下单，并将userId和优惠券存入到Redis中，并且返回0，整个过程需要保证是原子性的，所以我们要用Lua来操作，同时由于我们需要在Redis中查询优惠券信息，所以在我们新增秒杀优惠券的同时，需要将优惠券信息保存到Redis中

    完成以上逻辑判断时，我们只需要判断当前Redis中的返回值是否为0，如果是0，则表示可以下单，将信息保存到queue中去，然后返回，开一个线程来异步下单，可以通过返回订单的id来判断是否下单成功
  - Redis完成秒杀资格判断
    - 需求
      + 新增秒杀优惠券的同时，将优惠券信息保存到Redis中
      + 基于Lua脚本，判断秒杀库存、一人一单，决定用户是否秒杀成功
      - 修改保存优惠券相关代码
      ```java 
              @Override
        @Transactional
        public void addSeckillVoucher(Voucher voucher) {
            // 保存优惠券
            save(voucher);
            // 保存秒杀信息
            SeckillVoucher seckillVoucher = new SeckillVoucher();
            seckillVoucher.setVoucherId(voucher.getId());
            seckillVoucher.setStock(voucher.getStock());
            seckillVoucher.setBeginTime(voucher.getBeginTime());
            seckillVoucher.setEndTime(voucher.getEndTime());
            seckillVoucherService.save(seckillVoucher);
            // 保存秒杀优惠券信息到Reids，Key名中包含优惠券ID，Value为优惠券的剩余数量
            stringRedisTemplate.opsForValue().set(SECKILL_STOCK_KEY + voucher.getId(), voucher.getStock().toString()); 
        }

      ```

      添加成功后，数据库中和Redis中都能看到优惠券信息
      - 编写Lua脚本
      ```java
              -- 订单id
        local voucherId = ARGV[1]
        -- 用户id
        local userId = ARGV[2]
        -- 优惠券key
        local stockKey = 'seckill:stock:' .. voucherId
        -- 订单key
        local orderKey = 'seckill:order:' .. voucherId
        -- 判断库存是否充足
        if (tonumber(redis.call('get', stockKey)) <= 0) then
            return 1
        end
        -- 判断用户是否下单
        if (redis.call('sismember', orderKey, userId) == 1) then
            return 2
        end
        -- 扣减库存
        redis.call('incrby', stockKey, -1)
        -- 将userId存入当前优惠券的set集合
        redis.call('sadd', orderKey, userId)
        return 0

      ```
      ```java 
            -- 订单id
      local voucherId = ARGV[1]
      -- 用户id
      local userId = ARGV[2]
      -- 优惠券key
      local stockKey = 'seckill:stock:' .. voucherId
      -- 订单key
      local orderKey = 'seckill:order:' .. voucherId
      -- 判断库存是否充足
      if (tonumber(redis.call('get', stockKey)) <= 0) then
          return 1
      end
      -- 判断用户是否下单
      if (redis.call('sismember', orderKey, userId) == 1) then
          return 2
      end
      -- 扣减库存
      redis.call('incrby', stockKey, -1)
      -- 将userId存入当前优惠券的set集合
      redis.call('sadd', orderKey, userId)
      return 0
      ```
   - 基于阻塞队列实现秒杀优化
     - 需求
       + 如果秒杀成功，则将优惠券id和用户id封装后存入阻塞队列
       + 开启线程任务，不断从阻塞队列中获取信息，实现异步下单功能
     - 创建阻塞队列
       - 阻塞队列有一个特点：当一个线程尝试从阻塞队列里获取元素的时候，如果没有元素，那么该线程就会被阻塞，直到队列中有元素，才会被唤醒，并去获取元素
       - 阻塞队列的创建需要指定一个大小
       ```java
       private final BlockingQueue<VoucherOrder> orderTasks = new ArrayBlockingQueue<>(1024 * 1024);
       ```
       - 那么把优惠券id和用户id封装后存入阻塞队列
       ```java
              @Override
        public Result seckillVoucher(Long voucherId) {
            Long result = stringRedisTemplate.execute(SECKILL_SCRIPT,
                    Collections.emptyList(), voucherId.toString(),
                    UserHolder.getUser().getId().toString());
            if (result.intValue() != 0) {
                return Result.fail(result.intValue() == 1 ? "库存不足" : "不能重复下单");
            }
            long orderId = redisIdWorker.nextId("order");
            //封装到voucherOrder中
            VoucherOrder voucherOrder = new VoucherOrder();
            voucherOrder.setVoucherId(voucherId);
            voucherOrder.setUserId(UserHolder.getUser().getId());
            voucherOrder.setId(orderId);
            //加入到阻塞队列
            orderTasks.add(voucherOrder);
            return Result.ok(orderId);
        }
        ```
      - 实现异步下单功能 
        - 先创建一个线程池
        ```java
        private static final ExecutorService SECKILL_ORDER_EXECUTOR = Executors.newSingleThreadExecutor();
        ```
        - 创建线程任务，秒杀业务需要在类初始化之后，就立即执行，所以这里需要用到PostConstruct注解
        ```java 
                @PostConstruct
        private void init() {
            SECKILL_ORDER_EXECUTOR.submit(new VoucherOrderHandler());
        }

        private class VoucherOrderHandler implements Runnable {
            @Override
            public void run() {
                while (true) {
                    try {
                        //1. 获取队列中的订单信息
                        VoucherOrder voucherOrder = orderTasks.take();
                        //2. 创建订单
                        handleVoucherOrder(voucherOrder);
                    } catch (Exception e) {
                        log.error("订单处理异常", e);
                    }
                }
            }
        }

        ```
        - PostConstruct 是 Java 中一个注解，常用于 Spring 框架，用来修饰一个方法，在 依赖注入完成后、在构造方法执行之后 自动执行一次。
        - 编写创建订单的业务逻辑
        - 完整代码如下
        ```java 
                  package com.hmdp.service.impl;

          import com.hmdp.dto.Result;
          import com.hmdp.entity.VoucherOrder;
          import com.hmdp.mapper.VoucherOrderMapper;
          import com.hmdp.service.ISeckillVoucherService;
          import com.hmdp.service.IVoucherOrderService;
          import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
          import com.hmdp.utils.RedisIdWorker;
          import com.hmdp.utils.UserHolder;
          import lombok.extern.slf4j.Slf4j;
          import org.redisson.api.RLock;
          import org.redisson.api.RedissonClient;
          import org.springframework.aop.framework.AopContext;
          import org.springframework.beans.factory.annotation.Autowired;
          import org.springframework.core.io.ClassPathResource;
          import org.springframework.data.redis.core.StringRedisTemplate;
          import org.springframework.data.redis.core.script.DefaultRedisScript;
          import org.springframework.stereotype.Service;
          import org.springframework.transaction.annotation.Transactional;

          import javax.annotation.PostConstruct;
          import javax.annotation.Resource;
          import java.util.Collections;
          import java.util.concurrent.ArrayBlockingQueue;
          import java.util.concurrent.BlockingQueue;
          import java.util.concurrent.ExecutorService;
          import java.util.concurrent.Executors;

          /**
           * <p>
           * 服务实现类
           * </p>
           *
           * @author Kyle
           * @since 2022-10-22
           */
          @Service
          @Slf4j
          public class VoucherOrderServiceImpl extends ServiceImpl<VoucherOrderMapper, VoucherOrder> implements IVoucherOrderService {

              @Autowired
              private ISeckillVoucherService seckillVoucherService;

              @Autowired
              private RedisIdWorker redisIdWorker;

              @Resource
              private StringRedisTemplate stringRedisTemplate;

              @Resource
              private RedissonClient redissonClient;

              private IVoucherOrderService proxy;


              private static final DefaultRedisScript<Long> SECKILL_SCRIPT;

              static {
                  SECKILL_SCRIPT = new DefaultRedisScript();
                  SECKILL_SCRIPT.setLocation(new ClassPathResource("seckill.lua"));
                  SECKILL_SCRIPT.setResultType(Long.class);
              }

              private static final ExecutorService SECKILL_ORDER_EXECUTOR = Executors.newSingleThreadExecutor();

              @PostConstruct
              private void init() {
                  SECKILL_ORDER_EXECUTOR.submit(new VoucherOrderHandler());
              }

              private final BlockingQueue<VoucherOrder> orderTasks = new ArrayBlockingQueue<>(1024 * 1024);

              private void handleVoucherOrder(VoucherOrder voucherOrder) {
                  //1. 获取用户
                  Long userId = voucherOrder.getUserId();
                  //2. 创建锁对象，作为兜底方案
                  RLock redisLock = redissonClient.getLock("order:" + userId);
                  //3. 获取锁
                  boolean isLock = redisLock.tryLock();
                  //4. 判断是否获取锁成功 
                  if (!isLock) {
                      log.error("不允许重复下单!");
                      return;
                  }
                  try {
                      //5. 使用代理对象，由于这里是另外一个线程，
                      proxy.createVoucherOrder(voucherOrder);
                  } finally {
                      redisLock.unlock();
                  }
              }

              private class VoucherOrderHandler implements Runnable {
                  @Override
                  public void run() {
                      while (true) {
                          try {
                              //1. 获取队列中的订单信息
                              VoucherOrder voucherOrder = orderTasks.take();
                              //2. 创建订单
                              handleVoucherOrder(voucherOrder);
                          } catch (Exception e) {
                              log.error("订单处理异常", e);
                          }
                      }
                  }
              }

              @Override
              public Result seckillVoucher(Long voucherId) {
                  Long result = stringRedisTemplate.execute(SECKILL_SCRIPT,
                          Collections.emptyList(), voucherId.toString(),
                          UserHolder.getUser().getId().toString());
                  if (result.intValue() != 0) {
                      return Result.fail(result.intValue() == 1 ? "库存不足" : "不能重复下单");
                  }
                  long orderId = redisIdWorker.nextId("order");
                  //封装到voucherOrder中
                  VoucherOrder voucherOrder = new VoucherOrder();
                  voucherOrder.setVoucherId(voucherId);
                  voucherOrder.setUserId(UserHolder.getUser().getId());
                  voucherOrder.setId(orderId);
                  //加入到阻塞队列
                  orderTasks.add(voucherOrder);
                  //主线程获取代理对象
                  proxy = (IVoucherOrderService) AopContext.currentProxy();
                  return Result.ok(orderId);
              }


              @Transactional
              public void createVoucherOrder(VoucherOrder voucherOrder) {
                  // 一人一单逻辑
                  Long userId = voucherOrder.getUserId();
                  Long voucherId = voucherOrder.getVoucherId();
                  synchronized (userId.toString().intern()) {
                      int count = query().eq("voucher_id", voucherId).eq("user_id", userId).count();
                      if (count > 0) {
                          log.error("你已经抢过优惠券了哦");
                          return;
                      }
                      //5. 扣减库存
                      boolean success = seckillVoucherService.update()
                              .setSql("stock = stock - 1")
                              .eq("voucher_id", voucherId)
                              .gt("stock", 0)
                              .update();
                      if (!success) {
                          log.error("库存不足");
                      }
                      //7. 将订单数据保存到表中
                      save(voucherOrder);
                  }
              }
          }

        ```
        - 个人猜测：这里proxy的赋值应该在加入阻塞队列前会严谨一些，因为有可能程序走到了 proxy.createVoucherOrder(voucherOrder);而proxy还未赋值
      - 秒杀业务总结
        #image("Screenshot_20250805_214504.png")
        对于数据安全问题：
        - 如果刚好一个任务进来，异步从阻塞队列里取出一个任务执行，此时服务宕机，任务就丢失了。
        - 基于内存保存，如果阻塞队列里还有订单，这时如果服务宕机，信息全都丢失
- Redis消息队列
  - 什么是消息队列？字面意思就是存放消息的队列，最简单的消息队列模型包括3个角色 
    + 消息队列：存储和管理消息，也被称为消息代理（Message Broker）
    + 生产者：发送消息到消息队列
    + 消费者：从消息队列获取消息并处理消息
  - 使用队列的好处在于解耦：举个例子，快递员(生产者)把快递放到驿站/快递柜里去(Message Queue)去，我们(消费者)从快递柜/驿站去拿快递，这就是一个异步，如果耦合，那么快递员必须亲自上楼把快递递到你手里，服务当然好，但是万一我不在家，快递员就得一直等我，浪费了快递员的时间。所以解耦还是非常有必要的
  - 那么在这种场景下我们的秒杀就变成了：在我们下单之后，利用Redis去进行校验下单的结果，然后在通过队列把消息发送出去，然后在启动一个线程去拿到这个消息，完成解耦，同时也加快我们的响应速度
  - 这里我们可以直接使用一些现成的(MQ)消息队列，如kafka，rabbitmq等，但是如果没有安装MQ，我们也可以使用Redis提供的MQ方案
  - 基于List实现消息队列  
    - 消息队列(Message Queue)，字面意思就是存放消息的队列，而Redis的list数据结构是一个双向链表，很容易模拟出队列的效果
    - 队列的入口和出口不在同一边，所以我们可以利用：LPUSH结合RPOP或者RPUSH结合LPOP来实现消息队列。
    - 不过需要注意的是，当队列中没有消息时，RPOP和LPOP操作会返回NULL，而不像JVM阻塞队列那样会阻塞，并等待消息，所以我们这里应该使用BRPOP或者BLPOP来实现阻塞效果。Brpop和rpop的区别就在于阻塞，而且brpop支持多个key,也就是多个列表同时弹出
    - 基于List的消息队列有哪些优缺点？
      - 优点：
        + 利用Redis存储，不受限于JVM内存上限
        + 基于Redis的持久化机制，数据安全性有保障
        + 可以满足消息有序性
      - 缺点：
        + 无法避免消息丢失(经典服务器宕机)
        + 只支持单消费者(一个消费者把消息拿走了，其他消费者就看不到这条消息了)
    - 基于pubsub的消息队列
      - PubSub(发布订阅)是Redis2.0版本引入的消息传递模型。顾名思义，消费和可以订阅一个或多个channel，生产者向对应channel发送消息后，所有订阅者都能收到相关消息，通过订阅不一样channel来区分收到不同信息
      - 基于PubSub的消息队列有哪些优缺点 
        - 优点：
          + 采用发布订阅模型，支持多生产，多消费
        - 缺点： 
          + 不支持数据持久化
          + 无法避免消息丢失（如果向频道发送了消息，却没有人订阅该频道，那发送的这条消息就丢失了）
          + 消息堆积有上限，超出时数据丢失（消费者拿到数据的时候处理的太慢，而发送消息发的太快）
    - 基于stream的消息队列
      - 注意：当我们指定其实ID为\$时，代表只能读取到最新消息，如果当我们在处理一条消息的过程中，又有超过1条以上的消息到达队列，那么下次获取的时候，也只能获取到最新的一条，会出现漏读消息的问题
      - STREAM类型消息队列的XREAD命令特点 
        + 消息可回溯
        + 一个消息可以被多个消费者读取
        + 可以阻塞读取
        + 有漏读消息的风险
    - 基于stream的消费队列 - 消费者组
      - 消费者组(Consumer Group)：将多个消费者划分到一个组中，监听同一个队列，具备以下特点 
        + 消息分流 ： 队列中的消息会分流给组内的不同消费者，而不是重复消费者，从而加快消息处理的速度
        + 消息标识 ： 消费者会维护一个标识，记录最后一个被处理的消息，哪怕消费者宕机重启，还会从标识之后读取消息，确保每一个消息都会被消费
        + 消息确认 ： 消费者获取消息后，消息处于pending状态，并存入一个pending-list，当处理完成后，需要通过XACK来确认消息，标记消息为已处理，才会从pending-list中移除（Redis 是内存数据库，Stream 的数据默认存在内存中。如果开启了AOF和RDB,Redis 会将 Stream 的数据、消费者组信息、消费进度等写入磁盘，实现持久化。）
        - STREAM类型消息队列的XREADGROUP命令的特点 
          + 消息可回溯
          + 可以多消费者争抢消息，加快消费速度
          + 可以阻塞读取
          + 没有消息漏读风险
          + 有消息确认机制，保证消息至少被消费一次
        #image("Screenshot_20250806_152622.png")
    - Stream消息队列实现异步秒杀下单
      - 需求
        + 创建一个Stream类型的消息队列，名为stream.orders
        + 修改之前的秒杀下单Lua脚本，在认定有抢购资格后，直接向stream.orders中添加消息，内容包含voucherId、userId、orderId
        + 项目启动时，开启一个线程任务，尝试获取stream.orders中的消息，完成下单
      - #image("Screenshot_20250806_153252.png")
      - 因此取出来也是这样的类似json格式，所以需要转换对象。而且因为是count 1 所以只需要get（0），如果count 2,就能拿到两条信息，需要get（0）和get（1）
      - 消费者组必须创建，消费者若没创建xreadgroup会自动创建
      ```java 
              String queueName = "stream.orders";

        private class VoucherOrderHandler implements Runnable {

            @Override
            public void run() {
                while (true) {
                    try {
                        //1. 获取队列中的订单信息 XREADGROUP GROUP g1 c1 COUNT 1 BLOCK 2000 STREAMS stream.orders >
                        List<MapRecord<String, Object, Object>> records = stringRedisTemplate.opsForStream().read(Consumer.from("g1", "c1"),
                                StreamReadOptions.empty().count(1).block(Duration.ofSeconds(2)),
                                //ReadOffset.lastConsumed()底层就是 '>'
                                StreamOffset.create(queueName, ReadOffset.lastConsumed()));
                        //2. 判断消息是否获取成功
                        if (records == null || records.isEmpty()) {
                            continue;
                        }
                        //3. 消息获取成功之后，我们需要将其转为对象
                        MapRecord<String, Object, Object> record = records.get(0);
                        Map<Object, Object> values = record.getValue();
                        VoucherOrder voucherOrder = BeanUtil.fillBeanWithMap(values, new VoucherOrder(), true);
                        //4. 获取成功，执行下单逻辑，将数据保存到数据库中
                        handleVoucherOrder(voucherOrder);
                        //5. 手动ACK，SACK stream.orders g1 id
                        stringRedisTemplate.opsForStream().acknowledge(queueName, "g1", record.getId());
                    } catch (Exception e) {
                        log.error("订单处理异常", e);
                        //订单异常的处理方式我们封装成一个函数，避免代码太臃肿
                        handlePendingList();
                    }
                }
            }
        }

        private void handlePendingList() {
            while (true) {
                try {
                    //1. 获取pending-list中的订单信息 XREADGROUP GROUP g1 c1 COUNT 1 BLOCK 2000 STREAMS stream.orders 0
                    List<MapRecord<String, Object, Object>> records = stringRedisTemplate.opsForStream().read(
                            Consumer.from("g1", "c1"),
                            StreamReadOptions.empty().count(1),
                            StreamOffset.create(queueName, ReadOffset.from("0")));
                    //2. 判断pending-list中是否有未处理消息
                    if (records == null || records.isEmpty()) {
                        //如果没有就说明没有异常消息，直接结束循环
                        break;
                    }
                    //3. 消息获取成功之后，我们需要将其转为对象
                    MapRecord<String, Object, Object> record = records.get(0);
                    Map<Object, Object> values = record.getValue();
                    VoucherOrder voucherOrder = BeanUtil.fillBeanWithMap(values, new VoucherOrder(), true);
                    //4. 获取成功，执行下单逻辑，将数据保存到数据库中
                    handleVoucherOrder(voucherOrder);
                    //5. 手动ACK，SACK stream.orders g1 id
                    stringRedisTemplate.opsForStream().acknowledge(queueName, "g1", record.getId());
                } catch (Exception e) {
                    log.info("处理pending-list异常");
                    //如果怕异常多次出现，可以在这里休眠一会儿
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException ex) {
                        throw new RuntimeException(ex);
                    }
                }
            }
        }
        ```   
- 达人探店
  - 发布探店笔记
    - 对应的实体类，数据表中并没有用户头像和用户昵称，但是对应的实体类里却有，这是因为使用了\@TableField(exist = false) 用来解决实体类中有的属性但是数据表中没有的字段
  - 查看探店笔记
  - 点赞功能
    - 修改点赞功能，利用Redis中的set集合来判断是否点赞过，未点赞则点赞数+1，已点赞则点赞数-1
    - 如果当前用户未点赞，则点赞数 +1，同时将用户加入set集合
    - 如果当前用户已点赞，则点赞-1，将用户从set集合中移除
    - 修改完毕之后，页面上还不能立即显示点赞完毕的后果，因为上面的步骤只是修改redis中的数据，我们还需要修改查询Blog业务，判断Blog是否被当前用户点赞过
  - 点赞排行榜
    #image("Screenshot_20250806_221646.png")
    - 这里使用sortedSet按点赞顺序排序，其实就是把zset中的元素取出来它们的id,然后用id拿到数据库去查，并让sql按照我们查到的数据去返回。因为redis的zset返回的是按点赞顺序的，但是sql语句查询出来的不是。`select * from tb_user where id in (ids[0], ids[1] ...) order by field(id, ids[0], ids[1] ...)`
    - 同时我们需要修改BlogServiceImpl

      由于ZSet没有isMember方法，所以这里只能通过查询score来判断集合中是否有该元素，如果有该元素，则返回值是对应的score，如果没有该元素，则返回值为null
    - 同时修改isBlogLiked方法，在原有逻辑上，判断用户是否已登录，登录状态下才会继续判断用户是否点赞
  - 好友关注
    - 关注和取消关注
    - 共同关注
      - 实现方式当然是我们之前学过的set集合，在set集合中，有交集并集补集的api，可以把二者关注的人放入到set集合中，然后通过api查询两个set集合的交集
      - 那我们就得先修改我们之前的关注逻辑，在关注博主的同时，需要将数据放到set集合中，方便后期我们实现共同关注，当取消关注时，也需要将数据从set集合中删除
      - 对当前用户和博主用户的关注列表取交集，将结果转为list，之后根据ids去查询共同关注的用户，封装成UserDto再返回
    - Feed流
      - 关注了用户之后，这个用户发布了动态，那我们应该把这些数据推送给用户，这个需求，我们又称其为Feed流，关注推送也叫作Feed流，直译为投喂，为用户提供沉浸式体验，通过无限下拉刷新获取新的信息
      - 对于传统的模式内容检索：用户需要主动通过搜索引擎或者是其他方式去查找想看的内容
      - 对于新型Feed流的效果：系统分析用户到底想看什么，然后直接把内容推送给用户，从而使用户能更加节约时间，不用去主动搜素
      - Feed流的实现有两种模式 
        + Timeline：不做内容筛选，简单的按照内容发布时间排序，常用于好友或关注(B站关注的up，朋友圈等) 
          - 优点：信息全面，不会有缺失，并且实现也相对简单
          - 缺点：信息噪音较多，用户不一定感兴趣，内容获取效率低
        + 智能排序：利用智能算法屏蔽掉违规的、用户不感兴趣的内容，推送用户感兴趣的信息来吸引用户 
          - 优点：投喂用户感兴趣的信息，用户粘度很高，容易沉迷
          - 缺点：如果算法不精准，可能会起到反作用（给你推的你都不爱看）
        - 采用Timeline模式，有三种具体的实现方案 
          + 拉模式：也叫读扩散 
            - 该模式的核心含义是：当张三和李四、王五发了消息之后，都会保存到自己的发件箱中，如果赵六要读取消息，那么他会读取他自己的收件箱，此时系统会从他关注的人群中，将他关注人的信息全都进行拉取，然后进行排序
            - 优点：比较节约空间，因为赵六在读取信息时，并没有重复读取，并且读取完之后，可以将他的收件箱清除
            - 缺点：有延迟，当用户读取数据时，才会去关注的人的时发件箱中拉取信息，假设该用户关注了海量用户，那么此时就会拉取很多信息，对服务器压力巨大
          + 推模式：也叫写扩散
            - 推模式是没有写邮箱的，当张三写了一个内容，此时会主动把张三写的内容发送到它粉丝的收件箱中，假设此时李四再来读取，就不用再去临时拉取了
            - 优点：时效快，不用临时拉取
            - 缺点：内存压力大，假设一个大V发了一个动态，很多人关注他，那么就会写很多份数据到粉丝那边去
          + 推拉结合：页脚读写混合，兼具推和拉两种模式的优点
            - 推拉模式是一个折中的方案，站在发件人这一边，如果是普通人，那么我们采用写扩散的方式，直接把数据写入到他的粉丝收件箱中，因为普通人的粉丝数量较少，所以这样不会产生太大压力。但如果是大V，那么他是直接将数据写入一份到发件箱中去，在直接写一份到活跃粉丝的收件箱中，站在收件人这边来看，如果是活跃粉丝，那么大V和普通人发的都会写到自己的收件箱里，但如果是普通粉丝，由于上线不是很频繁，所以等他们上线的时候，再从发件箱中去拉取信息。
        - feed流的分页模式
          - 假设在t1时刻，我们取读取第一页，此时page = 1，size = 5，那么我们拿到的就是10~6这几条记录，假设t2时刻有发布了一条新纪录，那么在t3时刻，我们来读取第二页，此时page = 2，size = 5，那么此时读取的数据是从6开始的，读到的是6~2，那么我们就读到了重复的数据，所以我们要使用Feed流的分页，不能使用传统的分页
          - 滚动分页：
            我们需要记录每次操作的最后一条，然后从这个位置去开始读数据

            举个例子：我们从t1时刻开始，拿到第一页数据，拿到了10~6，然后记录下当前最后一次读取的记录，就是6，t2时刻发布了新纪录，此时这个11在最上面，但不会影响我们之前拿到的6，此时t3时刻来读取第二页，第二页读数据的时候，从6-1=5开始读，这样就拿到了5~1的记录。我们在这个地方可以使用SortedSet来做，使用时间戳来充当表中的1~10
          - 实现分页查询收件箱：
            + 每次查询完成之后，我们要分析出查询出的最小时间戳，这个值会作为下一次的查询条件
            + 我们需要找到与上一次查询相同的查询个数，并作为偏移量，下次查询的时候，跳过这些查询过的数据，拿到我们需要的数据（例如时间戳8 6 6 5 5 4，我们每次查询3个，第一次是8 6 6，此时最小时间戳是6，如果不设置偏移量，会从第一个6之后开始查询，那么查询到的就是6 5 5，而不是5 5 4，如果这里说的不清楚，那就看后续的代码）
            - 综上：我们的请求参数中需要携带lastId和offset，即上一次查询时的最小时间戳和偏移量，这两个参数。分页查询的思路其实就是每次记录最后的那个时间戳，然后记录相同时间戳在上一次查了有多少个（设为n），下次查的时候就直接用这个时间戳开始往后数n个开始查
- 附近商户
  - Redis在3.2版本中加入了对GEO的支持，允许存储地理坐标信息
  - GEODIST 命令在计算距离时会假设地球为完美的球形， 在极限情况下， 这⼀假设最⼤会造成 0.5% 的误差
    - 返回值：计算出的距离会以双精度浮点数的形式被返回。 如果给定的位置元素不存在， 那么命令返回空值
  - 具体实现思路就是将商铺所在位置存入redis, 查询redis、按照距离排序、分页; 结果：shopId、distance

    GEOSEARCH key FROMLONLAT x y BYRADIUS 5000 m WITHDIST

    如果不需要根据距离查询就直接返回shop,如果需要就查出来距离后放入shop的list中再返回
- 签到功能
  - 我们可以把年和月作为BitMap的key，然后保存到一个BitMap中，每次签到就把对应位上的0变成1，只要是1就说明这一天已经签到了，反之则没有签到
  - BitMap底层是基于String数据结构，因此其操作也都封装在字符串相关操作中
  #image("Screenshot_20250807_095731.png")
  -  获取截止至今日的签到记录  BITFIELD key GET uDay 0
- UV统计
  - UV：全称Unique Visitor，也叫独立访客量，是指通过互联网访问、浏览这个网页的自然人。1天内同一个用户多次访问该网站，只记录1次。
  - PV：全称Page View，也叫页面访问量或点击量，用户每访问网站的一个页面，记录1次PV，用户多次打开页面，则记录多次PV。往往用来衡量网站的流量。
  - UV统计在服务端做会很麻烦，因为要判断该用户是否已经统计过了，需要将统计过的信息保存，但是如果每个访问的用户都保存到Redis中，那么数据库会非常恐怖，那么该如何处理呢？
  - HyperLogLog(HLL)是从Loglog算法派生的概率算法，用户确定非常大的集合基数，而不需要存储其所有值
  - Redis中的HLL是基于string结构实现的，单个HLL的内存永远小于16kb，内存占用低的令人发指！作为代价，其测量结果是概率性的，有小于0.81％的误差。不过对于UV统计来说，这完全可以忽略。
  






