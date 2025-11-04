= 图像纤维识别平台
- 消息队列
  - 为什么要用消息队列？
    - 解耦：可以在多个系统之间进行解耦，将原本通过网络之间的调用的方式改为使用MQ进行消息的异步通讯，只要该操作不是需要同步的，就可以改为使用MQ进行不同系统之间的联系，这样项目之间不会存在耦合，系统之间不会产生太大的影响，就算一个系统挂了，也只是消息挤压在MQ里面没人进行消费而已，不会对其他的系统产生影响。
    - 异步：假如一个操作设计到好几个步骤，这些步骤之间不需要同步完成，如该项目从前端拿到图片后，将图片上传到阿里云oss和进行分析识别服务是可以异步进行的，这样就可加快系统的访问速度，提供更好的客户体验。
    - 削峰：一个系统访问流量有高峰时期，也有低峰时期，比如说，中午整点有一个抢购活动等等。比如系统平时流量并不高，一秒钟只有100多个并发请求，系统处理没有任何压力，一切风平浪静，到了某个抢购活动时间，系统并发访问了剧增，比如达到了每秒5000个并发请求，而我们的系统每秒只能处理2000个请求，那么由于流量太大，我们的系统、数据库可能就会崩溃。这时如果使用MQ进行流量削峰，将用户的大量消息直接放到MQ里面，然后我们的系统去按自己的最大消费能力去消费这些消息，就可以保证系统的稳定，只是可能要跟进业务逻辑，给用户返回特定页面或者稍后通过其他方式通知其结果
  - 不使用消息队列可以吗
    - try-catch避免崩溃
    - 给RestTemplate设置限时机制
    - spring Retry实现重试机制
      - 启动类\@EnableRetr
      - 方法\@Retryable
      ```java
      @Retryable(
    value = { ResourceAccessException.class, HttpServerErrorException.class }, // 需要重试的异常类型
    maxAttempts = 3,          // 最大重试次数（含第一次）
    backoff = @Backoff(delay = 2000, multiplier = 2) // 每次重试间隔时间（初始2秒，翻倍增长）
     ) 
      ```
    - 定义重试失败后的兜底方法
      - \@Recover 方法：
        - 参数第一个必须是异常类型；
        - 参数签名要和原方法一致；
        - 当重试次数用完后会自动调用。
  - 消费者执行识别逻辑时，怎么保证消息不重复消费或丢失？
    - 为什么会出现消息重复消费
      - 生产者重发消息，发送后 Broker 未返回 ACK，生产者以为失败，重发。
      - Broker 消息重投，消息已投递给消费者，但 Broker 未收到 ACK，认为失败，重试投递。
      - 消费者重启或异常，消费者处理消息后宕机，没提交 offset，下次启动会重新消费同一条。

    - 消息重复消费怎么解决？
      - 生产者角度防止重复
        -  消息唯一标识（幂等ID）
          - 在发送消息前，为每条消息生成唯一ID（如业务订单号、UUID）。即使重复发送，同一消息ID不会被重复处理。
        - 启用 ConfirmCallback 并做幂等确认
          - RabbitMQ 的 Publisher Confirms 模式允许你注册回调，确认每条消息是否成功到达 Broker。
      - 消费者角度防止重复
        - 消费幂等
          - 可以用：Redis、数据库唯一索引、分布式锁，第一次消费时执行并记录；再次消费时检测到已处理，直接跳过。
        - 消费 offset 精确提交
          - RabbitMQ：手动 ack 模式，确认消息处理完毕再 ack。
          - Kafka：手动提交 offset（enable.auto.commit=false），确保只有处理成功后才提交。
          - RocketMQ：返回 ConsumeConcurrentlyStatus.CONSUME_SUCCESS 后才算成功。
  - rabbitmq 
    - RabbitMQ的特性你知道哪些？
      - RabbitMQ 以 可靠性、灵活性 和 易扩展性 为核心优势，适合需要稳定消息传递的复杂系统。其丰富的插件和协议支持使其在微服务、IoT、金融等领域广泛应用，比较核心的特性有如下：
        - 持久化机制：RabbitMQ 支持消息、队列和交换器的持久化。当启用持久化时，消息会被写入磁盘，即使 RabbitMQ 服务器重启，消息也不会丢失。例如，在声明队列时可以设置 durable 参数为 true 来实现队列的持久化：
        - 消息确认机制：提供了生产者确认和消费者确认机制。生产者可以设置 confirm 模式，当消息成功到达 RabbitMQ 服务器时，会收到确认消息；消费者在处理完消息后，可以向 RabbitMQ 发送确认信号，告知服务器该消息已被成功处理，服务器才会将消息从队列中删除。
        - 镜像队列：支持创建镜像队列，将队列的内容复制到多个节点上，提高消息的可用性和可靠性。当一个节点出现故障时，其他节点仍然可以提供服务，确保消息不会丢失。
        - 多种交换器类型：RabbitMQ 提供了多种类型的交换器，如直连交换器（Direct Exchange）、扇形交换器（Fanout Exchange）、主题交换器（Topic Exchange）和头部交换器（Headers Exchange）。不同类型的交换器根据不同的规则将消息路由到队列中。例如，扇形交换器会将接收到的消息广播到所有绑定的队列中；主题交换器则根据消息的路由键和绑定键的匹配规则进行路由。

    - RabbitMQ的底层架构是什么？
      - 核心组件：生产者负责发送消息到 RabbitMQ、消费者负责从 RabbitMQ 接收并处理消息、RabbitMQ 本身负责存储和转发消息。
      - 交换机：交换机接收来自生产者的消息，并根据 routing key 和绑定规则将消息路由到一个或多个队列。
      - 持久化：RabbitMQ 支持消息的持久化，可以将消息保存在磁盘上，以确保在 RabbitMQ 重启后消息不丢失，队列也可以设置为持久化，以保证其结构在重启后不会丢失。
      - 确认机制：为了确保消息可靠送达，RabbitMQ 使用确认机制，消费费者在处理完消息后发送确认给 RabbitMQ，未确认的消息会重新入队。
      - 高可用性：RabbitMQ 提供了集群模式，可以将多个 RabbitMQ 实例组成一个集群，以提高可用性和负载均衡。通过镜像队列，可以在多个节点上复制同一队列的内容，以防止单点故障。

  - 消息队列如何选型
    #image("Screenshot_20251009_221833.png")
    - 从需求选型
      - 高吞吐
        - Kafka
        - RocketMQ  
      - 时效性，低延迟
        - RabbitMQ 
        - 特别说一下时效性，RabbitMQ以微秒的时效作为招牌，但实际上毫秒和微秒，在绝大多数情况下，都没有感知的区别，加上网络带来的波动，这一点在生产过程中，反而不会作为重要的考量。
      - 稳定性，安全性
        - 分布式部署的Kafka和Rocket
      - 支持主题数多
        - RabbitMQ 
      - 消息回溯，容错性强
        - 消息回溯就是让消费者从过去某个时间点（或 offset）重新消费已经消费过的消息。
        - RocketMQ 
        - Kafka 

