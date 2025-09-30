- TransmittableThreadLocal
  - Java 中的 ThreadLocal 是线程局部变量，保证每个线程拥有独立的副本。它的问题在于：
    - 只能在同一个线程中访问。
    - 线程池/异步任务 中无法自动传递
    ```java
        ThreadPoolExecutor executor = ...;
    ThreadLocal<String> tl = new ThreadLocal<>();
    tl.set("Hello");

    executor.submit(() -> {
        System.out.println(tl.get()); // 输出 null
    });
 
    ```
    - 因为任务可能在 线程池的其他线程 中执行，ThreadLocal 不会继承父线程的值。TTL 诞生的目的是解决 线程池、异步任务中 ThreadLocal 无法传递的问题。
  - TransmittableThreadLocal 是阿里开源的一个类,继承自 InheritableThreadLocal,InheritableThreadLocal 可以让子线程继承父线程的值，但仅限 线程创建时，线程池重用线程时不会重新继承。ttl解决了这个问题，它提交任务时，捕获当前父线程的值快照。在工作线程执行任务前，注入当前父线程的快照。无论线程池复用多少次，父线程的上下文都会被正确透传。
    ```java
        InheritableThreadLocal<String> itl = new InheritableThreadLocal<>();

    itl.set("父线程初始值");

    Thread t = new Thread(() -> {
        System.out.println("子线程第一次：" + itl.get()); // 输出：父线程初始值
    });
    t.start();

    // 父线程修改值
    itl.set("父线程新值");

    Thread t2 = new Thread(() -> {
        System.out.println("子线程第二次：" + itl.get()); // 输出：父线程新值
    });
    t2.start();

 
    ```
  - 增强了线程池适配能力：
    - TTL 可以通过 包装 Runnable 或 Callable 来在提交任务时拷贝父线程上下文。
    - 通过 TtlRunnable 和 TtlCallable 完成上下文传递。
  ```java
      TransmittableThreadLocal<String> ttl = new TransmittableThreadLocal<>();
    ttl.set("parentValue");

    new Thread(() -> {
        System.out.println(ttl.get()); // 输出 parentValue
    }).start();
 
  ```
  #image("Screenshot_20250920_125552.png")
- RequiredArgsConstructor注解：生成带 final 字段 的构造函数。
- 实现Filter接口可以作为 Servlet 过滤器拦截请求。在请求到达 Controller 前，进行流量控制。
  - doFilter 是拦截器核心方法：
    - 在请求到达 Controller 之前执行。
    - 可以决定 是否继续执行链条 或 直接返回响应。
