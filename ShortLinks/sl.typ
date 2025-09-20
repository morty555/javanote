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