- Kafka为什么高可用高可靠
  - 高可用主要指 服务不中断。即使部分 Broker 宕机，Kafka 集群仍能继续对外提供服务。
    - 分区副本机制
      - 每个topic分多个分区
      - 每个分区都有多个 副本（replica），一个为 Leader，其他为 Follower。
      - 数据写入和读取都是通过 Leader 完成，Follower 只做同步。
      - 当某个 Broker 宕机时：
        - 该 Broker 上的分区 Leader 不可用；
        - Kafka 会自动从剩余的副本中 选举一个新的 Leader；
        - 客户端自动重定向到新的 Leader，服务不中断。
    - Controller 节点选举
      - controller节点负责
        - 监控 Broker 状态；
        - 触发副本重新分配；
        - leader重选
    - 客户端自动感知
      - Kafka Producer、Consumer 都支持：
        - 自动感知分区 Leader 变更；
        - 自动重连机制
        - 元数据刷新。
  - 高可靠指 数据不丢失、不重复、顺序一致。
    - 多副本同步
      - Kafka 的副本同步机制保证：
        - Leader 负责写入；
        - Follower 从 Leader 拉取数据；
        - 当 ISR（In-Sync Replicas）集合 内所有副本都同步成功后，才算“提交”成功。
    - 持久化日志（顺序写 + PageCache）
      - Kafka 将消息写入 磁盘日志文件（commit log），并且是顺序写入：
        - 顺序写速度接近内存；
        - 依赖操作系统 PageCache，提高读写性能；
        - 重启或宕机后数据仍可从磁盘恢复。
    -  ACK 机制（生产者确认）
      #image("Screenshot_20251014_200713.png")
    - Min In-Sync Replicas（最小同步副本数）
      - min.insync.replicas = 2即必须至少有 2 个副本在 ISR 集合中同步成功，否则拒绝写入。
    - 消费者位移持久化（Offset Commit）
      - 消费者消费进度（offset）会写入 Kafka 内部主题 __consumer_offsets；
      - 同样有副本机制；
      - 即使消费者或 Broker 宕机，也能恢复到正确位置。

  - 既然rabbitmq的时效性没那么重要，为什么还要选择
    - 轻量，上手快、集成方便
    - 灵活的消息路由模型
    - 简单的可靠性模型
      - RabbitMQ 的 ack + 重试机制 简单直观，不需要理解 offset、事务回查等复杂逻辑。
      - 对于中小系统：
        - “发送消息 → 手动 ack → 出错重投” 就能满足 99% 异步场景。
    - 运维轻量

  - 为什么不选择kafka
    - 第一点：实时性与丢弃策略。
      - RabbitMQ 支持设置队列的最大长度、消息 TTL 和溢出策略（比如 drop-head），当队列满时可以自动丢弃最老的消息，这样可以防止识别任务堆积、系统被拖慢。而 Kafka 的消息是一定会落盘的，即使识别失败也会被保存在日志里，不会自动清理，如果遇到用户恶意上传无关图片，就容易导致消息堆积、磁盘被占满，消费端长期卡死。RabbitMQ 更合适。  
    - 第二点：失败消息处理机制。
      - 在 RabbitMQ 里，我们可以在消费失败时直接 ack 掉非法消息，或者通过 TTL + 死信队列做隔离，让无效图片不再重试、不占用资源；而 Kafka 的模型是偏向“可靠重放”的，消息会被重复拉取直到成功消费，这在我们这种识别模型只能处理特定类型图像的场景下反而是负担。
    - Kafka 适合海量日志、可重放的高吞吐场景；而我们的业务更偏实时识别任务处理，需要快速清理无效任务、保证系统不堆积。所以选择 RabbitMQ 能在保持消息可靠性的同时，更好地控制实时性和系统稳定性。

    
  - 为什么 RabbitMQ 延迟更低
    - RabbitMQ 的延迟低主要源自两点机制：
      - Push 模型（推送）
        - Broker 主动把消息推给 Consumer，省去了轮询等待时间；
      - 内存优先存储
        - 消息一般先放内存，再异步刷盘（可关闭持久化）。
    - 而 Kafka / RocketMQ 是 Pull 模型（拉取）：
      - 消费者周期性拉取消息，批量拉取会导致“感知延迟”略高。

  - “自动重试 + 延迟队列 + 死信队列”是怎么实现的？
    - 主队列和死信队列进行绑定，当主队列的消息被 basicReject(requeue=false) 拒绝时，消息会被 RabbitMQ 自动转发到该死信交换机 → 路由到 dlx_queue。
    - 延迟重试队列设置了TTL（x-message-ttl）：消息在此队列中存活时间为 1 秒和DLX（x-dead-letter-exchange=""）：消息过期后，由 RabbitMQ 自动重新投递到主队列。 
    - 生产者发布任务后，会先打到主队列进行消费，消费失败后，进入 handleRetry() 方法
    - handleRetry方法每次重试都会在消息头中将retry-count的值+1,每次重试时要先从消息头中读取该值
      - 如果次数未达上限：
        - 将消息重新发布到 retry_exchange → retry_queue；
        - retry_queue 里消息等待 TTL 过期；
        - TTL 到期后，自动回流到主队列（image_task_queue）；
        - 消费者重新消费该消息 → 再次执行任务。
      - 如果超过上限：
        - basicReject(requeue=false) 拒绝；
        - 消息进入主队列绑定的死信交换机 → 被投递到 dlx_queue。

  - 如果你的消费者宕机或处理超时了，消息会发生什么？
    - 我使用了
      ```java
            channel.basicConsume(MAIN_QUEUE, false, (consumerTag, delivery) -> {
          ...
      }, consumerTag -> {}); 
      ```

      并设置了手动确认模式， 在这种模式下，RabbitMQ 把消息从主队列中取出，发给你的消费者；这条消息变成 unacked（未确认）状态；RabbitMQ 等待消费者调用 basicAck() / basicReject() / basicNack()；如果消费者宕机、崩溃、网络断开，RabbitMQ 会检测到这个连接断开；此时 RabbitMQ 会把所有属于这个连接的 unacked 消息：重新标记为 ready 状态，并重新投递给其他可用的消费者（或自己重启后的新实例）。
  - 如果 ack 失败或者抛出异常，消息会如何被 RabbitMQ 处理？
    - 如果 ack 失败或者抛出异常，RabbitMQ 不会认为该消息已被成功消费。
    - 如果 ack 失败但代码未做任何处理，该消息会一直处于 unacked（未确认）状态，RabbitMQ 不会重新投递它，也不会删除它，从而导致队列阻塞（因为 RabbitMQ 默认每个消费者只会分配一定数量的未确认消息）。
    - 防止这种情况，我们通常会在 basicAck() 外层加 try-catch，一旦检测到 ACK 失败或抛出异常，可以手动执行 basicNack(deliveryTag, false, false) 拒绝消息或重新 basicPublish() 到死信队列，以确保消息不会卡死在 unacked 状态。
    #image("Screenshot_20251011_171919.png")
  
  - 你怎么控制最大重试次数
    - handleRetry方法每次重试都会在消息头中将retry-count的值+1,每次重试时要先从消息头中读取该值
      - 如果次数未达上限：
        - 将消息重新发布到 retry_exchange → retry_queue；
        - retry_queue 里消息等待 TTL 过期；
        - TTL 到期后，自动回流到主队列（image_task_queue）；
        - 消费者重新消费该消息 → 再次执行任务。
      - 如果超过上限：
        - basicReject(requeue=false) 拒绝；
        - 消息进入主队列绑定的死信交换机 → 被投递到 dlx_queue。

  - 为什么你选择用“延迟队列”而不是 RabbitMQ 的插件 delayed-message-exchange？你能说说这两种方案的区别与优劣吗？
    #image("Screenshot_20251011_172354.png")
    - 我在这个项目里选择用 TTL + 死信队列 来实现延迟重试，是因为 项目需求并不需要精确的延迟时间，TTL 的精度已经够用。两种方案在性能上差别不大，而且使用 x-delayed-message-exchange 插件比较麻烦，需要额外安装和配置，迁移成本比较高

  - 消息的幂等性你是怎么保证的？假如 RabbitMQ 因为网络抖动导致消息被重新投递两次，数据库如何避免重复写入？
    - 消息幂等性的核心思想是对同一条消息，不论消费者处理多少次，系统最终结果应该一致，避免重复写入、重复扣款、重复通知等。
    - 利用 唯一业务 ID，每条消息都带一个唯一 ID（如 messageId 或 taskId）数据库在写入时检查是否已存在：
      - 如果存在，就直接跳过或更新，不会重复写入。
    - 利用 数据库唯一约束
      - 即使消息被重复消费，数据库也会抛出唯一约束异常，可以捕获并忽略，保证不会重复写入。
    - 消息去重缓存
      - 使用 Redis 等缓存记录最近处理过的 messageId
      - 消费消息前先检查 Redis，如果存在就跳过，处理完后更新缓存 
  
  - RabbitMQ的瓶颈在哪里
    - 消息生产端
      - 如果大量图片同时上传，消息发送到 RabbitMQ 的速度可能超过 Broker 处理能力。
      - 这会导致消息堆积在队列中。
    - RabbitMQ Broker 本身
      - 单台 RabbitMQ 的 CPU、内存和磁盘 I/O 是瓶颈。
      - 队列里堆积大量消息时，内存和磁盘压力大，可能触发性能下降或流控。
    - 消费者端
      - 你的消费者是调用 Python 服务分析图片，每张图片处理时间可能较长。
      - 如果消费者数量不足，消息堆积，导致延迟增加。
  - 如果有成千上万张图片同时上传，消费者压力如何？
    - 单消费者：
      - 消费速度跟不上消息产生速度 → 队列消息堆积
      - 消费者可能被 CPU 或 Python 分析服务阻塞，响应变慢
      - 内存可能被大量未 ack 消息占用
    - 多消费者：
      - 可以并行处理消息，但如果 Python 服务处理能力有限，也可能成为瓶颈
      - 消费者之间需要合理分配任务，避免某个节点压力过大
    - 负载均衡 / 横向扩展方案
      -  消费者水平扩展
        - 启动多个 独立消费者实例，它们同时监听同一队列。
        - RabbitMQ 会 自动分发消息到空闲消费者（轮询分配），实现负载均衡。
      - 多队列 + 多交换机
        - 对任务量大或类型不同的消息，使用 多个队列 或 Topic Exchange
        - 将不同类型或大小的任务分流，避免单队列堆积。
      - 消费者内部并发处理
        - 每个消费者可以使用线程池或异步处理消息
        - Python 分析服务可通过 多进程 / 异步队列 提升吞吐量
      - 限流与流控
        - RabbitMQ 提供 QoS 设置：
        - 控制每个消费者一次拉取的消息数量，防止内存被打满
      - Broker 集群
        - 对于极大规模消息量，可以考虑 RabbitMQ Cluster
        - 提供高可用、分布式队列能力，减少单点瓶颈
  - 你提到负载均衡，负载均衡的策略有哪些
    - 简单轮询：将请求按顺序分发给后端服务器上，不关心服务器当前的状态，比如后端服务器的性能、当前的负载。
    - 加权轮询：根据服务器自身的性能给服务器设置不同的权重，将请求按顺序和权重分发给后端服务器，可以让性能高的机器处理更多的请求
    - 简单随机：将请求随机分发给后端服务器上，请求越多，各个服务器接收到的请求越平均
    - 加权随机：根据服务器自身的性能给服务器设置不同的权重，将请求按各个服务器的权重随机分发给后端服务器
    - 一致性哈希：根据请求的客户端 ip、或请求参数通过哈希算法得到一个数值，利用该数值取模映射出对应的后端服务器，这样能保证同一个客户端或相同参数的请求每次都使用同一台服务器
    - 小活跃数：统计每台服务器上当前正在处理的请求数，也就是请求活跃数，将请求分发给活跃数最少的后台服务器
  
  - 为什么使用 RabbitMQ 而不是 Kafka？你能从任务类型（图像分析任务 vs 日志流）角度解释原因吗？
    - 任务性质
      - 每个消息对应 一张图片分析任务
      - 任务有明确的 处理顺序和确认机制
      - 消费者处理时间不固定（调用 Python 服务分析图片，可能几百毫秒到几秒）
    - 任务目标
      - 每条消息必须被 至少一个消费者成功处理一次
      - 支持 失败重试、延迟重试、死信队列
      - 消息不需要长期存储，只要处理成功就行
    - 对于植物纤维图像分析任务，每条消息都对应一张独立图片，需要可靠投递、可失败重试、顺序消费和延迟重试，RabbitMQ 比 Kafka 更轻量、易用，也能满足功能需求。Kafka 更适合日志流或海量事件流，追求吞吐量和持久化，而不是单条任务可靠处理。
    - Kafka的延迟队列和死信实现
      #image("Screenshot_20251011_190834.png")
      #image("Screenshot_20251011_190936.png")