- 构造redis脚本对象
  ```java
    DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
  redisScript.setScriptSource(new ResourceScriptSource(new ClassPathResource(USER_FLOW_RISK_CONTROL_LUA_SCRIPT_PATH)));
  redisScript.setResultType(Long.class);
 
  ```
  - 使用 Spring Data Redis 提供的 DefaultRedisScript 执行 Lua 脚本。
  - 结果类型为 Long，因为脚本返回的是访问次数计数。
  - ClassPathResource：从 classpath 加载脚本文件。
  - 执行lua脚本
  ```java
  result = stringRedisTemplate.execute(redisScript, Lists.newArrayList(username), userFlowRiskControlConfiguration.getTimeWindow());
  
  ```
  - KEYS[1] → username，ARGV[1] → 时间窗口
  - userflowRiskcontrolConfiguration   
    ```java
        @Data
    @Component
    @ConfigurationProperties(prefix = "short-link.flow-limit")
    public class UserFlowRiskControlConfiguration {

        /**
         * 是否开启用户流量风控验证
         */
        private Boolean enable;

        /**
         * 流量风控时间窗口，单位：秒
         */
        private String timeWindow;

        /**
         * 流量风控时间窗口内可访问次数
         */
        private Long maxAccessCount;
    }  
    ```
    - 统计某用户在 过去 timeWindow 秒 内的请求次数。
      - 如果请求次数超过 maxAccessCount，拒绝访问（返回流控错误）。
      - 否则计数加 1，允许请求通过。
      - 作用：
        - 防止短时间内大量请求（刷接口）
          - 用户或攻击者可能通过短时间连续发送请求，占用系统资源。
          - 如果不限制：
            - 数据库压力急剧增加 → 慢查询、锁竞争。
            - 缓存压力增加 → Redis、Memcached 高负载。
            - Web 服务器线程耗尽 → 可能导致整个服务不可用。
        - 防止分布式攻击（DDoS/洪泛攻击）
          - 限流是 第一道防护墙：
            - 即使攻击者通过多台机器或 IP 发起洪泛请求，每个请求也会受到限流控制。
          - 保护后端服务：
        -  保护业务公平性
          - 对于资源有限的接口或功能（比如抢购、秒杀、抽奖等），需要保证 每个用户公平访问。
          - 限流可以防止某些用户 短时间内占用全部资源。
        - 控制系统资源消耗
          - 用户短时间频繁请求：
            - CPU、内存、IO 消耗急剧上升。
            - 后端可能出现 线程池耗尽 或 队列堆积。
          - 通过 timeWindow + maxAccessCount 限制：
            - 每秒只允许一定请求量。
            - 系统可保持稳定负载。
      - lua脚本 
        ```java
              -- 设置用户访问频率限制的参数
      local username = KEYS[1]
      local timeWindow = tonumber(ARGV[1]) -- 时间窗口，单位：秒

      -- 构造 Redis 中存储用户访问次数的键名
      local accessKey = "short-link:user-flow-risk-control:" .. username

      -- 原子递增访问次数，并获取递增后的值
      local currentAccessCount = redis.call("INCR", accessKey)

      -- 设置键的过期时间
      if currentAccessCount == 1 then
          redis.call("EXPIRE", accessKey, timeWindow)
      end

      -- 返回当前访问次数
      return currentAccessCount 
        ```
      - 为什么要用lua脚本
        - 假设用 Java 分两步操作：
          ```java
            Long count = stringRedisTemplate.opsForValue().increment(accessKey, 1);
            stringRedisTemplate.expire(accessKey, timeWindow, TimeUnit.SECONDS);
 
          ```
          - 在高并发下，线程A,B都执行INCR，和EXPIRE，会出现计数和过期可能不同步。限流逻辑可能被破坏。
          - 减少网络请求
            - 如果 Java 分多条命令，每条命令都需要 一次网络请求，高并发下压力大。Lua 脚本一次发送给 Redis，一次执行完成所有逻辑，减少网络往返，提高性能。
          - 高并发限流必须精准
            - 限流关键是 时间窗口内访问次数不能超过 maxAccessCount。
            - 如果用 Java 多条命令执行，可能出现 两个请求同时计数但都没超过 maxAccessCount → 超过限制也没被阻止。
- sneakyThrows
  - 作用：SneakyThrows 让你不用写 try/catch，方法签名也不用 throws，编译器不会报错。
  -风险：异常仍然会在运行时抛出，但编译器和调用者看不到这些异常，可能导致 运行时错误不易被发现。
-  filterChain.doFilter(servletRequest, servletResponse);
  - filterChain 表示 当前请求对应的过滤器链，由所有注册的 Filter 按顺序组成。
  - doFilter 的作用是 把请求传递给下一个过滤器，或者如果已经是最后一个过滤器，就把请求交给最终的 Servlet / Controller 处理。
  - 如果代码有多个过滤器，就需要调用该函数放行至下一个过滤器，否则请求就会被拦截在该过滤器中
  #image("Screenshot_20250920_134225.png")
  #image("Screenshot_20250920_134244.png")
- mybatis-plus的自动填充机制
  #image("Screenshot_20250920_134621.png")
  #image("Screenshot_20250920_134652.png")
- DesensitizedUtil.mobilePhone(phone)
  - 使用 Hutool 提供的手机号脱敏工具
  - 将原始手机号转换成脱敏形式，例如：13812345678 → 138\*\*\*\*5678
  - 只需在字段上添加 \@JsonSerialize(using = PhoneDesensitizationSerializer.class)，返回 JSON 时自动脱敏
- \@RestControllerAdvice
  - Spring 全局异常处理器，等同于 \@ControllerAdvice + \@ResponseBody
  - 作用：拦截 Controller 层抛出的异常 并返回 JSON
  - 就是定义一个全局异常处理类，对每种异常捕获后单独处理，将原来的异常报错抛出或显示HTML页面转换成向前端返回JSON信息
