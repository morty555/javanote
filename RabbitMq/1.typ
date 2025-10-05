#set text(size:2em)
- 同步通讯
  - 实时性强
  - 不能并发
- 异步通讯
  - 可以并发

- 使用Rabbitmq
  - 本地启动
  - 创建工具类 RabbitMQUtil，配置port,host，username,password等参数，同时提供连接，通道的获取方法和关闭资源方法
  - channel.queueDeclare声明一个队列
    - 参数含义
      - 队列名称
      - 队列是否持久化（服务器重启后队列还在）
      - 是否只限于当前连接使用（false = 多个连接都能用）
      - 是否自动删除（false = 消费完不会删除队列）
      - 额外参数
  - 生产者和消费者都需要声明队列，这样保证目标队列存在。
  - channel.basicConsume注册消费者
    - 参数含义
      - 队列名字
      - 消息确认，false：关闭自动确认（autoAck），表示你要 手动确认消息。
      - 回调函数，每当队列里有消息，就会触发这段逻辑。
        - delivery：封装了消息的所有内容，比如 delivery.getBody() 就是消息内容。
  - channel.basicAck(delivery.getEnvelope().getDeliveryTag(), false);处理成功后，手动确认消息，RabbitMQ 就会把这条消息从队列里删除。
    - deliveryTag：消息的唯一标识（RabbitMQ 分配）。
    - false：表示只确认这一条消息（如果传 true，表示批量确认 deliveryTag 之前的所有未确认消息）。
  - channel.basicNack(delivery.getEnvelope().getDeliveryTag(), false, true);处理失败时，拒绝消息，并让它重新回到队列（true = requeue）。下次还有机会重新消费。
    - 第一个 deliveryTag：消息 ID。
    - 第二个 false：只拒绝这一条。
    - 第三个 true：是否 requeue（重新放回队列）。


- 手动确认和自动确认的区别
  - 自动确认
    - 消息一旦投递给消费者，就立刻被 RabbitMQ 标记为确认（删除队列里的副本），不管消费者是否处理成功。消息可能丢失。比如消费者刚收到消息，还没处理完就挂了 → 这条消息就丢了（因为 RabbitMQ 已经以为它“处理完了”）。
  - 手动确认
    - 消息被消费者接收后，只有在代码里显式调用 basicAck，RabbitMQ 才会把这条消息标记为完成并从队列删除。
    - 如果处理失败：可以调用 basicNack 或 basicReject，选择是否重新入队。
    - 优点：确保消息至少被处理一次（at-least-once）。


- 死信队列
  - 声明死信交换机channel.exchangeDeclare
    - 交换机名称（自定义），这里用作死信交换机。
    - 交换机类型：direct 表示路由键精确匹配消息到队列。其他类型还有 fanout、topic、headers。
    - 是否持久化交换机。持久化交换机在 RabbitMQ 重启后仍存在。
  - 声明死信队列channel.queueDeclare
    - 	队列名称，这里作为死信队列。
    - 队列是否持久化。持久化队列在 RabbitMQ 重启后仍存在。
    - 是否排他队列。false 表示队列可以被多个连接共享；true 则队列只属于当前连接。
    - 队列是否在没有消费者时自动删除。false 表示不会自动删除。
    - 	arguments，队列的额外参数
  - 将死信队列绑定到死信交换机channel.queueBind
    - 队列名称
    - 交换机名称，即消息来源交换机。
    - 	路由键，direct 类型交换机使用此路由键进行消息匹配。
  - 普通队列绑定死信交换机
    - 普通队列绑定的死信交换机，当消息被拒绝、过期或队列满时，消息会发送到这个交换机
    - 死信交换机的路由键，用来将消息路由到对应队列。
  - 声明普通队列channel.queueDeclare
    - 	普通队列名称，用于正常消费任务消息。
    - 队列持久化。
    - 是否排他队列。
    - 是否自动删除。
    - 队列的额外参数 这里应该传 args 才能绑定死信队列。
  - 死信队列本身只是一种“标记和隔离”机制，它并不会自动处理消息。它的主要作用是把那些无法被正常消费的消息（比如被拒绝、超时或过期）单独放到一个队列里，以便后续分析或处理。
  - 要对死信队列的消息进行处理，其实跟普通队列一样，声明一个死信队列的channel然后进行监听就可以，通过回调函数的delivery拿到死信队列的消息


- 交换机
  - 在 RabbitMQ 中，生产者并不直接把消息发送到队列，而是发送给 交换机（Exchange），交换机根据一定的规则把消息路由到一个或多个队列。
  - 交换机类型
    -  Direct（直连型）
      - 路由规则：根据 精确匹配 routing key 把消息发送到队列。
      - 应用场景：需要将消息发送到特定队列时。
    - Fanout（扇出型）
      - 路由规则：忽略 routing key，把消息发送到绑定的 所有队列。
      - 应用场景：广播消息，比如日志系统或通知系统。
    - Topic（主题型）
      - 路由规则：根据 routing key 与 队列绑定的模式（带通配符）匹配来路由。
      - 应用场景：复杂路由，消息按主题分类发送。
      - 通配符：\*：匹配一个单词，\#：匹配零个或多个单词
      ```
      队列A绑定 key="log.*"
      队列B绑定 key="log.#"
      消息 routingKey="log.info" → A、B都能收到
      消息 routingKey="log.error.db" → 只有B收到
      ```
    - Headers（头部型）
      - 路由规则：根据 消息头部属性（headers）匹配队列，而不是 routing key。
      - 应用场景：更灵活的路由规则，适合不适合字符串匹配的场景。
      ```
      队列A绑定条件 headers={"type":"image","format":"png"}
      生产者发送消息 headers={"type":"image","format":"png"} → 队列A收到

      ```