- 缓存与数据库数据一致性

  - Redis和数据库如何保证数据一致性
    - 在修改数据时，先修改数据库再删缓存
      - 这个好处是，因为删缓存速度很快，先修改数据库再删缓存，在数据库修改成功到缓存删除这个时间空隙很短，并发下问题出现几率小
      - 即使在极少数情况下有线程在窗口期内读取了旧数据，由于缓存被很快删除，下次读取时也能重新从数据库中获取最新数据，问题可忽略不计。
    - 如果是先删缓存再修改数据库
      - 首先数据不一致性的窗口期很长，并发下出现问题大
      - 如果请求进入空窗期，读取数据库的脏数据后会写入缓存，这样当数据库修改完成后，缓存和数据库长期不一致，问题很大
    - 在项目中，我使用了先修改数据库再删除缓存，并且通过消息队列进行重试，防止缓存删除失败，并且在缓存失效后，通过加分布式锁，只允许一个线程进入修改，防止缓存击穿造成数据库压力暴增（尤其是高并发下热门 fiber 类别、图像元信息、数据集元信息等）。
  - Redis 实现分布式锁的原理
    - 利用 Redis 的原子性操作，保证在多个客户端竞争同一资源时，只有一个客户端能成功获得锁。


  - 在 Redis 和数据库异步更新的场景下，如何保证查询库存时数据的一致性？
    + 查询强制走缓存，禁止直接查数据库
      - 避免“双写不一致”；
      - 读性能极高。
      - Redis 故障时，恢复逻辑要设计好；
      - 异步失败可能造成短时库存差异。
    + 写操作时，使用消息队列确保最终一致
      - 异步但可靠；
      - 最终一致；
      - 支持高并发。
      - 数据短时不一致；
      - 需要 MQ 可靠性保障。
    - 查询时做 Redis + DB 双查校正
      - 先查 Redis；若 Redis 没有，则查数据库；并异步回填 Redis；对一致性要求中等。
    - 延迟双删策略（适用于同步更新）
    - 分布式锁 + 异步刷新
      - 在查询库存时：发现 Redis 缓存过期；获取分布式锁；一个线程去数据库刷新 Redis；



  - redis怎么设计的
    - 以类型为key,数据为value

  - 那在redis删除数据如何删
    - 先
    ```java 
    Set<String> keys = stringRedisTemplate.keys("imageType:*");
    ```
    获得所有的key再删除，因为redis的delete不支持通配符

  - 你还添加了布隆过滤器，说说布隆过滤器在项目中的作用
    - 在每次添加数据的时候，都将该数据的type作为key加入布隆过滤器
    - 在每次图识别图时，先判断type是否存在布隆过滤器中，若不存在则直接返回给前端，避免缓存穿透，同时提高运行效率

  - 你是如何设置布隆过滤器的参数的？


  - 在更新数据库之后，布隆过滤器是在缓存删除后更新还是前更新
    - 先更新布隆过滤器再删除缓存
      - 这个方案在高并发下，如果Bloom 已经更新但缓存还没更新完成，会出现瞬间缓存未命中 → 查数据库 → 压力小幅上升。但是不会出错
      - 这个方案主要保证的是正确性，性能有些许波动
    - 如果先删除缓存再更新布隆过滤器
      - 在缓存更新完成但布隆过滤器还未更新前，这个 key 仍可能被布隆过滤器判断为不存在；这样新的请求可能被直接「短路」掉（即被过滤掉），导致数据暂时查不到。
      - 这个方案性能稍优，一旦缓存写入完成，新请求立刻能从缓存读到数据；但有过滤正确数据的风险
    - 需要注意的是，布隆过滤器无法删除key，如果删除了数据库中的数据，只能先删除缓存，不更新布隆过滤器。因此有个小问题：如果未来要删除掉一个类别的key 布隆过滤器无法修改 他会认为这个key还在数据库内。放行一个错误数据到下一层redis检测
    - 对于这个redis层，我在服务启动的时候将纤维数据库中所有数据取出，并用hash结构，以type为hashkey,数据条数为value存放在redis中
    - 这样即使布隆过滤器出现误判，也能通过该hash结构判断数据库中是否存在该类别数据
    - 在高并发下，该hash结构也会出现问题，如果在一个类别存量为1时，两个线程同时进入删减逻辑的if判断
      - 此时因为库存为1,两个判断都成功，会出现两个线程都扣减成功导致类别为-1的情况，当下次有新的数据加入，hash中则变成0,和数据库中的1数据出现不一致性
    - 对于这种情况，一般采用几种解决方案
      - 分布式锁，每次扣减都要先拿到锁，这样效率慢
      - lua脚本，将多个redis操作用lua脚本保证原子性，该操作性能较优