- mybatis-plus的分页查询插件
  ```java
      @Bean
    @ConditionalOnMissingBean
    public MybatisPlusInterceptor mybatisPlusInterceptorByAdmin() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
 ```
 - 方法返回 interceptor，Spring 会将其注册到容器
 - MyBatis-Plus 在执行 SQL 时，会自动使用该分页拦截器处理分页查询
 - #image("Screenshot_20250920_141141.png")
 - \@ConditionalOnMissingBean仅当 Spring 容器中 没有同类型 Bean 时才注册,避免重复注册拦截器
 - 微服务调用链信息传递
   ```java
      @Configuration
    public class OpenFeignConfiguration {

        @Bean
        public RequestInterceptor requestInterceptor() {
            return template -> {
                template.header("username", UserContext.getUsername());
                template.header("userId", UserContext.getUserId());
                template.header("realName", UserContext.getRealName());
            };
        }
    } 
   ```
   - Feign 不会去主动“抓” ThreadLocal，拦截器帮你把 ThreadLocal 的值写进 header，Spring Cloud OpenFeign 会自动读取 RequestInterceptor 设置的 header，并把它们加到 HTTP 请求中发送给下游服务。
- 布隆过滤器
  - 布隆过滤器是一种 空间和时间都高效的概率型数据结构，用于判断某个元素是否在一个集合中：
    - 可能存在 → 返回 true（存在或者误判）
    - 一定不存在 → 返回 false
  - 优点：占用空间小，查询速度快
  - 缺点：允许 少量误判，但不会漏掉真实存在的元素
  - 核心原理
    - 布隆过滤器用 位数组 + 多个哈希函数 实现：
      - 初始化
        - 创建一个长度为 m 的 bit 位数组，初始全部为 0
        - 准备 k 个不同的哈希函数
      - 添加元素
        #image("Screenshot_20250920_143515.png")
      - 判断元素是否存在
        - 因为检查对应位可能有10011和00011类似的第一第二位相同的问题，存在误判可能
  - 系统根据你设定的误判率和预估元素量，自动计算位数组和哈希函数
  - 误判率越低 → 占用空间越大
  - 永远不会漏判真实存在的元素
  - 太少的哈希函数 → 冗余不够，误判率高
  - 太多的哈希函数 → 冲突增加，误判率反而升高
  - 降低误判率的更主要手段
    - 增加 bit 数组长度 m → 占用更多空间
    - 调整哈希函数数量 k → 接近最优 k_opt
  - 如何设置合理参数
    #image("Screenshot_20250920_144121.png")
    #image("Screenshot_20250920_144144.png")
- 为什么要单独写一个 UserConfiguration 配置类来注册 UserFlowRiskControlFilter（和 UserTransmitFilter），而不是直接把 UserFlowRiskControlFilter 本身加 \@Component 或直接注入 Spring Bean。
  #image("Screenshot_20250920_150041.png")
  - UserConfiguration 这个 \@Configuration 类只是 在 Spring 启动时注册两个 Filter Bean：
  - 后续每个用户请求：
    - 请求到达 Servlet 容器
    - 容器按照注册顺序调用 Filter 的 doFilter() 方法
    - UserTransmitFilter 提取请求头的用户信息放到 UserContext
    - UserFlowRiskControlFilter 调用 Redis + Lua 脚本进行流量限制
- 新增短链分组
  - 前端传送分组名称到后端controller
  - service携带着传送分组名称并从threadlocal中取出当前线程username，将username和分组名称写入数据库
  - 写入前，要先用Redisson分布式锁加锁，保证同一用户创建分组时不会出现并发写冲突（比如同时创建两个分组，超出最大分组数或 gid 冲突）。
    - 假设场景1,当前分组数为最大分组数-1,并且同时有A,B两个线程进入创建分组，A和B同时创建并判断MAXCOUNT大于当前分组数于是都能进入创建分组的逻辑，导致AB线程结束后当前分组数为最大分组数+1,出现问题
    - 假设场景2,两个线程同时生成gid,此时布隆过滤器和数据库中都不存在gidX，但是两个线程同时生成gid时都生成了gidX,但是由于数据库对gid的唯一性约束，只有一个线程能写入，第二个线程失败，用Redisson锁降低冲突的概率
    - 假设场景3
    #image("Screenshot_20250921_164645.png")
    - 布隆过滤器和数据库不是原子操作。在并发下，虽然代码是先插入数据库再写布隆过滤器，但线程切换可能让其他线程 在布隆过滤器还没写入时就查询它。。这就是所谓的 “状态不一致”：数据库里已经有了，但缓存/布隆过滤器里还没写入。加锁后线程 B 必须等线程 A 完成数据库 + 布隆过滤器写入后才能执行
  - 加锁后，查询数据库中未删除的数据并计算这些数据的分组数和是否大于最大分组数
    - 在这里采用软删除的方法处理删除的数据，即用一个flag字段标记数据删除或未删除
      - 保留历史数据
      - 数据审计，del_flag + deleted_at 可以追踪谁删除了、什么时候删除的
      - 统计和分析，某些统计可能需要包含已删除的数据（例如活跃用户数、操作日志等），直接删除会丢失统计基础
      - 避免外键约束问题，假设分组有其他关联表，如果直接删除可能违反外键约束，标记删除比物理删除安全，避免级联删除带来的副作用
  - 若超出最大分组数则返回错误信息，若没有则继续新增分组逻辑
  - 在新增分组逻辑中，采用重试的方法生成gid，插入数据库和布隆过滤器缓存
    - 生成retryCount和maxRetries两个变量通过while循环限制重试次数，若retryCount到达maxRetries说明达到最大重试次数，返回错误信息
    - 若没有则进入生成gid逻辑
      - 生成gid逻辑采用随机生成，使用SecureRandom，加密学安全的随机数生成器
      - 生成完gid后，先在布隆过滤器进行判断，过滤掉有明显冲突的gid
        - 若布隆过滤器识别到冲突就返回null,while循环识别到null就进行重试
        - 若没识别到冲突就进行下一步插入数据库逻辑
          - 将gid插入uniquegid数据库中，该数据库给gid设置了唯一性校验，这次校验是一定能检测出gid的冲突的，前面加过滤器是为了去除一些明显的冲突提高效率，避免所有请求都打到数据库
          - 唯一性校验完就返回
    - 外层拿到gid和username,分组名进行拼接成类，插入到数据库中，并将gid插入布隆过滤器中
- 查询短链分组
  - mybatis-plus构造查询条件和语句
  - 本地数据库查到gid和name
  - 从远程服务查到gid和countShortLinks
    - 远程服务调用类写在Service层
      - service 类有 GetMapping / PostMapping
        - 这是 Spring Cloud OpenFeign 的用法。
        - FeignClient 注解告诉 Spring：这个接口不是普通的 Service，而是一个 远程服务的客户端代理。
        - 接口里的 GetMapping、PostMapping 并不是本地实现，而是 声明远程服务的 HTTP API 路径。
          - 为什么没有实现还能调用？
            - 因为 Feign 在运行时帮你生成了实现类。
              - Spring 启动时会扫描带有 FeignClient 的接口。
              - Feign 框架会基于这些接口 动态生成代理类
              - 当你调用接口方法时，代理类会把调用转化成 HTTP 请求，然后把响应结果反序列化为 Result\<T> 返回。
              - 真正的实现在中台服务中，中台服务写完函数实现会上传到远程，然后本地只需要声明feign，并写好与中台服务相同名称的接口，即可直接调用远程服务的方法，spring会自动扫描FeignClient 注解。生成动态代理对象。
                - 有注册中心：Feign 根据服务名找地址，自动负载均衡，服务实例动态扩缩容也能适配。
                  - 注册中心就是注册多个服务，请求打入时就可以通过负载均衡选择服务
                - 没有注册中心：需要手写 url，所有调用都打到这个地址，没法动态发现服务。
  - 两者结果根据gid拼接返回
    #image("Screenshot_20250921_172202.png")

- 修改分组名称
  - 直接update修改
- 删除分组
  - 软删除
    - 将FLAG修改为1