- 你知道本地缓存可以用那个谷歌的guava cache吧，这二者有什么区别，为什么用caffeine，它解决了guava的什么问题？
  #image("Screenshot_20251015_155334.png")  
  - 传统 LRU（最近最少使用）策略存在几个问题：
    - 缓存抖动（Cache Pollution）
      - 突然出现的大量一次性访问数据会把热数据挤出缓存。例如：一次性扫描 100 万条新数据，LRU 会把原本频繁访问的小数据全部踢掉。
    - 命中率不够高。LRU 只考虑最近访问时间，不考虑访问频率。
  - Window-TinyLFU 核心思想
    - Window 部分（新数据区）
      - 缓存的一小部分（比如 1/32）用于存放 最新访问的条目。
      - 保证新进入的数据有机会被缓存
    - Main 部分（主缓存区）
      - 大部分缓存用于存放 频繁访问的老数据。
      - 使用 TinyLFU 策略判断是否应该保留或淘汰。
        - TinyLFU
          - 是一个 频率过滤器（Frequency Filter），基于 计数最小化算法（Count-Min Sketch），记录每个 key 的访问频率。
          - 当一个新条目要进入 Main 区时，算法会比较它的访问频率和 Main 区里最不常用条目的频率：如果新条目访问频率高于被替换条目，则替换。否则被淘汰
  - Caffeine的的Segment + CAS + 写队列
    - 在多线程更新同一个缓存节点时，不用加锁，而是通过原子操作尝试更新。如果更新失败（其他线程已经修改），会重试。
    - 为了进一步减少并发冲突，Caffeine 将缓存划分为多个 段（segment）。每个 segment 内部是一个小的哈希表，独立维护。这里锁的是表结构，即防止增删节点的并发问题，不对单个节点数据进行保护
    - Caffeine 维护一个 写队列（通常是 WriteOrderDeque）来延迟处理一些操作：元素访问顺序更新，过期/淘汰操作，LRU/LFU 权重更新。
      当线程写入或访问一个节点时，不立即修改全局访问顺序，而是把操作记录到写队列。