- 排序分组
  - 前端拖拽分组改变order传给后端
  - 后端遍历请求参数 requestParam，对每个分组找到对应记录。更新该分组的 sortOrder 值。
  - 前端本身就有完整数据，拖拽时前端直接修改order就行，即使服务器挂了也可以成功显示
    - 传到后端的原因是，保证下一次用户打开和上一次一样，也就是持久化存储
    - 因为当浏览器关闭后前端缓存就失效了，就要从数据库重新查
- 注册 
  - Transactional(rollbackFor = Exception.class)声明这是一个事务方法，如果执行过程中抛出 Exception（及其子类），事务会回滚，保证数据一致性。注册过程涉及 UserDO 插入和 GroupDO 插入（默认分组），必须保证原子性。
  - 基于 Redisson 分布式锁，锁的 key = 用户名。如果两个并发请求同时注册相同用户名，只有一个能加锁成功，另一个直接失败。
  - 把用户名加入布隆过滤器。快速判断用户名是否存在，减少 DB 压力，避免缓存穿透。
- 修改
  - 通过if判断本地username和参数username是否相同避免用户修改其他用户信息
  - 虽然前端看不到别的用户信息，主要是为了防止接口修改
- 登陆
  - 先查询数据库中是否存在该用户
  - 在Redis检查是否登陆
    - 其实就是用key去获得entry，若不为空说明已登陆则刷新token的过期时间
  - 避免重复生成新token,保持会话持续有效
  - 若是首次登陆
    - 生成唯一ID UUID
    - 将 token 和用户信息存入 Redis hash
    - 设置过期时间 30 分钟。
    - 返回token给前端
- excel表格生成
  - 设置响应类型和编码 → 告诉浏览器这是 Excel 文件。
  - 编码文件名 → 避免中文/空格乱码。
  - 设置 Content-Disposition → 让浏览器弹出下载窗口。
  - EasyExcel 写数据到输出流 → 数据直接流向浏览器，无需临时文件。
- 微服务网关统一token认证
  - 白名单内请求直接放行。
  - 非白名单请求：
    - 取 username 和 token 去 Redis 验证。
      - 验证成功：
        - 把用户信息写入请求头，下游服务可以直接使用。
        - 放行请求。
      - 验证失败：
        - 返回 401 JSON。
  #image("Screenshot_20250921_213937.png")
- SynchronousQueue（不存储任务，提交任务必须有空闲线程，否则丢弃旧任务）
  - 使用该队列的意义
    - 不做本地排队：让 Redis 承担消息堆积，而不是 Java 内存队列。
    - 保证实时消费：消费者忙时，不会再接收新任务，避免 OOM。
    - 契合单线程模型：既然只有一个线程，多余任务排队没有意义。
- 自定义线程工厂
  - 守护线程
    - 与普通（用户）线程的最大区别：JVM 在判断是否结束时只看“是否还有非守护线程活着”。
    - 典型用途：后台监控、日志刷新、定期清理等“可丢弃”的辅助任务。
    - 守护线程不会阻止 JVM 退出：只要最后一个非守护线程结束，JVM 会开始终止，守护线程会被 abruptly 停止（不会等待其完成）。
    - JVM 关闭时会执行已注册的 shutdown hooks（钩子），但守护线程的工作不被保证完成。
- redisstream
  -  Redis Stream 本身保证消息可靠存储：Redis Stream 是持久化的：消息存储在 Redis 中，消费者组会维护一个消费进度（offset）。只要消费者没 ACK（确认消费），消息就会一直存在于 pending list。如果消费者挂掉，消息仍然在 Redis 里，等恢复后可以继续消费。这和 Kafka、RabbitMQ 类似，本质上是 拉取式队列 + 消费者组。
- 利用string的setnx机制设置消息状态
  - 所以就是利用setnx只能set相同数据一次的特性，来判断消息是否正在被消费，然后通过让不同消息id作为key,set他们的value为0或1,若为0就是正在消费中，若为1就是消费完成，因为setnx的特性，即使多次消费请求打入也只是一次，保证幂等性，删除key就是去除幂等性标识
    #image("Screenshot_20250923_163948.png")
- 何时调用string的setnx机制
  - shortLinkStatsSaveConsumer实现了onmessage方法
  - listenerContainer.register(...)：把 shortLinkStatsSaveConsumer（也就是 StreamListener 实现类）注册进来。
  - listenerContainer.start()：启动后台线程，不断从 Redis Stream 拉取消息。
  - 每当有消息到达时，容器就会调用你写的 onMessage 方法，并把消息对象（MapRecord）传进去。
  - 如：
    - 生产者（比如另一个服务）调用：stringRedisTemplate.opsForStream().add(topic, map);把一条消息写入 Redis Stream。
    - StreamMessageListenerContainer 后台线程在 轮询 Redis Stream，拿到消息。
    - 框架把这条消息封装成 MapRecord\<String, String, String>，然后回调：shortLinkStatsSaveConsumer.onMessage(record);
- 流消息读取请求
  - 需要给定参数
    - 我要消费哪个 Stream（主题）
    - 我属于哪个消费组，指定消费者
      - 若有多个消费者，则会自动负载均衡，采用点对点模型，一条消息只会被 一个消费者 处理。
      - 若还有不同消费组
        - 广播（Pub/Sub）模型
        - 一条消息会被 所有订阅者 消费。对应到 Redis Stream，就是 不同消费组。
        - 消费者组的意义
          - 水平扩展（组内负载均衡）
            - 一个消费组内可以有多个消费者实例（比如多台服务或多线程）。
            - 消息在组内被分配给不同消费者，同一条消息只会给组内一个消费者处理。
            - 解决了单消费者处理能力不足的问题。
          - 隔离消费逻辑（组间独立）
            - 不同消费组可以针对同一条消息执行不同业务逻辑。
            - groupA：记录统计日志
            - groupB：更新缓存
            - groupC：触发通知系统
            - 每个组消费同一条消息，但互不干扰。
          - 重试与消费确认独立
            - 每个消费组维护自己的 Pending List 和 offset。
            - 一个组的消费者挂了，不会影响其他组的消费进度。
    - 我是否要自动确认（ack）消息
    - 遇到错误要不要停掉监听
- 消息监听容器
  - 参数
    - 设置一次拉取信息数量
    - 设置处理信息的线程池
    - 如果没有拉取到消息，阻塞等待的时间
  - 为什么短链接项目只用一个线程
   #image("Screenshot_20250923_171636.png")
- 获取短链接
  - 需要加读锁，用于保证多线程读操作的安全，避免在并发统计时出现冲突（例如同时更新数据库计数）
  - 查询短链接对应的 GID
  - 把一条短链接访问记录 拆解成多张统计表更新
  #image("Screenshot_20250923_173022.png")
- 总体流程概括
  - 前端用户点击短链接 → 浏览器获取用户信息（IP、设备、浏览器、系统等）将这些信息封装成 ShortLinkStatsRecordDTO 发给后端
  - 后端写入 Redis Stream
    - 配置 Stream：
      - 主题（Topic）：如 SHORT_LINK_STATS_STREAM_TOPIC_KEY
      - 消费组（Consumer Group）：如 SHORT_LINK_STATS_STREAM_GROUP_KEY
      - 消费者名称（Consumer Name）
    - 通过 Redis Stream 保证消息顺序、可靠传递
  -  消息队列监听器配置
    - 使用 StreamMessageListenerContainer 创建监听器
    - 配置：
      - 自定义 线程池（目前只有一个线程）
      - 拉取批量消息数量（batchSize）
      - 阻塞时间（pollTimeout）
      - 重试/错误策略 (cancelOnError)
  -  消息幂等性处理
    - MessageQueueIdempotentHandler：利用 Redis 的 setIfAbsent
  - 消费者接收消息
    - 当监听器发现 Stream 有新消息：
      - 调用 ShortLinkStatsSaveConsumer.onMessage
      - 将消息传入线程池执行
      - 线程池是生产用来执行onmessage方法的线程的
  - 消费者内部处理逻辑
    - 对每个短链接使用 读写锁确保同一条短链接的统计数据在数据库更新时不会冲突
    - 数据库操作：
      - 更新统计表：PV/UV/UIP/按时间维度聚合
      - 更新明细表：LinkAccessLogsDO 插入每条访问记录
      - 可选调用外部服务：获取地理位置（AMap API）
    - 完成后删除 Stream 消息
    - 设置消息为已完成（幂等标记 1）