- 单机场景下，商户商品持续增加导致缓存不停 put 键，数组可能不够用，该如何解决？
  - Caffeine：支持基于容量的 LRU/LFU 淘汰策略，自动扩容和异步刷新，底层通过 Segment + CAS + 写延迟队列 实现高性能。
  - Guava Cache：也支持基于容量/时间的淘汰，但性能略低于 Caffeine。

- 实现 LRU 淘汰策略后，查询、淘汰操作的时间复杂度是多少？
  - 哈希表 + 双向链表实现 
    - 查询：O(1)
    - 淘汰：O(1)
  - 因为哈希表存储了节点地址，提供了常数时间的键值查找，双向链表维护了访问顺序，淘汰最久未使用的节点也只需常数时间。

- LRU 实现中，查询时会修改链表，如何保证并发安全？
  - 直接加锁
  - 分段锁（Segment Lock）
  - 非阻塞 CAS + 写队列 
  - get 操作不直接修改链表而是记录访问时间戳或访问计数，链表/优先队列异步刷新淘汰顺序。Caffeine 的 Window TinyLFU思想。但是访问顺序不是严格精确的 LRU，可能是 近似 LRU
    - 淘汰逻辑会选择 链表尾部节点，如果后台刷新线程还没处理最近的访问，链表顺序可能 不是最新的



- 令牌桶 redis lua aop
  - 令牌桶和漏桶的区别？
    - 漏桶是固定速率处理请求，限制突发；
    - 令牌桶允许突发流量，但平均速率受限。
  - 令牌桶的核心参数是什么？
    - capacity（桶容量）、rate（生成速率）、tokens（当前令牌数）、last_refill_time（上次补充时间）
  - 令牌桶如何处理突发流量？
    - 当请求到来时，如果桶里有足够令牌，可以一次性放行；
    - 如果没有令牌，则拒绝或排队。
  - 为什么使用REDIS 
    - 多节点共享令牌桶状态，实现全局限流；
    - 高性能、低延迟。
  - 为什么使用LUA脚本
    - 保证令牌补充和消费操作原子性，防止并发冲突。
  - 令牌桶在 Redis 中如何存储？
    - 可以用 Hash 存储：tokens、last_refill_time；
    - 每个 key 对应一个限流对象（用户或接口）。
  - \@RateLimit 注解是如何生效的？
    - \@Around("\@annotation(rateLimit)") 切点拦截带注解的方法；
    - 通过 ProceedingJoinPoint 调用原方法，并结合令牌桶判断是否允许执行。
  - 单机部署下为什么使用 ConcurrentHashMap？
    - 缓存每个方法的本地令牌桶实例；
    - 保证多线程访问安全，避免重复创建桶。
  - 如何保证高并发下的线程安全？
    - 本地缓存使用 ConcurrentHashMap + computeIfAbsent 原子创建桶；
    - Redis + Lua 保证分布式原子性。
  - 突发流量控制如何实现？
    - 令牌桶允许积累令牌，短时间内可以同时放行多请求；


- 你用到websocket,Websocket建立连接的过程，涉及到HTTP吗
  - WebSocket 建立连接的过程的确涉及 HTTP 协议，但仅在握手阶段（初次连接时）使用 HTTP。之后就升级为 WebSocket 协议，不再走 HTTP。直接在 TCP 层上进行全双工数据传输。  