- 限流配置
  - InitializingBean：Spring 提供的一个接口，在 Bean 属性注入完成后会调用 afterPropertiesSet() 方法
  - 过实现 InitializingBean，在 Spring 启动时就初始化 Sentinel 限流规则
  - 新建一个 FlowRule 列表，用来存储限流规则
  - FlowRule createOrderRule = new FlowRule(); → 新建一个流控规则对象
  - setResource("create_short-link") → 限流的资源名称，这里是 "create_short-link"，对应业务中调用的接口或方法
  - setGrade(RuleConstant.FLOW_GRADE_QPS) → 限流类型：按 QPS（每秒请求数） 限制
  - setCount(1) → 每秒最大允许 1 个请求
  - rules.add(createOrderRule) → 添加到规则列表
  - FlowRuleManager.loadRules(rules);
- 回收站功能
  - 主要就是对逻辑删除字段del和enable设置0,1状态，然后在回收站分页查询和短链接分页查询时根据字段进行区分
- 短链接跳转原始链接功能
  - UV首次登录统计
  #image("Screenshot_20250927_161333.png")
  - 使用消息队列来写数据库
    - 削峰填谷
      - Redis + MQ 先快速存储请求数据，保证用户跳转几乎无延迟。
      - 消息队列可以缓冲高并发流量，后台消费者再批量写数据库。
    - 解耦
      - 短链接跳转请求和统计入库解耦：
        - 跳转逻辑只负责快速响应（Redis 查找 + 重定向）。
        - 统计逻辑异步执行（消费 MQ，写数据库）。
      - 即使数据库挂掉，短链接跳转功能仍然可用。
    - 可扩展性
      - 后续如果要增加更多统计维度（如地理位置、设备分布、热力图），只要在消费端扩展逻辑即可，不需要修改跳转代码。
  - 布隆过滤器防止缓存穿透
    #image("Screenshot_20250927_162413.png")
  - Redis进一步标记之前查过，确实不存在的短链接的缓存
  - 分布式锁查询数据库
    - 在查询数据库前需要再进行一次缓存查询
    - 因为前面的代码逻辑是先查缓存，缓存没命中才查数据库
      - 但在高并发下，可能多个请求同时查缓存，前面的缓存都没命中，走到了抢占分布式锁的逻辑
      - 这时只有一个请求能拿到锁，其他请求都阻塞等待，直到锁释放后再进行数据库查询
      - 在这个请求的数据库逻辑里，可能修改了缓存，但在抢占分布式锁的线程是无法感知的，因为他们已经走完了判断缓存的逻辑
      - 因此需要在抢占到分布式锁之后再次判断
  - 布隆过滤器，redis缓存与数据库查询逻辑
    - 加锁前
      - 先查redis有没有以短链接为key，原始链接为value的string类型数据
        - 若有直接记录uv数据并且重定向到原始链接
        - 若没有 
          - 查布隆过滤器有没有该短链接缓存
            - 若没有则返回pageNotFound
            - 若有
              - 查询redis负缓存 
                - 若存在则返回pageNotFound
                - 若不存在
                  - 抢占分布式锁查询数据库
                    - 抢占失败等待
                    - 抢占成功进入数据库查询逻辑
                      - 再次查询redis以短链接为key的缓存和redis的负缓存，和加锁前的思路一样（因为抢占失败等待的线程无法感知到抢占了锁的线程对缓存的修改）
                      - 若经过第二次缓存逻辑通过
                        - 说明redis中不存在以短链接为key的缓存
                          - 原因：
                            - 数据库中有数据
                              - 缓存过期：Redis 设置了 TTL（有效期），短链接的缓存可能过期被清理了，但数据库里还存在。
                              - 缓存未写入：某个短链接刚创建，还没来得及写入 Redis，就可能出现 Redis 里没有，但数据库里有。
                              - 缓存失效/重建中：可能 Redis 集群做了故障转移，部分数据丢失。
                            - 数据库中无数据
                              - 布隆过滤器误判：布隆过滤器允许少量误判，可能认为某个短链接存在，但实际上数据库里没有。
                              - 数据删除：短链接可能被用户删除了，数据库里已经没有对应记录。但是布隆过滤器没法删除
                              - Redis 缓存和负缓存都过期。
                        - 负缓存不存在
                          - 数据库中可能有相应的数据
                          - 缓存过期
                      - 查询数据库
                        - 先查goto表，只有短链接
                          - 若不存在
                            - 返回pageNotFound
                            - 写入负缓存
                          - 若存在 
                            - 查详细数据表
                              - 包括删除字段和启用字段
                            - 将查出来的信息进行过滤筛选
                              - 若被删除或未被启用或没有数据
                                #image("Screenshot_20250927_170732.png")
                                - 写入负缓存
                                - 返回pageNotFound
                              - 若未被删除且被启用
                                - 将该短链接为key，原始链接为value写入redis缓存
                                - 记录uv等信息
                                - 重定向到原始链接
                    - 释放分布式锁