- 那http和websocket区别是什么
  - HTTP 是请求-响应协议，而 WebSocket 是双向实时通信协议。双向：客户端和服务端都能主动发送消息
  - HTTP	每次请求都新建或复用连接（短连接或HTTP/2多路复用） WebSocket通过一次 HTTP 握手升级为 WebSocket 长连接
  - HTTP无状态（每次请求独立） WebSocket有状态（连接保持不断开）
  - HTTP基于文本（HTTP 报文头+体），Websocket二进制帧（更轻量）
  - HTTP实时性弱，WebSocket实时性强
  - 传输协议都是TCP



- xxljob的组件有哪些
  - 调度中心
    - 提供任务管理、调度、日志、执行结果监控等功能，是系统的核心控制中枢。独立部署的 Web 应用（通常是 Spring Boot + MySQL）
  - 执行器
    - 负责执行调度中心下发的任务，并将执行结果回传。部署在各业务服务节点上
  - 通信模块
    - 调度中心与执行器之间通过 HTTP（默认）或自定义 RPC 通信。
  - 数据存储模块（数据库）
    - 保存任务信息、调度日志、执行结果、调度记录、执行器注册信息等
  - 注册中心（执行器注册机制）
    - 执行器会定期向调度中心注册并保活，调度中心通过心跳表判断执行器状态。内置在调度中心数据库
  - 调度线程池
    - 负责从数据库中扫描待触发任务、推送到执行器。
  - 日志模块
  - 核心组件交互流程
    - 任务注册
      - 开发者在调度中心（xxl-job-admin）上配置任务（包括 cron 表达式、路由策略、任务参数等）。
      - 任务保存到数据库。
    - 执行器注册
      - 每个执行器启动后，会定期向调度中心注册（HTTP 心跳机制）。
      - 调度中心维护一张 xxl_job_registry 表记录执行器在线状态。
    - 任务调度
      - 调度中心内部有一个扫描线程（ScheduleThread），定时从数据库扫描符合 cron 表达式的任务。
      - 当任务到期后，调度中心通过 HTTP 调用对应的执行器节点接口 /run 下发任务执行。
    - 任务执行
      - 执行器收到任务后，执行本地定义的 JobHandler（任务逻辑）。
      - 执行完成后，将执行结果（成功 / 失败 / 日志）回调到调度中心。
    - 日志与监控
      - 调度中心记录执行日志，并可通过 Web UI 查看。
      - 支持任务超时、失败重试、邮件报警等。



= 点评+智能体
== LangChain4j 与系统架构相关
- 你为什么选择 LangChain4j 而不是直接调用 LLM API？
  #image("Screenshot_20251020_202507.png")

- LangChain4j 的核心组件有哪些？它和 LangChain（Python 版）相比有何异同？
  - LangChain4j 是 LangChain 在 Java 生态中的官方移植与再设计版本，由 LangChain4j团队维护，保持了 LangChain 的整体思想框架：LLM 抽象 + 记忆系统 + 工具调用 + 文档检索增强（RAG） + 智能体（Agent）架构。
  - ChatLanguageModel
    - 封装了主流模型（OpenAI、Ollama、Qwen、阿里云百炼、Azure、Vertex AI、Mistral 等）的调用逻辑。
  - PromptTemplate
    - 模板化 Prompt 构造
  - ChatMemory
    - 自动保存上下文消息，实现有状态对话。
    - 内置实现
      - MessageWindowChatMemory（基于窗口的滑动记忆）
      - InMemoryChatMemoryStore
      - RedisChatMemoryStore
  - RetrievalAugmentor（RAG 模块）
    - 向量化文本 → 存储 → 检索相似内容 → 拼接到 Prompt 中 → 交给 LLM
    - 主要组件：
      - EmbeddingModel：生成文本向量（如 OpenAiEmbeddingModel、BGEEmbeddingModel）
      - EmbeddingStore：存储向量（如 PgVectorEmbeddingStore、ChromaEmbeddingStore）
      - RetrievalAugmentor：整合检索结果并传递给模型。
  - AiServices（Declarative AI 接口）
    - 核心：LangChain4j 最有特色的模块之一。
    - 允许你用一个 Java 接口声明一个“智能体”，并用注解驱动：
    - 同时支持工具调用（\@Tool）
  - Tools（函数调用 / 插件系统）
    - 支持通过注解\@Tool 或 FunctionTool 注册。
    - 当模型生成的文本中包含指令时，会自动执行对应 Java 方法。
  - DocumentLoaders + EmbeddingStore
    - 可加载多种数据源（PDF、TXT、HTML、数据库）
    - 向量化后存入 EmbeddingStore
    - 可直接配合 RAG 使用。
  - AgentExecutor
    - 核心：完整的智能体执行引擎
    - 可以根据模型输出动态决定调用哪个工具、是否继续推理。
    - 内部实现 ReAct 模式（Reason + Act + Observation）。
    #image("Screenshot_20251020_203412.png")
  