- 短链接创建功能
  - 资源保护注解
    ```java
    @SentinelResource(
    value = "create_short-link",                         // 资源名称，标识被保护的方法
    blockHandler = "createShortLinkBlockHandlerMethod",  // 当触发限流/降级时的处理方法
    blockHandlerClass = CustomBlockHandler.class         // 限流处理方法所在的类
    ) 
    ```
    - 当 create_short-link 这个资源被 Sentinel 判定为限流或熔断时，不会执行原方法，而是调用 CustomBlockHandler.createShortLinkBlockHandlerMethod(...) 来返回一个友好的结果，从而避免直接抛出 Sentinel 的异常。
    - 如何触发限流
      - 有一个类会有限流规则设置，并在该类上会setResource("create_short-link")标记限流的方法，这个resource和sentinelresource的value值相同
      - 当调用该方法时，sentinel会检查当前的 QPS 是否超过了规则中设置的阈值
      - 如果超过了，就会触发限流，不会执行原方法，而是调用 blockHandler 指定的处理方法
  - 从前端服务拿到完整链接
  - 创建短链
    - 如果在布隆过滤器中存在短链数据说明生成的短链重复
      - 进行重试，重试次数达到上限则返回错误
    - 如果布隆过滤器中不存在短链数据
      - 进行插入数据库
  - 插入数据库要插入到总信息表和短链表
  - 将两个插入数据库的操作放在try里
    - 若插入成功
      - 将短链插入布隆过滤器和redis缓存
      - 返回短链
    - 若插入失败
      - 可能是短链重复，违反了唯一性约束
        - 判断布隆过滤器是否存在短链
          - 若不存在则直接新增入布隆过滤器
          - 这里对布隆过滤器的判断是为了防止布隆过滤器和数据库的不一致性问题
            - 原因： 
              - 布隆过滤器关机或重启时，内存数据会丢失
              - 两个线程同时访问\@transactional修饰的方法，该方法里有布隆过滤器和数据库插入逻辑，如果线程a完成数据库插入，但是还没有在布隆过滤器插入，线程b此时判断布隆过滤器不存在相同短链，也插入数据库，结果发生了冲突
            - 为什么需要在catch里补一次插入逻辑
              #image("Screenshot_20250930_194737.png")
            - 布隆过滤器作用 
              - 快速判断短链是否存在，减少数据库压力
            - 用布隆过滤器+数据库的唯一性约束来保证绝对不重复
              - 因为布隆过滤器允许少量误判，可能认为某个短链不存在，但实际上数据库里已经有了。
              - 数据库的唯一性约束是最终的保障，确保不会插入重复的短链。
      - 抛出错误，短链接生成重复提示前端
- 通过分布式锁创建短链接
  - 生成短链和插入数据库前就加锁
  - 避免并发冲突
  - 单线程，慢

- 批量创建
  - 其实还是调用原来的创建短链方法
  - 只是把前端传过来的多个完整链接拆分成一个个调用
  - 一次性传入多条长链接，系统自动循环处理，不需要用户手动多次发请求（少了网络请求的多次往返、用户点击操作），用户体验更好。
- 修改短链
  - 