- 你在项目中是如何实现 会话隔离 的？
  - LangChain4j 的 Memory 模块 + Redis 存储层实现持久化记忆
  - 用户请求 → 带 userId/sessionId → 获取对应 Memory → 注入到 LangChain4j 会话 → 返回回答并更新记忆
  - 使用 RedisChatMemoryStore（自定义 MemoryStore）
    - LangChain4j 默认提供了 InMemoryChatMemoryStore，但这是 JVM 内存，不适合分布式部署。
  - 绑定用户会话ID（实现会话隔离）
    - 每个请求头都会带上 Authorization（JWT Token），后端从中解析出用户 ID
    - 然后在创建 Memory 时使用这个唯一键
  - LangChain4j 会话绑定
    - 创建 Assistant（智能体）时，把 memory 注入：

- LangChain4j 如何实现 消息注解（\@UserMessage, \@SystemMessage）？这些注解的作用是什么？
  - 是 LangChain4j 提供的一种“消息角色建模机制”，用于在与大模型（LLM）的交互中标识不同来源的对话消息，从而精确控制提示（prompt）的构建逻辑。
  - 假设你在 LangChain4j 中定义了一个智能助手接口：
    ```java
      @AiService
  public interface Assistant {

      @SystemMessage("You are a helpful assistant that answers concisely.")
      @UserMessage("What is the capital of {{country}}?")
      String askCapital(@V("country") String country);
  }

    ```
  - 调用时：
    ```java
    String answer = assistant.askCapital("Japan");
    System.out.println(answer);
 
    ```
  - 这会生成给 LLM 的消息序列：
    ```
    [
  { "role": "system", "content": "You are a helpful assistant that answers concisely." },
  { "role": "user", "content": "What is the capital of Japan?" }
    ]
    ```
  - LangChain4j 会自动根据注解将方法中的字符串模板转化为消息对象，传入底层的 ChatCompletion 请求中。
  - 底层实现原理（源码机制）
    - LangChain4j 在构建 AiService 的代理类时，会扫描方法上的注解并构造消息列表。
    - 简化流程如下：
      - 注册阶段
        - 当你用 AiServices.builder(Assistant.class).build(model) 创建代理对象时，LangChain4j 会扫描接口中所有方法。
      - 注解解析
        - 每个方法被封装为一个 AiServiceMethod 对象，它会读取：
          - 方法上的 \@SystemMessage、\@UserMessage 等注解；
          - 方法参数上的 \@V("...")、\@MemoryId、\@Context 等注解。
      - 消息构建
        - 当方法被调用时，LangChain4j 会根据模板替换参数（如 {{country}} → "Japan"），然后将这些注解转换为 ChatMessage 列表
      - 发送给 LLM

- 你是如何在 Spring Boot 中集成 LangChain4j 的？（例如配置、上下文管理）
  - 引入依赖
  - 模型配置类（LangChain4j 配置 Bean）
    - 例如使用 Ollama 本地模型：
      ```java
              @Configuration
        public class LangChainConfig {

            @Bean
            public ChatLanguageModel chatModel() {
                return OllamaChatModel.builder()
                        .baseUrl("http://localhost:11434") // Ollama 服务地址
                        .modelName("llama3") // 模型名
                        .temperature(0.7)
                        .build();
            }
        }
 
      ```
    - 若使用阿里云百炼 DashScope：
      ```java
            @Bean
      public ChatLanguageModel dashscopeModel() {
          return DashScopeChatModel.builder()
                  .apiKey(System.getenv("DASHSCOPE_API_KEY"))
                  .modelName("qwen-turbo")
                  .build();
      }
 
      ```
  - 上下文管理（记忆）
    - LangChain4j 提供多种记忆方式（Memory），可用来保存对话上下文。在生产中常配合 Redis 实现 会话隔离。
  - 定义 AI 接口（LangChain4j Agent）
    - LangChain4j 提供了类似 Spring 的声明式 AI 接口定义机制。
    ```java
        @AiService
    public interface ChatAgent {

        @SystemMessage("你是一个智能对话助手。")
        @UserMessage("用户说：{input}")
        String chat(@V("input") String input);
    }
 
    ```
  - 然后在配置类中创建代理实例：
    ```java
        @Bean
    public ChatAgent chatAgent(ChatLanguageModel chatModel, Memory memory) {
        return AiServices.create(ChatAgent.class, chatModel, memory);
    }
 
    ```
  - Controller 层接入
    ```java
        @RestController
    @RequestMapping("/api/chat")
    public class ChatController {

        private final RedisMemoryManager memoryManager;
        private final ChatLanguageModel model;

        public ChatController(RedisMemoryManager memoryManager, ChatLanguageModel model) {
            this.memoryManager = memoryManager;
            this.model = model;
        }

        @PostMapping
        public String chat(@RequestParam String sessionId, @RequestParam String message) {
            Memory memory = memoryManager.getMemory(sessionId);
            ChatAgent agent = AiServices.create(ChatAgent.class, model, memory);
            return agent.chat(message);
        }
    }
 
    ```

== 会话记忆与上下文管理

== RAG（检索增强生成）与知识库构建

== 大模型部署与性能优化

== 工具调用与扩展能力

== 架构设计与工程实践


== 点评部分
- 项目中如何模拟超卖？模拟的QPS量级和库存设置是多少？
  - Jmeter压测      