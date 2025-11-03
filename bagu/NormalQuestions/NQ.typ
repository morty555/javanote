= 牛客面经
- Java数据结构
  - Collection
    - List
      - 	ArrayList、LinkedList、Vector
    - set
      - 	HashSet、LinkedHashSet、TreeSet
    - Queue
      - 	LinkedList、PriorityQueue
    - Deque
      - 	ArrayDeque、LinkedList
  - Map
    - HashMap、LinkedHashMap、TreeMap、Hashtable、ConcurrentHashMap

- 介绍一下堆的实现方式，插入删除时间复杂度
  - 堆是一种完全二叉树（complete binary tree）
  - 大根堆（最大堆）：任意节点的值 ≥ 其子节点的值。
  - 小根堆（最小堆）：任意节点的值 ≤ 其子节点的值。
  - 堆通常使用 数组（array） 实现，而不是链表或树节点结构。
  - 假设数组下标从 1 开始
    - 父节点下标  	i / 2
    - 左子节点下标 	2 \* i
    - 右子节点下标 	2 \* i + 1
  - 堆的主要操作
    - 插入（Insert）
      - 将新元素放到数组末尾；
      - 向上调整（上浮 / sift-up）直到满足堆性质。
      - 时间复杂度：O(log n)
    - 删除（Delete）通常删除的是堆顶元素（最大/最小）。
      - 将堆顶与最后一个元素交换；
      - 删除最后一个元素；
      - 向下调整（下沉 / sift-down）以恢复堆性质。
      - O(log n)
    - 建堆（Heapify）
      - 逐个插入：O(n log n)
      - 从最后一个非叶子节点开始下沉：O(n)
  - On建堆
    #image("Screenshot_20251025_094254.png")
    #image("Screenshot_20251025_094320.png")
    #image("Screenshot_20251025_094328.png")

- Caffeine、Guava 等本地缓存与 Java 普通哈希方法的区别是什么？
  - HashMap / ConcurrentHashMap
    - 本质是一个纯粹的键值存储容器。
    - 不提供过期、淘汰、统计等缓存功能。
    - 内存占用完全由 JVM GC 管理。
    - hashmap不是线程安全的，concurrenthashamap线程安全
  - Caffeine / Guava Cache
    - 支持自动过期、大小限制、LRU/LFU 淘汰策略、异步刷新等。
    - 可以统计命中率、加载未命中数据（通过 CacheLoader）。
    - 支持 容量限制，超过限制时自动根据策略淘汰：
      - LRU (最近最少使用)
      - LFU (最不经常使用，Guava 支持)
      - 基于权重（Caffeine）
    - 支持 时间过期：
      - 写入后过期（expireAfterWrite）
      - 访问后过期（expireAfterAccess）
    - 内部通常支持高并发访问（Caffeine 基于 CAS + Segment + 写延迟队列）。

- 用线程池或多线程扫描缓存淘汰数据，会为系统带来多少额外开销？有其他更好的方法吗？
  - 额外开销主要有以下几个方面：
    - CPU 开销
      - 每次扫描需要访问缓存的内部数据结构（哈希表/链表/跳表等）。如果缓存很大，比如百万级或亿级条目，遍历整个缓存会占用大量 CPU 时间。
    - 内存开销
      - 多线程扫描时可能需要额外的临时数据结构（比如线程本地队列或标记数组），尤其在分段锁/分片缓存中，每个线程可能持有额外引用。
    - 锁/同步开销
      - 如果缓存内部数据结构需要加锁（Segment 或 synchronized），并发扫描会导致锁竞争。
      - 高并发情况下，可能会影响正常读写操作的吞吐量。
    - 上下文切换
      - 大量线程会带来上下文切换成本，尤其是线程数 > CPU 核数时。
  - 现代高性能缓存（如 Caffeine）都尽量避免全量扫描，使用“懒惰淘汰 + 局部维护”的策略：
    - 惰性/访问时淘汰（Lazy Eviction）：只有在访问缓存时，才检查该条目是否过期或需要淘汰。
      - 优点：无需定期扫描，CPU 开销几乎为零
      - 缺点：不访问的缓存可能长时间占用空间，但一般配合容量限制可控。
    - 分段/分片淘汰（Segmented Eviction）
      - 将缓存分成 N 段，每段独立管理 LRU/过期策略。
      - 只扫描活跃段或随机抽样部分条目，不需要全量扫描。
    - 写入触发淘汰（Write-Driven Eviction）
      - 当缓存容量接近阈值时，在写操作时顺便淘汰最老或最不常访问的条目。
    - 近似 LRU / CLOCK 算法
      - 可以用环形数组或队列，每次淘汰时随机检查部分条目。
      - 不严格维护全局访问顺序，只维护近似顺序。
    - 异步批量淘汰队列
      - 只有写入时将条目放入延迟队列，由后台线程异步清理，但不扫描整个缓存。


- java中hashmap是干什么的，主要用途？插入，删除时间复杂度？
  - HashMap 是 Java 中最常用的 键值对（key-value）映射容器，属于 java.util 包。
  - 它的核心功能是：
    - 通过 key 快速查找、插入、删除 value
    - 不保证顺序（与插入顺序无关）
    - 允许 null 键和 null 值（但 Hashtable 不允许）
  - 主要用途
    - 快速查找
      - 比如缓存、索引、计数器（词频统计、IP访问次数等）
      - map.get(key) 能在平均 O(1) 时间内获取结果
    - 存储键值对映射关系
      - 如 userId → UserInfo
      - username → password
    - 实现集合类
      - HashSet 实际上就是基于 HashMap 实现的（key 存值，value 为固定常量）
  - 时间复杂度分析
    - 插入查找删除  	平均O(1)  最差	O(n) 
    - 当链表变成红黑树后，最坏情况会优化为：	O(log n)


- treeMap和hashMap的区别和底层实现
  - 是否顺序存储：
    - treeMap按key顺序存储
    - hashMap不按顺序存储
  - key可以为null吗？ value呢？
    - treeMap的key不能为null，因为需要排序
    - hashMap可以为null,但是只有一个，因为有覆盖问题
    - value都可以为null，且多个
  - 线程安全
    - 都不是线程安全的
  - 插入，删除时间复杂度
    - treeMap是logn,因为基于红黑树
    - hashMap平均O（1），最坏为O（n），碰撞严重退化成链表，但是链表长度大于8会变成红黑树（jdk1.8以后）
  - 底层实现
    - treeMap的底层实现是红黑树
    - hashMap的底层实现是数组+链表或红黑树 

- 为什么要红黑树不要AVL树
  - AVL树严格平衡二叉树，维护代价高
  - 红黑树平衡策略相对宽松

- 那为什么还要链表
  - 红黑树占用更多内存，红黑树节点大小是普通节点大小的两倍
- 如果链表转为红黑树，还会转回来吗
  - 树节点小于等于6
    - 为什么是6而不是8
      - 避免单节点反复添加删除导致的树化与去树化频繁


- hashmap的底层实现
  - 由数组+链表或红黑树构成
  - put时，先计算key的hash值
  - 然后hash&（n-1）计算索引
  - 如果索引所在位置没有元素则直接放在数组中，如果有
    - 如果key不同，则产生哈希冲突，如果链表的元素小于8或者数组长度小于64，在链表后加入元素
    - 如果key相同，直接替换
  - 如果链表的元素大于8且数组长度>=64,则把链表转换成红黑树
    - 为什么要数组长度大于等于64
      - 避免频繁树化，减小内存占用
      - 数组容量小的时候，扩容自然会减少哈希冲突
      - 容量小更容易扩容，如果不限制数组长度，可能树化完又扩容了
    - 为什么是8 
      - 时间效率和空间占用的平衡
      - 因为红黑树占用内存大，能不用就不用
      - 链表冲突到8的几率很小
  - 扩容机制：
    - 如果数组小于64,链表长度超过 8，优先扩容
    - 如果当前hashmap的容量>容量\*负载因子，则触发扩容 默认容量16,负载因子0.75
      - 为什么是0.75
        - 时间和空间效率的平衡
        - 0.5扩容频繁，查得快
        - 1的话查询效率慢，省空间
    - 扩容容量 ×2，创建新数组，重新计算每个元素的新位置。
    - rehash过程
      - 遍历旧表，对每个桶进行重新分配
        - 如果桶中只有一个节点：直接根据新 hash 重新放入新表。
        - 如果是链表结构：
          - 低位组（(e.hash & oldCap) == 0）留在原索引；
          - 高位组（(e.hash & oldCap) != 0）移动到 index + oldCap。
        - 如果是树结构：
          - 拆分为两棵树或链表，逻辑同上。
  - 为什么容量总是 2 的幂
    - 方便用 (n - 1) & hash 快速计算索引，比直接取余运输快很多
  - 为什么hash 高低位混合
    - 避免哈希分布偏移，提高均匀性
  - 为什么链表树化阈值 8
    - 实际测试中链表长度超过 8 概率极低，树化提升极少但增加复杂度
  - 为什么扩容只移位不重算 hash
    - 节省 CPU 时间，利用位运算特性
  - 为什么负载因子 0.75 
    - 平衡时间与空间效率
  - JDK 8 前后的区别
    - JDK 7，对于桶的哈希冲突问题，采用头插法解决，链表也是纯链表，没有红黑树的扩展，扩容全部重hash
    - JDK8，采用尾插法避免多线程扩容时死循环，采用链表+红黑树的结果，扩容	利用 (hash & oldCap) 判断位置
    - JDK8使key的哈希值的高16位和低16位异或，使得哈希值同时拥有高位和低位的特性，哈希分布更均匀
    - JDK8对元素迁移机制优化
  - hashmap头插法多线程下的死循环问题
    #image("Screenshot_20251017_122249.png")
    - 其实就是头插法下，链表扩容时桶搬迁后是逆序的
    - 但是多线程环境下，A,B线程在搬迁前指向同一个头节点，若A节点时间片用完在休眠，B节点开始搬迁，搬迁后，因为逆序的原因，等到A节点执行时间片的时候，就和新hashmap的存储顺序相反了，结果就会产生死循环
  - 头插法put流程
    - 新元素计算到key所在index有多个元素时
    - 直接将新元素的next指向数组index指向的元素
    - 再让数组index指向新元素就可以了
    - 也就是说，数组[index]存的是链表头节点的索引，每次put新元素时将新元素next指向数组index指向的头节点，改变链表的头节点为新元素，再让数组index指向该元素即可
  - 尾插法put流程
    - 计算到index后先遍历index所在位置的链表直到tail
    - tail.next=新元素
    - 新元素.next=null；
    - 修改新元素为tail
  - hashmap扩容时，顺着数组index所指向的元素一个个迁移，也就是从链表头开始迁移
  - 也就是说 扩容的时候先比较桶各个元素hash & oldCap的值，将为0的放在一个链表，不为0的放在另一个链表，这个过程用的尾插法，当遍历完一个桶所有元素后，将原桶index所在位置指向为0的链表的头节点索引，新桶指向不为0的

  - hashset和hashmap的区别
    - hashset是基于hashmap实现的，不允许重复元素，无序
    - 主要是基于hashmap的key唯一实现的，value为一个常量对象
  - hashmap保证顺序吗
    - 不保证，如果要保证可以用linkedhashmap
    - 排序的话用treemap
  - linkedhashmap使用过吗
    - LRU缓存的实现

- hashmap为什么线程不安全
  - HashMap 的设计是为了单线程环境的高效访问，因此
    - 没有加锁
    - 没有使用volatile等同步机制
    - 没有CAS等原子操作
  - 多线程 put 导致数据覆盖
  - 扩容（resize）时的线程安全问题
    - JDK 1.7：扩容时链表可能反转成环导致死循环；
      - 头插法导致多线程扩容时死循环问题
      - 两个线程指向同一个头节点，A线程休眠，B线程扩容后链表逆序，A线程继续执行时链表顺序和新hashmap不一致，导致死循环
    - JDK 1.8：结构改为数组 + 链表/红黑树，虽然死循环问题修复了，但并发写入仍然会导致数据丢失或覆盖。
      - 尾插法避免死循环，但并发写入仍会覆盖数据


- hashmap线程不安全，可以如何优化
  - hashtable，锁全表，效率慢
  - concurrenthashmap，效率高
  - sychronized，效率慢
    


 - Java的锁有哪些
      - 内置锁（Synchronized）
      - 显式锁（ReentrantLock）
      - 读写锁（ReadWriteLock）
      - 偏向锁 / 轻量级锁 / 重量级锁/ 自旋锁（JVM 层优化）
      - 乐观锁/CAS
      - 其他锁机制
        - StampedLock
        - Semaphore：
        - CountDownLatch / CyclicBarrier / Phaser：
  
- synchronized原理 
  - synchronized是基于原子性的内部锁机制，是可重入的，因此在一个线程调用synchronized方法的同时在其方法体内部调用该对象另一个synchronized方法，也就是说一个线程得到一个对象锁后再次请求该对象锁，是允许的，这就是synchronized的可重入性。
    - synchronized底层是利用计算机系统mutex Lock实现的。每一个可重入锁都会关联一个线程ID和一个锁状态status。
    - 当一个线程请求方法时，会去检查锁状态。
      - 如果锁状态是0，代表该锁没有被占用，使用CAS操作获取锁，将线程ID替换成自己的线程ID。
      - 如果锁状态不是0，代表有线程在访问该方法。此时，如果线程ID是自己的线程ID，如果是可重入锁，会将status自增1，然后获取到该锁，进而执行相应的方法；如果是非重入锁，就会进入阻塞队列等待。
    - 在释放锁时，
      - 如果是可重入锁的，每一次退出方法，就会将status减1，直至status的值为0，最后释放该锁。
      - 如果非可重入锁的，线程退出方法，直接就会释放该锁。


- 如何在多线程环境下使用HashMap，除了加同步锁方案和ConcurrentHashMap以外还能想到什么
  - 读写锁（ReentrantReadWriteLock）
    - 多读可以并发执行；
    - 写独占
    - 适合读多写少
    - 锁粒度仍然在“整个 Map”层面，性能不如分段锁。
  - 使用 Copy-On-Write 机制
    - 每次写入时复制一份新的 Map，读操作无锁
    - 写时要加sychronized锁
    - 写操作代价大（复制整个 map）；
  - 使用 分段锁（分区锁） 思想
    - 并发度更高，多个分区可同时写；
    - 原理接近 ConcurrentHashMap 1.7 的 “Segment” 分段锁。
  - 消息队列写
  - 使用 ThreadLocal + 合并机制。让每个线程维护自己的本地副本，最后再合并。

- ConcurrentHashMap底层
  - 在 JDK 1.7 中它使用的是数组加链表的形式实现的，而数组又分为：大数组 Segment 和小数组 HashEntry。 Segment 是一种可重入锁（ReentrantLock），在 ConcurrentHashMap 里扮演锁的角色；HashEntry 则用于存储键值对数据。一个 ConcurrentHashMap 里包含一个 Segment 数组，一个 Segment 里包含一个 HashEntry 数组，每个 HashEntry 是一个链表结构的元素。
  - 在 JDK 1.7 中，ConcurrentHashMap 虽然是线程安全的，但因为它的底层实现是数组 + 链表的形式，所以在数据比较多的情况下访问是很慢的，因为要遍历整个链表，而 JDK 1.8 则使用了数组 + 链表/红黑树的方式优化了 ConcurrentHashMap 的实现
  - JDK 1.8 ConcurrentHashMap JDK 1.8 ConcurrentHashMap 主要通过 volatile + CAS 或者 synchronized 来实现的线程安全的。添加元素时首先会判断容器是否为空：
    - 如果为空则使用 volatile 加 CAS 来初始化
    - 如果容器不为空，则根据存储的元素计算该位置是否为空。 
      - 如果根据存储的元素计算结果为空，则利用 CAS 设置该节点；
      - 如果根据存储的元素计算结果不为空，则使用 synchronized ，然后，遍历桶中的数据，并替换或新增节点到桶中，最后再判断是否需要转为红黑树，这样就能保证并发访问时的线程安全了。
  - 如果把上面的执行用一句话归纳的话，就相当于是ConcurrentHashMap通过对头结点加锁来保证线程安全的，锁的粒度相比 Segment 来说更小了，发生冲突和加锁的频率降低了，并发操作的性能就提高了。
  - 而且 JDK 1.8 使用的是红黑树优化了之前的固定链表，那么当数据量比较大的时候，查询性能也得到了很大的提升，从之前的 O(n) 优化到了 O(logn) 的时间复杂度。
  - 分段锁怎么加锁的？
    - 在 ConcurrentHashMap 中，对于插入、更新、删除等操作，需要先定位到具体的 Segment，然后再在该 Segment 上加锁，而不是像传统的 HashMap 一样对整个数据结构加锁。这样可以使得不同 Segment 之间的操作并行进行，提高了并发性能。
    - get过程中使用了大量的volatile关键字,并没有加锁，保证了可见性
  - 分段锁是可重入的吗？
    - JDK 1.7 ConcurrentHashMap中的分段锁是用了 ReentrantLock，是一个可重入的锁。
  
  - 已经用了synchronized，为什么还要用CAS呢
    - ConcurrentHashMap使用这两种手段来保证线程安全主要是一种权衡的考虑，在某些操作中使用synchronized，还是使用CAS，主要是根据锁竞争程度来判断的。
    - 比如：在putVal中，如果计算出来的hash槽没有存放元素，那么就可以直接使用CAS来进行设置值，这是因为在设置元素的时候，因为hash值经过了各种扰动后，造成hash碰撞的几率较低，那么我们可以预测使用较少的自旋来完成具体的hash落槽操作。
    - 当发生了hash碰撞的时候说明容量不够用了或者已经有大量线程访问了，因此这时候使用synchronized来处理hash碰撞比CAS效率要高，因为发生了hash碰撞大概率来说是线程竞争比较强烈。

-  ConcurrentHashMap 实现缓存的时间复杂度是多少？如何做到的？
  - 当桶内为链表时，GET,PUT,DELETE，CONTAINSKEY的复杂度为O（1）
  - 当为红黑树时，为O（logn）

- 为什么hashmap中允许key或者value为null？而concurrenrtHashMap不允许key或者value为null
  - 在map中，调用map.get(key)方法得到的值是null，那你无法判断这个key是在map里面没有映射过，还是这个key本身设置就null。这种情况下，在非并发安全的map中，可以通过map.contains(key)的方法来判断。但是在考虑并发安全的map中，两次调用的过程中，这个值是很有可能被改变的。

- sychronized和reentrantlock
  #image("Screenshot_20251014_201712.png")
  - synchronized是 Java 关键字，由 JVM 原生支持；底层是利用计算机系统mutex，依赖对象头中的monitor
  #image("Screenshot_20251014_201935.png")
  #image("Screenshot_20251014_202135.png")
  - reentrantlock是 普通类，基于 AbstractQueuedSynchronizer（AQS）实现；锁的获取和释放是通过 CAS + FIFO 等待队列（CLH 队列）；
-  介绍一下AQS
  - AQS全称为AbstractQueuedSynchronizer，是Java中的一个抽象类。 AQS是一个用于构建锁、同步器、协作工具类的工具类（框架）。
  - AQS核心思想是，如果被请求的共享资源空闲，那么就将当前请求资源的线程设置为有效的工作线程，将共享资源设置为锁定状态；如果共享资源被占用，就需要一定的阻塞等待唤醒机制来保证锁分配。这个机制主要用的是CLH队列的变体实现的，将暂时获取不到锁的线程加入到队列中。
  - CLH：Craig、Landin and Hagersten队列，是单向链表，AQS中的队列是CLH变体的虚拟双向队列（FIFO），AQS是通过将每条请求共享资源的线程封装成一个节点来实现锁的分配。
  - AQS使用一个Volatile的int类型的成员变量来表示同步状态，通过内置的FIFO队列来完成资源获取的排队工作，通过CAS完成对State值的修改。
  - Sync是AQS的实现。 AQS主要完成的任务：
    - 同步状态（比如说计数器）的原子性管理；
    - 线程的阻塞和解除阻塞；
    - 队列的管理。
  - 在 公平锁 下：进入阻塞队列的线程，只有队首那个会在 state=0 时尝试获取资源。
  - 在 非公平锁 下：队首线程会被唤醒尝试，但新来的线程也可能插队抢到锁。
  -  AQS原理
    - AQS最核心的就是三大部分：
      - 状态：state；
      - 控制线程抢锁和配合的FIFO队列（双向链表）；
      - 期望协作工具类去实现的获取/释放等重要方法（重写）。
    - 状态state
      - 这里state的具体含义，会根据具体实现类的不同而不同：比如在Semapore里，他表示剩余许可证的数量；在CountDownLatch里，它表示还需要倒数的数量；在ReentrantLock中，state用来表示“锁”的占有情况，包括可重入计数，当state的值为0的时候，标识该Lock不被任何线程所占有。
      - state是volatile修饰的，并被并发修改，所以修改state的方法都需要保证线程安全，比如getState、setState以及compareAndSetState操作来读取和更新这个状态。这些方法都依赖于unsafe类。
    - FIFO队列
      - 这个队列用来存放“等待的线程，AQS就是“排队管理器”，当多个线程争用同一把锁时，必须有排队机制将那些没能拿到锁的线程串在一起。当锁释放时，锁管理器就会挑选一个合适的线程来占有这个刚刚释放的锁。
      - AQS会维护一个等待的线程队列，把线程都放到这个队列里，这个队列是双向链表形式。
    - 实现获取/释放等方法
      - 这里的获取和释放方法，是利用AQS的协作工具类里最重要的方法，是由协作类自己去实现的，并且含义各不相同；
      - 获取方法：获取操作会以来state变量，经常会阻塞（比如获取不到锁的时候）。在Semaphore中，获取就是acquire方法，作用是获取一个许可证； 而在CountDownLatch里面，获取就是await方法，作用是等待，直到倒数结束；
      - 释放方法：在Semaphore中，释放就是release方法，作用是释放一个许可证； 在CountDownLatch里面，获取就是countDown方法，作用是将倒数的数减一；
      - 需要每个实现类重写tryAcquire和tryRelease等方法。
    - 当线程尝试加锁或释放锁时，AQS会通过判断 exclusiveOwnerThread 来判断是否“属于自己”：
-  CAS 和 AQS 有什么关系？
  - CAS 是一种乐观锁机制，它包含三个操作数：内存位置（V）、预期值（A）和新值（B）。CAS 操作的逻辑是，如果内存位置 V 的值等于预期值 A，则将其更新为新值 B，否则不做任何操作。整个过程是原子性的，通常由硬件指令支持，如在现代处理器上，cmpxchg 指令可以实现 CAS 操作。
  - AQS 是一个用于构建锁和同步器的框架，许多同步器如 ReentrantLock、Semaphore、CountDownLatch 等都是基于 AQS 构建的。AQS 使用一个 volatile 的整数变量 state 来表示同步状态，通过内置的 FIFO 队列来管理等待线程。它提供了一些基本的操作，如 acquire（获取资源）和 release（释放资源），这些操作会修改 state 的值，并根据 state 的值来判断线程是否可以获取或释放资源。AQS 的 acquire 操作通常会先尝试获取资源，如果失败，线程将被添加到等待队列中，并阻塞等待。release 操作会释放资源，并唤醒等待队列中的线程。
  - CAS 为 AQS 提供原子操作支持：AQS 内部使用 CAS 操作来更新 state 变量，以实现线程安全的状态修改。在 acquire 操作中，当线程尝试获取资源时，会使用 CAS 操作尝试将 state 从一个值更新为另一个值，如果更新失败，说明资源已被占用，线程会进入等待队列。在 release 操作中，当线程释放资源时，也会使用 CAS 操作将 state 恢复到相应的值，以保证状态更新的原子性。
-  如何用 AQS 实现一个可重入的公平锁？
  - 继承 AbstractQueuedSynchronizer：创建一个内部类继承自 AbstractQueuedSynchronizer，重写 tryAcquire、tryRelease、isHeldExclusively 等方法，这些方法将用于实现锁的获取、释放和判断锁是否被当前线程持有。
  - 实现可重入逻辑：在 tryAcquire 方法中，检查当前线程是否已经持有锁，如果是，则增加锁的持有次数（通过 state 变量）；如果不是，尝试使用 CAS操作来获取锁。
  - 在 tryAcquire 方法中，按照队列顺序来获取锁，即先检查等待队列中是否有线程在等待，如果有，当前线程必须进入队列等待，而不是直接竞争锁。
  - 创建锁的外部类：创建一个外部类，内部持有 AbstractQueuedSynchronizer 的子类对象，并提供 lock 和 unlock 方法，这些方法将调用 AbstractQueuedSynchronizer 子类中的方法。

- CAS存在什么问题，应用场景有哪些
  - ABA 问题
    - 值从 A → B → A，CAS 检查时看到值没变，误以为没有被修改过。
    - 解决方案：使用 版本号机制，即 带版本戳的 CAS。
  -  自旋（Spin）开销大
    - CAS 在失败时会不断重试（自旋），高并发下可能会占用大量 CPU。
    - 解决方案：限制自旋次数
  - 只能保证一个变量的原子性
    - 解决方案：使用 AtomicReference 封装多个变量；
  - 应用场景：
    -  原子类（AtomicInteger、AtomicBoolean 等）
    - ConcurrentHashMap
    - AQS（AbstractQueuedSynchronizer
    - 



- JAVA中的异常捕获
  - Java 的异常体系是基于类继承层次设计的，根类是 java.lang.Throwable：
  - try-catch
  - 多重 catch
  - try-catch-finally
  - try-with-resources
    - 只要资源类实现了 AutoCloseable 接口（如 FileInputStream、BufferedReader、Connection 等），系统会自动在 try 结束后调用 close() 方法。
  - throws 声明
  - throw 关键字
  - 自定义异常
    - 继承 Exception 或 RuntimeException，添加构造方法和自定义字段。

- java的异常类型 
  - Error（错误类）
    - Error 表示 JVM 层面的严重错误，通常由系统引起，应用程序无法恢复或不应捕获。
    #image("Screenshot_20251027_152811.png")
  - Exception（异常类）
    - Exception 是可以被程序捕获并恢复的异常。
    - 检查型异常（Checked Exception）
      - 编译器会强制要求捕获或声明 throws。
      #image("Screenshot_20251027_152845.png")
    - 运行时异常（Runtime Exception）
      - 运行时自动检测到的逻辑错误，编译器不强制处理。
      #image("Screenshot_20251027_152912.png")

- java的集合有哪些
  - collection接口体系
    - List —— 有序、可重复
      - arraylist
      - linkedlist
      - vector 线程安全
      - stack 继承自 Vector，后进先出（LIFO）
    - Set —— 无序、不重复
      - hashset
      - treeset
      - linkedhashset
    - Queue / Deque —— 队列 / 双端队列
      - PriorityQueue
      - ArrayDeque
      - LinkedList
      - Queue是只能一端进一端出，Deque是双端队列，两端都可进可出，Deque也常用作栈
  - Map 接口体系（键值对集合）
    - 特点：存储键值对（key-value），key 不可重复，value 可重复。
    - hashmap
    - treemap
    - linkedhashmap
    - Hashtable
    - concurrenthashmao

- ==和equals的区别
  - 基本类型不能使用equals
  - ==基本类型比值，引用类型比地址
  - equals默认比地址，重写后不一定
  - String、Integer、Date、集合类中的元素，都重写了 equals()，用来比较内容。所以==和equals可能不一样
- java中BIO,NIO，AIO区别，如何实现，是否有过实际的使用
  - BIO（blocking IO）：就是传统的 java.io 包，它是基于流模型实现的，交互的方式是同步、阻塞方式，也就是说在读入输入流或者输出流时，在读写动作完成之前，线程会一直阻塞在那里，它们之间的调用是可靠的线性顺序。优点是代码比较简单、直观；缺点是 IO 的效率和扩展性很低，容易成为应用性能瓶颈。
  - NIO（non-blocking IO） ：Java 1.4 引入的 java.nio 包，提供了 Channel、Selector、Buffer 等新的抽象，可以构建多路复用的、同步非阻塞 IO 程序，同时提供了更接近操作系统底层高性能的数据操作方式。
  - AIO（Asynchronous IO） ：是 Java 1.7 之后引入的包，是 NIO 的升级版本，提供了异步非堵塞的 IO 操作方式，所以人们叫它 AIO（Asynchronous IO），异步 IO 是基于事件和回调机制实现的，也就是应用操作之后会直接返回，不会堵塞在那里，当后台处理完成，操作系统会通知相应的线程进行后续的操作。
  - 底层实现区别
    - BIO：一个请求一个线程，线程调用 socket.read() 时挂起，直到有数据。
    - NIO：基于 I/O 多路复用（select/poll/epoll），一个线程能同时处理多个连接。
    - AIO：基于 操作系统异步 I/O 能力（如 Linux 的 io_uring、Windows 的 IOCP）。
  #image("Screenshot_20250907_235916.png")
  #image("Screenshot_20250908_000213.png")





- 为什么很多大厂只用post发请求
  - URL长度限制
    - GET 请求参数写在 URL 上，不同浏览器、代理、服务器对 URL 长度有限制（常见 2KB ~ 8KB）。
    - 在大厂业务场景中，请求参数可能很复杂（JSON、大量条件、批量 ID、加密串），GET 根本放不下。
    - POST 请求参数放在请求体中，长度没有限制。
  - 安全性
    - GET 请求参数暴露在 URL 上，容易出现在
      - 浏览器地址栏
      - 代理/网关日志
      - 浏览器历史记录
    - 敏感数据（如 token、手机号、订单号）用 POST 放在 body 里更安全。
  - 缓存与幂等性问题
    - HTTP 语义里：
      - GET 应该是安全、幂等的 → 浏览器、中间代理可能会缓存
      - POST 不幂等，默认不缓存
    - 在复杂的分布式系统里，大厂不想依赖中间层“自动缓存”的行为，所以干脆都用 POST，自己做缓存控制。
  - 统一网关与监控
    - 大厂通常有 API 网关、统一鉴权、监控系统。
    - 如果方法不统一（有的用 GET，有的用 DELETE），会增加接入和维护的复杂度。
    - 全部用 POST，统一在 header/body 做参数校验、签名验证、加解密，更加简单。
  - 跨域与复杂请求
    - 浏览器里，GET、POST 的简单请求比较好处理。
    - 但如果需要传自定义 header（如 token、签名），很多情况都会变成 复杂请求 (CORS Preflight)。
    - 大厂干脆约定一律 POST，减少前后端沟通成本。
  - 是一种务实选择，而不是规范选择。

- 长连接和短连接，长连接断开后会发生什么？
  - HTTP是以TCP协议传输的，也就是请求发送前要建立TCP连接
  - 如果每次发送都要建立TCP连接就是短连接，如果建立一次TCP连接可以进行多次请求就是长连接
  - 长连接中断会发生什么？
    - 长连接中断有几种情况
      - TCP连接被动关闭（服务器或客户端主动关闭）
        - 服务器会发送FIN包，TCP进入FIN_WAIT状态
        - 客户端接受到FIN包会进入CLOSE_WAIT状态
        - 之后完成四次挥手
        - 下一次请求时，客户端发现连接已关闭，就会自动重新建立 TCP 连接并重发请求。
      - TCP 连接异常中断（如网络波动、服务器崩溃）
        - 客户端会在写请求时得到 Broken pipe 或 Connection reset 错误；
        - 在在读响应时得到 Connection reset by peer；
        - TCP 状态会变成 CLOSE_WAIT 或 RESET。
        - 当前请求失败；连接池中的该连接会被移除；客户端会尝试重新建立新连接发送请求
      - 请求发送到一半时中断
        - 如果客户端发送请求数据过程中连接断了 请求直接失败；
        - 如果服务器已经收到了部分数据但没收完：服务器可能丢弃请求或返回错误（如 400、408）。
        - 客户端一般不会自动重试非幂等请求（如 POST），以免造成重复提交。 

- MTU
  - MTU（Maximum Transmission Unit，最大传输单元） 指的是一次可以在网络层传输的最大数据包大小（不含链路层头部）。
  - 常见情况下 MTU = 1500 字节（特别是在以太网环境）。应用层实际能传输的 TCP 数据（MSS）约为 1460 字节。    
  - 如果数据包超过 MTU，会被 分片（Fragmentation）；
  - 分片会导致性能下降；
  - 在 VPN、隧道、MPLS 环境中，还可能引发 “路径 MTU 问题”（PMTU 黑洞）。

- PMTU
  - PMTU（Path MTU） = 从源到目的地路径上，所有链路中最小的 MTU 值。
  - PMTU 发现机制（Path MTU Discovery）
    - 为避免分片，IP 协议设计了 PMTU Discovery (PMTUD) 机制：
    - 发送方发包时，设置：IP头中的 DF(Don’t Fragment) = 1，表示“禁止中途分片”。
    - 如果中途某个路由器发现包太大、自己 MTU 不够
      - 丢弃该包
      - 并返回一个 ICMP "Fragmentation Needed" (Type 3, Code 4) 消息；
      - 告诉发送方：“我这里 MTU = XXX”。  
    - 发送方据此降低包大小（更新路径 MTU），直到能成功传输。
  - PMTU 黑洞是什么？
    - 有些防火墙或路由器 拦截或丢弃了 ICMP 消息。
    - 路由器丢包了；但发送方 收不到 ICMP 通知；因为 DF=1，又不能分片；所以发送方永远不知道该减小包大小。
  - 解决方案： 
    - 允许 ICMP "Fragmentation Needed" 通过
    - 禁用 DF 位（允许分片）  
    -  手动调整 MTU

- 常见的请求头内容 content-type有什么
  - 常见的请求头内容 
    - 通用头（General）：和请求整体有关
      - Host：指定目标主机和端口；
      - Connection：是否保持连接（如 keep-alive）。
    - 实体头（Entity）：描述请求体内容
      - Content-Type：说明请求体类型（如 application/json、multipart/form-data）；
      - Content-Length：请求体长度。
    - 客户端信息头（Client Info）：描述客户端信息，比如
      - User-Agent：浏览器或客户端信息；
      - Accept、Accept-Language、Accept-Encoding：声明可接受的响应格式、语言、压缩方式。
    - 认证与安全相关头（Auth & Security）：
      - Authorization：携带令牌（JWT / Basic Auth）；
      - Cookie：传递登录状态。
    - 跨域与自定义头（CORS / Custom）：
      - Origin：跨域请求源；

- 认证头只能是authorization吗
  - 认证头不只能是 Authorization，但标准规定它是唯一正式的认证字段。在 HTTP 标准（RFC 7235 / RFC 9110） 中，Authorization 是唯一被标准定义的用于客户端向服务器传递认证信息的请求头。
  - 实践中：可以起别名，但属于“自定义请求头”
  - 自定义头不是“标准认证头”，它不会被某些中间件（如 Nginx、Spring Security）自动识别处理； 你需要自己解析。
  - 跨域（CORS）时必须显式允许，浏览器会先发一个 OPTIONS 预检请求。后端必须允许这个头：



  - HTTP 请求头里的 Content-Type 是非常重要的一个字段，用来声明请求或响应的实体内容（body）类型，告诉服务器（或客户端）数据是以什么格式传输的。
  - 常见的 Content-Type 类型分类
    - 文本类型
      - text/plain 纯文本 普通字符串请求、日志上传
      - text/html HTML文本 网页内容（HTML 页面）
      - text/css 前端样式文件
      - text/javascript 	前端脚本
      - text/xml XML 数据传输
    - 表单类型（Form）
      - application/x-www-form-urlencoded   默认表单格式，键值对以 key1=value1&key2=value2 方式编码  普通 HTML 表单提交
      - multipart/form-data 用于上传文件，数据被分块传输  
      - text/plain 简单表单文本上传 
    -  JSON / XML / 结构化数据
    - 文件与二进制数据
      - 二进制流 
      - PDF
      - ZIP
      - 图片文件
      - 音视频文件


- 常见的返回状态码
  - 1xx表示请求已被接收，正在继续处理。
  - 2xx表示请求已成功被接收、理解并接受
  - 3xx 重定向告诉客户端去别的地方获取资源。如 400 参数错误、401 未授权、403 禁止、404 未找到
  - 4xx 客户端错误表示请求有问题，客户端需要修改请求。如 400 参数错误、401 未授权、403 禁止、404 未找到；
  - 5xx 服务器错误 ，500 内部错误、502 网关错误、503 服务不可用。

- 永久重定向和临时重定向区别
  - 永久重定向浏览器会缓存重定向结果，下次访问不再请求原 URL，临时重定向不缓存，下次仍访问原 URL
  - 永久重定向搜索引擎会将旧地址的权重转移给新地址
  - 永久重定向一次后浏览器直接跳过短链接服务器，无法统计访问量
  - 永久重定向不能跳转目标修改

- 输入一个表单用的是什么格式的
  - 普通表单（默认）application/x-www-form-urlencoded登录、注册、搜索 
  - 文件上传：multipart/form-data 上传图片，文件
  - JSON 提交（JS 手动发） application/json   


- OSI七层和TCP四层网络模型 每层干什么，有什么协议
  - #image("Screenshot_20251103_111021.png")
  - #image("Screenshot_20251103_111035.png")



- 输入一段URL，整个过程发生了啥
  - URL解析，分析 URL 所需要使用的传输协议和请求的资源路径。
    - 如果输入的 URL 中的协议或者主机名不合法，将会把地址栏中输入的内容传递给搜索引擎。
    - 如果没有问题，浏览器会检查 URL 中是否出现了非法字符，则对非法字符进行转义后在进行下一过程。
  - 缓存查询 
    - 缓存判断：浏览器缓存 → 系统缓存（hosts 文件） → 路由器缓存 → ISP 的 DNS 缓存，如果其中某个缓存存在，直接返回服务器的IP地址。
  - DNS解析 
    - 如果缓存未命中，浏览器向本地 DNS 服务器发起请求，最终可能通过根域名服务器、顶级域名服务器（.com）、权威域名服务器逐级查询，直到获取目标域名的 IP 地址。
  - MAC地址查找
    - 当浏览器得到 IP 地址后，数据传输还需要知道目的主机 MAC 地址，因为应用层下发数据给传输层，TCP 协议会指定源端口号和目的端口号，然后下发给网络层。网络层会将本机地址作为源地址，获取的 IP 地址作为目的地址。然后将下发给数据链路层，数据链路层的发送需要加入通信双方的 MAC 地址，本机的 MAC 地址作为源 MAC 地址，目的 MAC 地址需要分情况处理。通过将 IP 地址与本机的子网掩码相结合，可以判断是否与请求主机在同一个子网里，如果在同一个子网里，可以使用 ARP 协议获取到目的主机的 MAC 地址，如果不在一个子网里，那么请求应该转发给网关，由它代为转发，此时同样可以通过 ARP 协议来获取网关的 MAC 地址，此时目的主机的 MAC 地址应该为网关的地址。
  - 建立TCP连接
    - 主机将使用目标 IP地址和目标MAC地址发送一个TCP SYN包，请求建立一个TCP连接，然后交给路由器转发，等路由器转到目标服务器后，服务器回复一个SYN-ACK包，确认连接请求。然后，主机发送一个ACK包，确认已收到服务器的确认，然后 TCP 连接建立完成。
  - SSL/TLS四次握手
    - 如果使用的是 HTTPS 协议，在通信前还存在 TLS 的四次握手。
  - 发送请求
    - 连接建立后，浏览器会向服务器发送HTTP请求。请求中包含了用户需要获取的资源的信息，例如网页的URL、请求方法（GET、POST等）等。
  - 接受请求渲染页面
  - 简单来说，当用户输入url url中携带了接收方的ip地址，本地就处理ip地址直到mac，然后判断是否在同一子网下，若在则直接通过ARP找到目标主机 MAC 若不在则使用 ARP 获取 网关 MAC，发送到网关 网关负责查路由表 → 决定下一跳 → 最终把数据送到目标主机 ，发送的过程要建立tcp连接， 如果是https还要建立tls连接 ，建立完连接后就能发送请求了






- 锁升级
  - 一开始某个临界区是无锁状态，如果有线程进入拿锁，就会先判断是否是偏向锁状态，如果不是就加当前线程的偏向锁，也就是把markword中的id设置为当前线程id.如果是偏向锁状态，就会判断markword的id和当前线程是否相同
    - 相同，进入临界区
    - 不相同，产生竞争
      - 若旧线程不再运行，将偏向锁转移
      - 如果此时旧线程还在运行，撤离偏向锁，升级为轻量级锁，轻量级锁采用CAS乐观锁，线程不断CAS自旋，直到拿到锁。如果CAS失败，说明竞争激烈，需要升级为重量级锁
        - 重量级锁未竞争到的锁不再自旋，而是直接挂起，减少cpu消耗

- JUC 包含哪些核心包?
  - 并发工具类（Thread Utilities / Synchronizers）
    - CountDownLatch 允许一个或多个线程等待其他线程完成操作。
    - CyclicBarrier 让一组线程互相等待，直到到达屏障点。
    - Semaphore 控制同时访问资源的线程数量。
    - Exchanger 两个线程之间交换数据。
    - Phaser 灵活的分阶段线程同步器，比 CyclicBarrier 更强大。
  - 锁与同步（Locks）
    - ReentrantLock：可重入互斥锁。
    - ReentrantReadWriteLock：读写锁，允许多个线程读或单个线程写。
    - StampedLock：支持乐观读锁、写锁等。
    - LockSupport：线程阻塞和唤醒工具。
    - Condition：配合 Lock 使用的等待/通知机制。
  - 并发集合（Concurrent Collections）
    - ConcurrentHashMap：线程安全的哈希表。
    - ConcurrentSkipListMap / ConcurrentSkipListSet：线程安全的跳表实现。
    - CopyOnWriteArrayList / CopyOnWriteArraySet：写时复制的集合，适合读多写少场景。
    - BlockingQueue 接口及实现类：ArrayBlockingQueue、LinkedBlockingQueue、PriorityBlockingQueue、DelayQueue、SynchronousQueue 等。
  - 原子操作（Atomic Variables）
    - AtomicInteger / AtomicLong / AtomicBoolean
    - AtomicReference / AtomicReferenceArray / AtomicMarkableReference / AtomicStampedReference
  - 线程池与任务执行（Executors）
    - Executor / ExecutorService / ScheduledExecutorService：线程池和任务提交接口。
    - ThreadPoolExecutor / ScheduledThreadPoolExecutor：线程池具体实现。
    - Executors 工厂类：提供常用线程池创建方法。
    - Future / FutureTask / Callable / Runnable：任务提交与返回结果。
  - 并发工具方法
    - ForkJoinPool：分治任务的线程池实现。
    - RecursiveTask / RecursiveAction：Fork/Join 框架的任务。
    - TimeUnit：时间单位枚举，方便线程睡眠和超时控制。


- 线程的创建方式有哪些 
  - 继承 Thread 类
    - 直接继承 Thread 并重写 run() 方法。
    - 调用 start() 方法会自动启动新线程并执行 run()。
    - 缺点： Java 不支持多继承，继承 Thread 后不能再继承其他类。
  - 实现runnable接口
    - 把任务逻辑和线程对象分离，更符合面向对象思想。
    - 可以共享同一个 Runnable 对象，实现多线程共享资源。
  - 使用 匿名内部类 或 Lambda 表达式
    - 实际底层还是实现了 Runnable。
  - 实现 Callable 接口 + FutureTask
    - 如果你需要 线程有返回值 或 抛出异常，必须使用 Callable。



- 怎么保证a，b两个线程顺序执行
  - 使用 Thread.join()
    - join() 会让当前线程等待目标线程执行完成。
    ```java
        public class Main {
        public static void main(String[] args) throws InterruptedException {
            Thread a = new Thread(() -> {
                System.out.println("A 开始执行");
                try { Thread.sleep(1000); } catch (InterruptedException ignored) {}
                System.out.println("A 执行结束");
            });

            Thread b = new Thread(() -> {
                System.out.println("B 开始执行");
                System.out.println("B 执行结束");
            });

            a.start();    // 启动A
            a.join();     // 等待A执行完毕
            b.start();    // 再启动B
        }
    }

    ```
  - 使用 CountDownLatch
    - CountDownLatch 内部有一个计数器。
    - b 调用 await() 时阻塞。
    - 当 a 调用 countDown() 后计数器为 0，b 解除阻塞执行。  

  - 使用 Future / ExecutorService
    - Future.get() 会阻塞直到任务完成，因此可以确保 A 完成后再执行 B。
    ```java
        import java.util.concurrent.*;

    public class Main {
        public static void main(String[] args) throws Exception {
            ExecutorService executor = Executors.newFixedThreadPool(2);

            Future<?> futureA = executor.submit(() -> {
                System.out.println("A 执行中...");
                try { Thread.sleep(1000); } catch (InterruptedException ignored) {}
                System.out.println("A 执行完毕");
            });

            // 等待A执行完再执行B
            futureA.get();
            executor.submit(() -> System.out.println("B 执行中...")).get();

            executor.shutdown();
        }
    }
 
    ```

  - 使用 ReentrantLock + Condition
    - B调用lock.Lock()后执行condition.await()。
    - A执行完后调用condition.signal()唤醒B。

  - 只有lock不行
  ```
    public class test3 {

            static Lock lock = new ReentrantLock();

            public static void main(String[] args) {
                Thread a = new Thread(() -> {
                    lock.lock();
                    try {
                        System.out.println("A 执行中...");
                        Thread.sleep(1000);


                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    } finally {
                        lock.unlock();
                    }
                });

                Thread b = new Thread(() -> {
                    lock.lock();
                    try {

                        System.out.println("B 执行中...");
                    }
                    finally {
                        lock.unlock();
                    }
                });


                a.start();
                b.start();

        }

    }

  ```
  - 如这段代码，a和b线程虽然启动顺序是a先b后，但是lock锁并不能保证a先执行完再执行b，start() 只是通知 JVM 调度器去启动线程；实际上 A、B 何时真正运行 是由操作系统线程调度决定的；


- 线程池原理及拒绝策略
  - 介绍一下线程池的原理
    - 线程池设定了核心线程数，和最大线程数，如果任务进来
      - 核心线程没有满，就新建核心线程执行任务
      - 如果核心线程满了，则放入阻塞队列，阻塞队列中的任务等待核心线程空闲后执行
        - 如果阻塞队列满了，如果没有达到最大线程数，就要新建线程执行新提交的任务（注意不是队列里的）
          - 如果达到了最大线程数，就要执行拒绝策略
  - 线程池的参数
    - corePoolSize：线程池核心线程数量。默认情况下，线程池中线程的数量如果 <= corePoolSize，那么即使这些线程处于空闲状态，那也不会被销毁。
    - maximumPoolSize：限制了线程池能创建的最大线程总数（包括核心线程和非核心线程），当 corePoolSize 已满 并且 尝试将新任务加入阻塞队列失败（即队列已满）并且 当前线程数 < maximumPoolSize，就会创建新线程执行此任务，但是当 corePoolSize 满 并且 队列满 并且 线程数已达 maximumPoolSize 并且 又有新任务提交时，就会触发拒绝策略。
    - keepAliveTime：当线程池中线程的数量大于corePoolSize，并且某个线程的空闲时间超过了keepAliveTime，那么这个线程就会被销毁。
    - unit：就是keepAliveTime时间的单位。
    - workQueue：工作队列。当没有空闲的线程执行新任务时，该任务就会被放入工作队列中，等待执行。
    - threadFactory：线程工厂。可以用来给线程取名字等等
    - handler：拒绝策略。当一个新任务交给线程池，如果此时线程池中有空闲的线程，就会直接执行，如果没有空闲的线程，就会将该任务加入到阻塞队列中，如果阻塞队列满了，就会创建一个新线程，从阻塞队列头部取出一个任务来执行，并将新任务加入到阻塞队列末尾。如果当前线程池中线程的数量等于maximumPoolSize，就不会创建新线程，就会去执行拒绝策略
  - 线程池工作队列满了有哪些拒绝策略？
    - CallerRunsPolicy，使用线程池的调用者所在的线程去执行被拒绝的任务，除非线程池被停止或者线程池的任务队列已有空缺。
    - AbortPolicy，直接抛出一个任务被线程池拒绝的异常。
    - DiscardPolicy,不做任何处理，静默拒绝提交的任务
    - DiscardOldestPolicy，抛弃最老的任务，然后执行该任务。
    - 自定义拒绝策略
  - 阻塞队列有哪些
    - 有界队列
      - 基于数组实现
      - 有固定大小
      - 可选 公平/非公平 锁；
      - 常用于需要限制队列大小的场景，防止内存溢出。
    -  LinkedBlockingQueue
      - 基于 链表 实现；
      - 默认容量为 Integer.MAX_VALUE（几乎无界）
      - 可通过构造函数指定容量。
      - 因为几乎无界，用于高并发场景，吞吐量高。
    - PriorityBlockingQueue
      - 无界优先级队列
      - 元素按 自然顺序 或 Comparator 排序；
      - 不保证 FIFO 顺序。
      - 内部使用 堆结构（PriorityQueue）。
      - 适合需要优先级处理的任务场景。
    - DelayQueue
      - 基于 PriorityQueue 实现；
      - 队列中的元素必须实现 Delayed 接口；
      - 只有到期（延时结束）的元素才能被取出。
      - 适合定时任务、缓存过期等场景。
    - SynchronousQueue
      - 容量为 0 的队列；
      - 每次 put() 必须等待一个 take()；
      - 不能缓存元素。
      - 适合直接交付任务的场景，如线程池中的直连交付。
    -  LinkedBlockingDeque
      - 双向链表实现的 双端阻塞队列；
      - 支持在队头、队尾插入/移除；
      - 适合需要双端操作的场景，如工作窃取算法。
    - LinkedTransferQueue
      - 无界的 高性能队列；
      - 支持 直接传递（transfer） 给消费者；
      - 性能优于 LinkedBlockingQueue；
      - 内部基于 CAS + 链表；
      - 常用于高并发场景。

- 如何创建线程池
  - 使用 Executors 工具类
    ```java 
    ExecutorService pool = Executors.newFixedThreadPool(10);
    ```
    - Executors 默认使用的队列往往是 无界队列容易导致溢出
  - 手动创建 ThreadPoolExecutor
    ```java
      ThreadPoolExecutor pool = new ThreadPoolExecutor(
      corePoolSize,        // 核心线程数
      maximumPoolSize,     // 最大线程数
      keepAliveTime,       // 非核心线程空闲存活时间
      TimeUnit.SECONDS,    // 时间单位
      new ArrayBlockingQueue<>(100), // 阻塞队列
      Executors.defaultThreadFactory(), // 线程工厂
      new ThreadPoolExecutor.AbortPolicy() // 拒绝策略
  );
 
    ```
  - CPU 密集型任务 	核心线程数 = CPU 核数 + 1
  - IO 密集型任务 	核心线程数 = 2 × CPU 核数

- Java常用线程池哪些？
  - 线程池的核心类：ThreadPoolExecutor,所有线程池的本质都是这个类：
  - 常用线程池类型（Executors 工厂方法）
    - 固定线程数线程池，固定 n 个核心线程，任务多时排队等待
    - 单线程线程池，只有一个线程，顺序执行任务
    - 缓存线程池，线程数不固定，可自动回收空闲线程
    - 定时任务线程池，定时或周期性任务执行
    - 单线程定时任务池，单线程版本的定时线程池
  - 自定义线程池（推荐方式）阿里巴巴《Java开发手册》不建议直接使用 Executors 创建线程池，因为容易出现 资源耗尽（OOM） 风险

- 线程池和直接NEW线程的区别是什么
  - 直接 new Thread() = 每次都新建线程，用完就扔。
  - 线程池 = 创建一组可复用线程，任务结束后线程不会销毁，而是留着继续执行其他任务。
  - 性能差异
    - 直接 new 线程：频繁创建和销毁线程，开销大，性能低。
    - 线程池：线程复用，减少创建销毁开销，性能更好。
  - 资源管理
    - 直接 new 线程：无法控制线程数量，可能导致资源耗尽。
    - 线程池：可以设置最大线程数，合理利用系统资源。
  - 任务调度  
    - 直接 new 线程：任务提交后立即执行，无法排队。
    - 线程池：可以使用阻塞队列排队任务，按顺序执行。
  - 系统稳定性
    - 直接 new 线程：大量线程可能导致系统不稳定。
    - 线程池：通过限制线程数，提高系统稳定性。
  - 代码维护
    - 直接new线程：代码分散，难以维护。
    - 线程池：集中管理线程，代码更清晰易维护。 


- JVM内存模型
  - JVM的内存结构主要分为以下几个部分：
    - 程序计数器：可以看作是当前线程所执行的字节码的行号指示器，用于存储当前线程正在执行的 Java 方法的 JVM 指令地址。如果线程执行的是 Native 方法，计数器值为 null。是唯一一个在 Java 虚拟机规范中没有规定任何 OutOfMemoryError 情况的区域，生命周期与线程相同。
    - Java 虚拟机栈：每个线程都有自己独立的 Java 虚拟机栈，生命周期与线程相同。每个方法在执行时都会创建一个栈帧，用于存储局部变量表、操作数栈、动态链接、方法出口等信息。可能会抛出 StackOverflowError 和 OutOfMemoryError 异常。
    - 本地方法栈：与 Java 虚拟机栈类似，主要为虚拟机使用到的 Native 方法服务，在 HotSpot 虚拟机中和 Java 虚拟机栈合二为一。本地方法执行时也会创建栈帧，同样可能出现 StackOverflowError 和 OutOfMemoryError 两种错误。
    - Java 堆：是 JVM 中最大的一块内存区域，被所有线程共享，在虚拟机启动时创建，用于存放对象实例。从内存回收角度，堆被划分为新生代和老年代，新生代又分为 Eden 区和两个 Survivor 区（From Survivor 和 To Survivor）。如果在堆中没有内存完成实例分配，并且堆也无法扩展时会抛出 OutOfMemoryError 异常。
    - 方法区（元空间）：在 JDK 1.8 及以后的版本中，方法区被元空间取代，使用本地内存。用于存储已被虚拟机加载的类信息、常量、静态变量等数据。虽然方法区被描述为堆的逻辑部分，但有 “非堆” 的别名。方法区可以选择不实现垃圾收集，内存不足时会抛出 OutOfMemoryError 异常。
    - 运行时常量池：是方法区的一部分，用于存放编译期生成的各种字面量和符号引用，具有动态性，运行时也可将新的常量放入池中。当无法申请到足够内存时，会抛出 OutOfMemoryError 异常。
    - 直接内存：不属于 JVM 运行时数据区的一部分，通过 NIO 类引入，是一种堆外内存，可以显著提高 I/O 性能。直接内存的使用受到本机总内存的限制，若分配不当，可能导致 OutOfMemoryError 异常。

- 字符串常量池在哪
  - JDK 6 及以前在永久代 
  - JDK 7及以后在堆，jdk8以后永久代删除
  - 为什么从永久代移到堆
    - 在 JDK 6 时，字符串常量池放在永久代，容易导致：
      - 类加载多、字符串常量多时，永久代溢出（OOM: PermGen space）
      - 回收效率差，因为永久代由 Full GC 才能清理
    - JDK 7 把它挪到堆中，带来好处：
      - 堆空间更大、可调节；
      - GC 更灵活（年轻代 GC、CMS、G1 都能处理字符串对象）；
      - 避免因字符串过多导致永久代溢出。


- 堆的结构：新生代（Young Gen） + 老年代（Old Gen） 
  - 新生代是 大多数新对象 被创建的地方。它又分为三块：
    - Eden 区：新对象首先分配在这里。当 Eden 区满时，会触发 Minor GC，将存活的对象移动到 Survivor 区。
    - Survivor 区：分为 From Survivor（S0） 和 To Survivor（S1） 两个区域。
      - S0	存放上次 GC 后仍然存活的对象
      - S1 轮流作为目标 Survivor 区，存放从 Eden/S0 复制过来的对象
    - 比例默认约为 8:1:1（可通过 -XX:SurvivorRatio=8 调整）。
  - Minor GC 流程
    - 对象创建在 Eden；
    - 当Eden区满时，会触发一次Minor GC（新生代垃圾回收）。 Stop-The-World
    - GC 会扫描
      - 存活下来的对象会被移动到其中一个Survivor空间,存活次数（Age）+1
      - 这两个区域轮流充当对象的中转站，帮助区分短暂存活的对象和长期存活的对象。
    - 若对象在多次 Minor GC 后仍然存活（超过 MaxTenuringThreshold 次，默认15），则晋升到 老年代； 
    - 老年代中的对象生命周期较长，因此Major GC（也称为Full GC，涉及老年代的垃圾回收）发生的频率相对较低，但其执行时间通常比Minor GC长。Stop-The-World
  - 对象晋升机制（Tenuring）
    - 每个对象在 Survivor 区都会有一个“年龄（Age）”计数器：
      - 每经历一次 Minor GC 并存活下来，Age +1；
      - 当 Age ≥ MaxTenuringThreshold 时，晋升到老年代；
      - 也可能因为 Survivor 区空间不足而提前晋升（称为“空间担保”）。
  -     大对象区（Large Object Space / Humongous Objects）:在某些JVM实现中（如G1垃圾收集器），为大对象分配了专门的区域，称为大对象区或Humongous Objects区域。大对象是指需要大量连续内存空间的对象，如大数组。这类对象直接分配在老年代，以避免因频繁的年轻代晋升而导致的内存碎片化问题。

- Survival区可以怎么优化
  - Survivor 区（又叫 Survival 区，S0/S1） 是新生代（Young Generation）的一部分，用来在 Minor GC 时保存从 Eden 区“幸存”的对象。
  - 优化 Survival 区的意义在于：减少对象过早晋升到老年代（Old Gen），从而减轻 Full GC 压力。
  - 优化方向一：调整 Survivor 区大小比例
    - -XX:SurvivorRatio=8
    - 表示 Eden : Survivor = 8 : 1 : 1
    - 即新生代共 10 份，Eden 占 8，两个 Survivor 各占 1。
    - 默认是 8，可以适当调大或调小：
    - Survivor 太小会导致对象直接晋升老年代
    - Survivor 太大造成 Eden 区浪费、GC 频繁
  - 优化方向二：控制对象晋升阈值（Tenuring）
    - -XX:MaxTenuringThreshold=15
    - 对象在 Survivor 区经历几次 GC 后会晋升老年代。
    - 默认 15（最大值），有些 GC（如 G1）会自动调整。
    - 短命对象多（大量瞬时对象）设小一点，比如 3~5快速回收这些对象
    - 中等生命周期对象多设大一点，比如 10~15	延迟晋升，减少老年代压力
  - 优化方向三：启用动态年龄判定机制
    - JVM 可能根据 Survivor 的使用情况自动调整对象晋升年龄：
    - -XX:+UseAdaptiveSizePolicy
  - 为什么短命对象多要设置“小阈值”
    - 短命对象虽然很快会死，但：
      - 它们第一次 GC 幸存下来（复制进 Survivor）
      - 第二次 GC 又被扫描、复制
      - 反复经历多次 Survivor→Survivor 的拷贝
      - 每次都要复制存活对象、扫描引用，浪费 CPU。
    - 当阈值小（比如 3）
      - 对象最多经历 3 次 Minor GC；
      - 很多中期对象在第 3 次就晋升老年代；
      - 短命对象在 1~2 次 GC 内就会被清理，不会反复复制。降低 Minor GC 停顿时间，提升吞吐量



- 元空间参与垃圾回收吗，回收什么
  - 参与，但方式不同于 Java 堆。
  - 元空间中的对象（例如类元数据）不是 GC 的主要目标，因为它们只有在类被卸载时才可能被清理。
  - 当类被卸载（class unloading）时，其对应的元数据才会被 GC 释放。
  - 也就是说：元空间的回收实质上是类卸载的过程。
  - 什么情况下类会被卸载？
    - 该类的所有实例都被回收；
    - 加载该类的 ClassLoader 被回收；
    - 没有任何地方再引用该 Class 对象。
  - 元空间回收的具体内容
    - 类的元数据（metadata）
    - 方法信息（method info）
    - 字段信息（field info）
    - 常量池
    - 方法表、接口表
    - 运行时注解信息
    - ClassLoader 相关的元数据


- MAJORGC和FULLGC不一样
  - MAJORGC只清理老年代
  - FULLGC清理整个堆，包括新生代和老年代，有时还包括方法区
  #image("Screenshot_20251026_223852.png")

- 垃圾回收算法
  - 标记清除 
    - old 
    - 简单
    - 碎片多
    - 从GCroot开始，标记所有可达的对象， 清除所有没有被标记的对象
  - 标记整理 
    - old 
    - 移动成本高
    - 避免碎片
    - 在标记清除上改进，标记存活对象，将存活对象往一端移动
  - 复制算法 
    - young 
    - 无碎片，效率高 
    - 空间浪费一半 
    - 将内存分为两块（From 和 To）；每次只使用其中一块；回收时，把存活对象复制到另一块，然后清空旧区。
  - 分代收集 
    - 高性能  
    - 实现复杂
    - 划分为新生代，老年代，元空间
    - 新生代minorGC回收 Eden + Survivor，老年代fullgc或majorgc全堆标记整理（非常慢），Mixed GC（G1）“混合回收”一部分老年代（高垃圾比例的 Region）+ 新生代的所有 Region。

- 判断垃圾算法
  - 引用计数算法
    - 每个对象都有一个引用计数器；
    - 每当有一个地方引用它，计数 +1；
    - 引用失效时，计数 -1；
    - 当计数变为 0 时，对象被认为是垃圾。
    - 缺点：
      - 无法处理循环引用问题：A -> B, B -> A  相互引用，引用计数都不为0，但都不可达
      - 多线程下计数操作成本高。
      - 维护计数器开销大；
  - 可达性分析算法
    - 从一组称为 GC Roots（根对象） 的起始点出发；
    - 通过引用关系向下搜索；
    - 能被 GC Roots 直接或间接引用 的对象为“存活对象”；
    - 没被连接到任何 GC Roots 的对象被视为“垃圾”。
    - GC Roots 通常包括：
      - 虚拟机栈中引用的对象（局部变量等）；
      - 方法区中静态变量引用的对象；
      - JNI 引用的对象（native 方法）；
      - 活动线程对象本身。
    - 被标记为“不可达”并不一定马上回收，GC 会再做两次判断：
      - 是否覆写了 finalize() 方法；
      - 如果有，则会给它一次“自救”的机会（即在 finalize() 中重新建立引用）；
      - 如果仍然不可达，则被认定为真正的垃圾。
    - 即使对象“不可达”，也可能暂时被保留，例如：
      - 被 SoftReference / WeakReference 引用；
        - 软引用（SoftReference） 
          - 内存不足时回收
        - 弱引用（WeakReference）
          - 下一次 GC 就回收
        - 虚引用（PhantomReference）
          - 随时可回收，不可直接访问对象  
      - 处于老年代，GC 未触发；
      - 仍在 finalize() 执行期间。
 


- 垃圾收集器
  - Serial收集器（复制算法): 新生代单线程收集器，标记和清理都是单线程，优点是简单高效；
  - ParNew收集器 (复制算法): 新生代收并行集器，实际上是Serial收集器的多线程版本，在多核CPU环境下有着比Serial更好的表现；
    - 注重响应速度，降低停顿时间，适合交互式应用
  - Parallel Scavenge收集器 (复制算法): 新生代并行收集器，追求高吞吐量，高效利用 CPU。吞吐量 = 用户线程时间/(用户线程时间+GC线程时间)，高吞吐量可以高效率的利用CPU时间，尽快完成程序的运算任务，适合后台应用等对交互相应要求不高的场景；
    - 注重高吞吐量，但是停顿长，适合计算密集型任务
  - Serial Old收集器 (标记-整理算法): 老年代单线程收集器，Serial收集器的老年代版本；
  - Parallel Old收集器 (标记-整理算法)： 老年代并行收集器，吞吐量优先，Parallel Scavenge收集器的老年代版本；
  - CMS(Concurrent Mark Sweep)收集器（标记-清除算法）： 老年代并行收集器，以获取最短回收停顿时间为目标的收集器，具有高并发、低停顿的特点，追求最短GC回收停顿时间。
  - G1(Garbage First)收集器 (标记-整理算法)： Java堆并行收集器，G1收集器是JDK1.7提供的一个新收集器，G1收集器基于“标记-整理”算法实现，也就是说不会产生内存碎片。此外，G1收集器不同于之前的收集器的一个重要特点是：G1回收的范围是整个Java堆(包括新生代，老年代)
  - 以上垃圾收集器的标记都采用位图
  - ZGC
    -  传统 GC 问题
      - 传统 GC（如 G1）在标记对象时，需要额外的“标记位图”；
      - 复制对象后，必须“Stop The World”修正所有引用；
      - 堆越大，停顿越久
    - ZGC 的做法
      - ZGC 把“标记信息”直接放在 对象指针的高位 上（称为 染色指针）：
        - bit 0~42 实际内存地址
        - bit 43~45 GC 标记状态（颜色）
        - bit 46~63 	元数据（代信息、压缩状态等）
      - 这样，JVM 不需要停止程序去修正指针，而是通过读取染色位就知道对象状态。    
      #image("Screenshot_20251026_225201.png")
      #image("Screenshot_20251026_225704.png")
      - 优点： 
        - 所有对象引用都能被快速判断；
        - 对象移动、标记、重定位都可 并发进行；
        - 极大降低 STW 停顿时间。
    - 工作流程 
      - 并发标记（Concurrent Mark）
        - 扫描对象图，标记存活对象；
        - 与应用线程并发运行；
        - 利用染色指针来标识对象状态。
      - 并发重分配准备
        - 计算哪些区域可以压缩；
        - 构建移动计划
        - 不阻塞用户线程。
      - 并发重分配（Relocate）
        - 将活跃对象移动到新的内存区域；
        - 更新染色指针；
        - 所有对象引用更新也可并发执行。
      - 短暂的停顿阶段
        - 在阶段切换时会有极短暂停；用于同步根对象、更新线程栈等。
      #image("Screenshot_20251026_224954.png")

- Shenandoah 
  - 并发标记整理
  - 在移动后会在原地址留下一个“前向指针”（Forwarding Pointer），指向新地址；
  - 应用线程访问对象时，如果发现前向指针，就会跳转到新地址；
  - 这样，应用线程可以并发访问对象，无需停顿等待

- CMS的垃圾回收流程
  - CMS 的 GC 流程分为 四个阶段，其中 并发阶段 是 CMS 的核心。
  - 阶段 1：初始标记（Initial Mark）
    - 类型：STW（Stop-The-World）停顿阶段
    - 作用：标记 GC Roots 直接可达的对象。
    - 特点：只标记根节点直接引用的对象，耗时很短。
    - 停顿原因：必须暂停用户线程来保证标记准确。
  - 阶段 2：并发标记（Concurrent Mark）
    - 类型：并发阶段，用户线程继续运行
    - 作用：从初始标记阶段标记的对象出发，递归标记整个可达对象图。扫描对象引用，标记所有可达对象。
    - 特点：与应用线程并发执行，时间相对较长，可能产生 浮动对象（应用线程创建的新对象未被标记）
  - 阶段 3：重新标记（Remark）
    - 类型：STW 停顿阶段
    - 作用：处理 并发标记阶段产生的浮动对象（并发阶段用户线程可能修改了对象引用），最终修正标记结果，保证标记准确。
    - 特点：停顿时间比初始标记稍长，但仍比 Full GC 短。只处理少量的对象，因此停顿较短。
  - 阶段 4：并发清理（Concurrent Sweep）
    - 类型：并发阶段
    - 作用：扫描整个老年代，将 未被标记的对象 回收。回收空间给新的对象使用。
    - 特点：与应用线程并发执行，回收完成后，堆中可能产生 内存碎片，CMS 默认不压缩。
  - CMS 的注意点
    - 浮动垃圾：
      - 并发标记阶段用户线程可能创建对象或修改引用，会产生 少量浮动垃圾。
      - Remark 阶段处理大部分浮动垃圾，但可能仍有微量垃圾未及时回收。
    - 内存碎片：
      - CMS 默认 不压缩老年代，可能因为碎片导致无法分配大对象。
      - 当碎片严重时，可能触发 Full GC（Stop-The-World）进行压缩。
    - CPU 使用率：
      - 并发阶段占用 CPU，与应用线程竞争，可能影响应用性能。
    - 为什么新创建对象可能无法标记
    #image("Screenshot_20251021_154545.png")
    



- 堆外内存
  - 堆外内存的特点
    - 不受 GC 管理，不参与垃圾回收，避免 GC 停顿对大对象的影响
    - 手动释放，使用 Cleaner 或 free 方法手动释放，否则可能内存泄漏
    - 访问速度快，避免堆内对象的复制，直接操作系统内存，尤其适合 I/O 或网络传输
    - 适用场景，大缓存（如 Redis、Netty ByteBuf）、内存映射文件、零拷贝 I/O、高性能系统
  - 堆外内存的用途
    - 减少 GC 压力
      - 大对象或大量临时对象如果放在堆上，会频繁触发 GC。
      - 将它们放在堆外，GC 不会扫描这些对象，减少 Full GC 停顿。
    - 零拷贝 I/O
      - 网络通信或文件读写时，堆外内存可以直接映射系统内存，减少数据复制，提高性能。
        - 传统 I/O 为什么“慢”
          - 假设我们要把一个文件发送到网络（比如发送给浏览器）
            - 有四次“拷贝”
              - 文件 → 内核缓冲区（DMA 读）
              - 内核缓冲区 → JVM 堆内存（read() 调用）
              - JVM 堆内存 → 内核 Socket 缓冲区（write() 调用）
              - Socket 缓冲区 → 网卡（DMA 发送）
            - 每次调用 read/write 都会在 内核空间 和 用户空间（JVM） 之间复制数据；
            - 数据量大时，CPU 拷贝负担很重；
        - 零拷贝（Zero-Copy）怎么优化这个过程？
          - 让操作系统自己在内核空间直接传递数据，不经过 JVM 堆。
          - 堆外内存映射的是操作系统的物理内存；
          - I/O 读写可以直接在内核态和这块堆外内存之间传输，不再复制到 JVM 堆。

    - 缓存
      - 高性能缓存（如 Netty、DirectByteBuffer、Off-Heap Map）可以使用堆外内存，避免堆内大对象造成 GC 压力。
        - 堆外缓存（Off-Heap Cache）为什么更高效？
          - 如果你用 HashMap\<String, byte[]> 存放缓存对象，那这些对象（key、value、byte[]）全在 堆内，对象多、数据大，GC 会非常频繁（特别是 Full GC）。
        - 把缓存放到堆外JVM 不再扫描这些数据；

- 方法区中方法执行过程
  - 解析方法调用：JVM会根据方法的符号引用找到实际的方法地址（如果之前没有解析过的话）。
  - 栈帧创建：在调用一个方法前，JVM会在当前线程的Java虚拟机栈中为该方法分配一个新的栈帧，用于存储局部变量表、操作数栈、动态链接、方法出口等信息。
  - 执行方法：执行方法内的字节码指令，涉及的操作可能包括局部变量的读写、操作数栈的操作、跳转控制、对象创建、方法调用等。
  - 返回处理：方法执行完毕后，可能会返回一个结果给调用者，并清理当前栈帧，恢复调用者的执行环境。
  #image("Screenshot_20251018_112259.png")



- JMM
  - JMM 是 线程之间如何共享变量、保证可见性与有序性 的抽象模型。它属于“并发语义”层面的内存模型，不等同于上面的运行时内存结构。
  - 主要关注三件事：
    - 可见性：一个线程对共享变量的修改，能否被其他线程看到。
    - 原子性：一个操作是否是不可分割的。
    - 有序性：程序执行的顺序是否与代码顺序一致。
  - JMM 定义了 主内存（Main Memory） 和 工作内存（Working Memory）：
    - 主内存：存放所有共享变量。
    - 工作内存：每个线程都有一份主内存的拷贝（缓存），线程对变量的操作必须先在工作内存中进行，然后同步回主内存。

- 用户线程与内核线程
  - 用户线程
    - 由用户空间的线程库（如 Java 的线程库、POSIX pthread 等）管理，操作系统内核对此 并不感知。
    - 用户线程的创建、调度、销毁等都是由 用户态代码 完成的，不需要系统调用。
    - 用 Java 创建 new Thread() 或 Python 的 threading.Thread()，实际上对应的是用户线程层面的抽象。
  - 内核线程（Kernel Thread, KLT）
    - 由操作系统内核直接管理。
    - 内核会为每个内核线程分配 内核栈、线程控制块（TCB），并参与调度（即由操作系统调度器负责运行）。
    - 创建、销毁、上下文切换都要经过 系统调用。
  - 用户线程和内核线程的映射模型
    - 1:1 模型 	每个用户线程对应一个内核线程。
    - N:1 模型  多个用户线程映射到同一个内核线程，由用户线程库调度。
    - M:N 模型  M 个用户线程映射到 N 个内核线程（混合模型）。
  - JAVA是哪种模型
    - Java 的线程在现代 JVM（HotSpot）中采用 1:1 模型：
    - 优点：多核利用率高；
    - 缺点：线程数量受系统资源限制（通常几千~上万线程后就不行了）。


- java编译和运行流程
  - 编写源码
    - 你写一个 Java 文件，例如 HelloWorld.java
    - 这一步生成的是 源代码文件，扩展名是 .java。
  - 编译（Compile）
    - 使用 Java 编译器 javac：  javac HelloWorld.java
    - 发生的事情：
      - 词法分析（Lexical Analysis）将源码拆分成一个个 token（关键字、标识符、符号等）。
      - 语法分析（Syntax Analysis）根据 Java 语法规则生成 抽象语法树（AST）。
      - 语义分析（Semantic Analysis）检查类型、方法调用、变量声明等是否合理。
      - 生成字节码（Bytecode） 编译器将 AST 转换为 Java 字节码，存储在 .class 文件中。每个类对应一个 .class 文件，例如 HelloWorld.class。
    - .class 文件是与平台无关的中间代码。
    - 可以在任何安装了 JVM 的平台上运行。
  - 类加载（Class Loading）
    - 当你运行程序时：java HelloWorld
    - JVM 会做的事情：
      - 加载类（Loading）
        - ClassLoader 读取 .class 文件，加载到内存中。
      - 连接（Linking）
        - 验证（Verification）：确保字节码合法，不破坏内存安全。
        - 准备（Preparation）：为类的静态变量分配内存并赋默认值。
        - 解析（Resolution）：将符号引用转为直接引用。
      - 初始化（Initialization）
        - 为静态变量赋初始值，执行静态代码块。
  - 运行
    - JVM 的 执行引擎（Execution Engine） 运行字节码：
      - 解释执行（Interpreter）
        - JVM 逐条解释字节码执行。
      - 即时编译（JIT, Just-In-Time Compiler）
        - 将热点代码编译为本地机器码，提高性能。


- 类加载流程
  - 类从被加载到虚拟机内存开始，到卸载出内存为止，它的整个生命周期包括以下 7 个阶段：
    - 加载：通过类的全限定名（包名 + 类名），获取到该类的.class文件的二进制字节流，将二进制字节流所代表的静态存储结构，转化为方法区运行时的数据结构，在内存中生成一个代表该类的Java.lang.Class对象，作为方法区这个类的各种数据的访问入口
    - 连接：验证、准备、解析 3 个阶段统称为连接。 
      - 验证：确保class文件中的字节流包含的信息，符合当前虚拟机的要求，保证这个被加载的class类的正确性，不会危害到虚拟机的安全。验证阶段大致会完成以下四个阶段的检验动作：文件格式校验、元数据验证、字节码验证、符号引用验证
        - 文件格式校验是验证 .class 文件最基础的一步，主要用于 确保文件整体结构符合 JVM 规范，防止非法或损坏的文件被加载。
          - 魔数（Magic Number）检查文件前 4 个字节是否为 0xCAFEBABE。
          - 版本号合法性检查，是否在 JVM 支持的版本范围内
          - 常量池长度检查
        - 元数据验证就是 检查类结构、字段、方法和继承信息的合法性，保证：
          - 类的继承关系正确
          - 方法和字段合法
          - 访问权限安全
          - 常量池引用有效
        - 字节码验证就是在 逻辑上模拟 JVM 执行字节码，确保
          - 指令是合法的
          - 操作数类型正确
          - 栈操作安全
          - 控制流合法性 也就是检查跳转指令（goto, if, tableswitch, lookupswitch）是否安全：
            - 确定跳转目标在方法范围内。
            - 不会跳出方法边界。
            - 局部变量类型在跳转后仍然一致。
      - 准备：为类中的静态字段分配内存，并设置默认的初始值，比如int类型初始值是0。被final修饰的static字段不会设置，因为final在编译的时候就分配了
      - 解析阶段是虚拟机将常量池的「符号引用」直接替换为「直接引用」的过程。符号引用是以一组符号来描述所引用的目标，符号可以是任何形式的字面量，只要使用的时候可以无歧义地定位到目标即可。直接引用可以是直接指向目标的指针、相对偏移量或是一个能间接定位到目标的句柄，直接引用是和虚拟机实现的内存布局相关的。如果有了直接引用， 那引用的目标必定已经存在在内存中了。

    - 初始化：初始化是整个类加载过程的最后一个阶段，初始化阶段简单来说就是执行类的构造器方法（() ），执行类中定义的 静态代码块 和 静态变量的赋值语句。，要注意的是这里的构造器方法()并不是开发者写的，而是编译器自动生成的。
    - 使用：使用类或者创建对象
    - 卸载：一个类要被JVM卸载，条件非常苛刻，需要同时满足以下三点： 
      - 该类所有的实例都已经被回收：这是最显而易见的前提。如果堆中还存在这个类的任何一个实例对象，那么定义这个对象的Class对象肯定不能被卸载。
      - 加载该类的ClassLoader已经被回收：这是最关键也是最难满足的条件。类与其加载器是双向绑定的共生关系。一个类由哪个类加载器加载，这个信息是存储在Class对象里的。要卸载一个类，必须先卸载加载它的类加载器。
      - 类对应的Java.lang.Class对象没有任何地方被引用：不能在任何地方通过反射（如静态字段、全局变量）、静态变量、JNI等途径引用到这个Class对象。一旦这个Class对象还存在强引用，GC就不会回收它，那么这个类也就不会被卸载。

- 类加载器与双亲委派机制
  - 类加载器有哪些？
    - 启动类加载器（Bootstrap Class Loader）：这是最顶层的类加载器，负责加载Java的核心库（如位于jre/lib/rt.jar中的类），它是用C++编写的，是JVM的一部分。启动类加载器无法被Java程序直接引用。
    - 扩展类加载器（Extension Class Loader）：它是Java语言实现的，继承自ClassLoader类，负责加载Java扩展目录（jre/lib/ext或由系统变量Java.ext.dirs指定的目录）下的jar包和类库。扩展类加载器由启动类加载器加载，并且父加载器就是启动类加载器。
    - 系统类加载器（System Class Loader）/ 应用程序类加载器（Application Class Loader）：这也是Java语言实现的，负责加载用户类路径（ClassPath）上的指定类库，是我们平时编写Java程序时默认使用的类加载器。系统类加载器的父加载器是扩展类加载器。它可以通过ClassLoader.getSystemClassLoader()方法获取到。
    - 自定义类加载器（Custom Class Loader）：开发者可以根据需求定制类的加载方式，比如从网络加载class文件、数据库、甚至是加密的文件中加载类等。自定义类加载器可以用来扩展Java应用程序的灵活性和安全性，是Java动态性的一个重要体现。
    - 这些类加载器之间的关系形成了双亲委派模型，其核心思想是当一个类加载器收到类加载的请求时，首先不会自己去尝试加载这个类，而是把这个请求委派给父类加载器去完成，每一层次的类加载器都是如此，因此所有的加载请求最终都应该传送到顶层的启动类加载器中。
    - 只有当父加载器反馈自己无法完成这个加载请求（它的搜索范围中没有找到所需的类）时，子加载器才会尝试自己去加载。
  - JDK 9 是从“包级开发”迈向“模块化系统开发”的分水岭。它用模块取代了扩展机制，优化了性能与结构，从此 JDK 不再是一个“巨大的 rt.jar”，而是由多个可独立加载的模块组成的系统。


  - 双亲委派模型的作用  
    - 保证类的唯一性：通过委托机制，确保了所有加载请求都会传递到启动类加载器，即使 ExtClassLoader 无法加载目标类，它仍然会先把请求传递给父加载器（Bootstrap）。并且每个类在同一个 ClassLoader 中只会被加载一次，避免了不同类加载器重复加载相同类的情况，保证了Java核心类库的统一性，也防止了用户自定义类覆盖核心类库的可能。
    - 保证安全性：由于Java核心库被启动类加载器加载，而启动类加载器只加载信任的类路径中的类，这样可以防止不可信的类假冒核心类，增强了系统的安全性。防止用户自定义与核心类（如 java.lang.String）同名的类，污染 JVM 命名空间例如，恶意代码无法自定义一个Java.lang.System类并加载到JVM中，因为这个请求会被委托给启动类加载器，而启动类加载器只会加载标准的Java库中的类。
    - 支持隔离和层次划分：双亲委派模型支持不同层次的类加载器服务于不同的类加载需求，如应用程序类加载器加载用户代码，扩展类加载器加载扩展框架，启动类加载器加载核心库。这种层次化的划分有助于实现沙箱安全机制，保证了各个层级类加载器的职责清晰，也便于维护和扩展。
    - 简化了加载流程：简化了加载流程：通过委派，大部分类能够被正确的类加载器加载，减少了每个加载器需要处理的类的数量，简化了类的加载过程，每个加载器只负责自己范围内的类，减少复杂性，提高效率
    - 为什么说是「大部分类」而不是「全部类」
    #image("Screenshot_20251018_155925.png")
   

- 介绍threadlocal原理
  - threadlocal内部有一个threadlocalmap
    - Entry
      - key 是一个 弱引用的 ThreadLocal 对象。
      - value 是当前线程保存的具体值。
    - table：存储所有 Entry 的数组。
    - threshold：阈值（扩容时用）。
    - size：当前存储的数量。
  - key为什么是弱引用
    - 如果 ThreadLocal 对象被外部没有强引用持有，GC 就可以回收它；
    - 但是 ThreadLocalMap 里的 Entry 仍然会存在，key 会变成 null（被回收）；
    - 若不清理，会导致 value 无法访问但还在内存中 → 内存泄漏。
  - 因此ThreadLocalMap 有自清理机制：
    - 在每次 set() 或 get() 时，ThreadLocalMap 会自动清理那些key == null 的 Entry；也就是 ThreadLocal 已经被 GC 掉的项。

- redis的zset的底层数据结构？ziplist的作用？hashtable的作用？跳表的作用？
  - Redis 的 ZSet（有序集合） 是由两个核心数据结构共同实现的：
    - hash（字典 / hashtable）
      - 作用：用来根据 成员（member）快速查分值（score）。
      - 场景：当你要执行 ZSCORE key member、ZINCRBY key member 这样的操作时，通过 hash 能快速定位。
    - skiplist（跳表）  
      - 作用：用来根据 分值（score）排序成员，支持范围查询和排名操作。
      - 结构：类似多层链表结构，可以实现有序查找。
      - 时间复杂度：O(logN)。 
  - 底层编码优化：ziplist 与 skiplist 的切换
    - ZSet 有两种编码方式： 
      - ziplist（压缩列表）   
      - skiplist + dict（标准结构）
    - ziplist 的作用（小数据优化）
      - 当 ZSet 中的元素数量较少且每个元素的数据较短时，Redis 会用 ziplist（压缩列表） 存储，以节省内存。
      - ziplist 是一块连续的内存区域。查找和范围操作需要线性遍历 → O(N)。存储顺序：[score][member][score][member]...
      - 使用 ziplist 的条件（默认配置）
        - zset-max-ziplist-entries 128      元素数量小于128
        - zset-max-ziplist-value 64        每个成员长度小于64字节
      - 只要超过这两个阈值，Redis 会自动转成标准结构（dict + skiplist）。
    - skiplist + dict 的作用
      - 当数据量或元素大小超过阈值时：
        - dict：通过 member 查 score
        - skiplist：通过 score 查 member（维持排序）
  - Hashtable 的作用（在 ZSet 内外）
    - 在 ZSet 内：
      - 用来映射 member -> score。
      - 支持 O(1) 查询和更新。
    - 在 Redis 全局：
      - Redis 的所有键值对数据库本身就是一个大 hashtable。
      - 每个 key 都存在于全局的 dict 中（快速查找键名）。
  ```
    ZADD myRank 100 alice
  ZADD myRank 200 bob
  ZADD myRank 150 carol
 
  ```
  - 成员查分值 → 用 hashtable（member → score）分值查成员 → 用 skiplist（score → member），所以跳表在任意水平层都是 按 score 升序排列的。
  - myRank 这个 key 本身 是存放在 Redis 全局的哈希表（dict） 中，它对应的 value 是一个 ZSet 对象（有序集合对象）
  - dict 是 Redis 自己实现的一种哈希表结构，用来存储 “key → value” 的映射关系。
  - Redis 自己实现的 dict，比普通哈希表更复杂一些，因为它支持 渐进式 rehash（扩容）。当 dict 装满到一定比例后，Redis 不会一次性扩容（那样会卡顿），而是采用 渐进式 rehash：
    - 新建一个更大的哈希表 dictht[1]；
    - 每次执行普通操作（如查找 / 插入）时，顺便把一小部分数据搬过去；
    - 搬完所有后，dictht[1] 变成主表，dictht[0] 清空。
  - 在 Redis 或任何哈希表中：每个 key 对应唯一一个 value。你不能让 "myRank" 同时是 String 又是 ZSet；
  - dict 也是 hashmap 格式，数组+链表，但是数组是存储 key-value 结构，索引是 key 通过哈希后分到的位置。
  #image("Screenshot_20251025_104005.png")
  - 为什么不用红黑树？
    - Redis 中一个 score 可能对应多个 member，跳表更容易处理“重复分值”的情况。
    - 跳表实现简单，范围查询更方便（可以顺序遍历）。    

  - 如命令 ZADD myRank 100 alice
    - myRank 是 Redis数据库中的 key，对应一个 ZSET 类型的 value。
    - 内部哈希表的 key 是 ZSET成员名，也就是 alice。内部哈希表的 value 是 指向跳表节点的指针（或早期版本存 score）。



- Redis 的 zset 中删除并重新插入数据的时间复杂度是多少？
  - Redis 的 ZSET 底层是 跳表（skiplist）+ 哈希表 的组合：
  - 删除元素需要
    - 在哈希表中查找元素：O(1)
    - 在跳表中删除元素：O(logN)
  - 插入元素需要
    - 在哈希表中插入元素：O(1)
    - 在跳表中插入元素：O(logN)

- 压缩列表如何保证按score排序的
  - 当你插入新元素时，Redis 会 从头遍历压缩列表，找到 第一个 score 大于目标 score 的位置，然后将新元素插入到这个位置。

- 了解过redis中的spark嘛？
  #image("Screenshot_20251027_164351.png")
  - Spark 是一个基于内存计算的分布式数据处理引擎，设计用于大规模数据处理和分析任务。它提供了高效的内存计算能力，支持多种编程语言（如 Scala、Java、Python 和 R），并且可以与 Hadoop 生态系统无缝集成。
  - Spark 的核心组件包括：
    - Spark Core：提供基本的分布式任务调度、内存管理和容错机制。
    - Spark SQL：用于结构化数据处理，支持 SQL 查询和 DataFrame API。
    - Spark Streaming：用于实时数据流处理。
    - MLlib：机器学习库，提供各种机器学习算法和工具。
    - GraphX：用于图计算和图分析。
  - Spark 的主要特点：
    - 内存计算：通过将数据存储在内存中，Spark 提供了比传统磁盘计算更快的处理速度。
    - 易用性：提供了丰富的 API 和高级抽象，使得开发者可以轻松编写复杂的数据处理任务。
    - 可扩展性：可以在单机模式下运行，也可以扩展到数千个节点的集群。
    - 容错性：通过数据的弹性分布式数据集（RDD）和数据复制机制，Spark 能够在节点故障时自动恢复数据。
  - Spark 的工作原理：
    - 数据分区：Spark 将数据划分为多个分区，并将这些分区分布在集群的不同节点上。
    - 任务调度：Spark 的调度器将任务分配给集群中的工作节点，并协调任务的执行。
    - 内存计算：Spark 利用内存中的数据进行计算，减少了磁盘 I/O，提高了处理速度。
    - 结果输出：计算结果可以存储在内存中，也可以写入外部存储系统（如 HDFS、数据库等）。

- redis的stream和MQ的区别
  #image("Screenshot_20251020_195146.png")
  #image("Screenshot_20251020_195233.png")

- redis怎么从成本或者使用上优化 
  - 减少内存占用
    - 选对数据结构
    - 合理设置过期时间 TTL
    - 压缩与编码优化
    - 删除冗余数据
  - 降低硬件成本
    - 使用内存压缩型实例
    - 冷热分离。热数据放 Redis；冷数据放 MySQL / ElasticSearch；
  - 减少副本节点数量
  - 持久化优化
    - 不建议高频 RDB，会大量占用磁盘 I/O。
  - 降低访问压力
    - 本地缓存 + Redis 缓存双层结构
  - 批量操作（Pipeline）把多个命令合并成一次请求，减少网络往返
  - 分布式限流 / 防击穿
    - 利用 Lua 脚本原子执行；
    - 热 key 使用本地缓存或互斥锁。
  - 集群与分片优化
    - 使用 Redis Cluster 分片扩展；
    - 控制 key 的 哈希标签（HashTag） 保持相关性；

- Redis哨兵和分片
  -  Redis 哨兵（Sentinel）
    - 提供高可用（HA）机制，主要解决单节点 Redis 宕机后的自动故障转移问题。
    - 监控：Sentinel 持续监控主从节点的状态。
    - 自动故障转移：当主节点不可用时，Sentinel 会选举新的主节点，并通知客户端更新。
    - 配置提供者：客户端可以通过 Sentinel 获取最新的主节点地址。
  - Redis 分片（Sharding）
    - 解决单节点容量和性能瓶颈，把数据水平拆分到多个节点上。
    - 客户端分片（Client-side Sharding）
      - 客户端根据 key 计算哈希，决定请求哪个 Redis 节点。
      - 缺点：节点增加/减少时，哈希重排需要迁移大量数据
    - Proxy 分片（如 Twemproxy）
      - 客户端只连接 Proxy，Proxy 管理数据分片。
    - 客户端只连接 Proxy，Proxy 管理数据分片。
      - Redis Cluster 将 key 空间划分为 16,384 个 slot，每个节点负责部分 slot。
    - 哨兵 + 分片
      - 每个分片都可以是一个主从集群，由 Sentinel 管理。
  - Redis 哨兵（Sentinel）为什么通常要至少 3 个，而不能只有 2 个，这其实是分布式系统“选举机制 + 容错性”的结果。
    - 哨兵的职责
      - 监控主从实例是否存活
      - 在主节点宕机时选出新的主节点
    - 但！选主节点时不能单个哨兵自己说了算，必须经过多数派（majority）投票同意。
    - 至少要有 ⌈N/2⌉ + 1 个哨兵同意，才能进行主节点故障转移。
    - 2 个哨兵的情况：如果有 1 个哨兵挂了，剩下 1 个无法形成“多数派”。





- 如何处理Redis中的热点Key问题？可能引发什么问题？有哪些解决方案？
  - 什么是热点 Key
    - 在短时间内被大量请求访问（读或写）的某个 Key，远高于平均访问量。
  - 热点 Key 会引发什么问题？
    - Redis 是单线程处理命令的（除非启用多线程 IO），热点 Key 导致大量请求集中到一个节点的一个 Key 上，导致单核 CPU 飙高、处理阻塞
    - 所有请求都打向同一个 Redis 节点，网络流量集中，连接数激增
    - 热点 Key 过期时，大量请求同时打到数据库，数据库被打垮
    - Redis Cluster 中不同节点负载差异极大，某节点 QPS 高，其他节点空闲
  - 缓存副本分摊读压力
    - Redis 主从架构，将读流量分散到多个从节点；
    - 应用层实现 读写分离（写主、读从）；
    - 或使用 Redis Cluster 分片并手动做“副本扩散”。
    - 缺点：热点仍集中在同一个 Key 上，主从间同步延迟可能造成不一致。
  - 本地缓存（多级缓存）
    - 在应用端增加一层 本地缓存（Guava Cache / Caffeine / Ehcache）；
    - 每次从 Redis 取值后，缓存到本地内存；
    - 多实例时还可使用 定期刷新 + 失效通知。
    - 缺点： 数据一致性差、占内存。
  - Key 拆分 / 热点分片
    - 将一个热点 Key 分成多个小 Key
    - 写操作随机打到其中一个；
    - 读操作时再汇总求和。
    - 缺点： 读操作略复杂，需要聚合。
  -  缓存预热 + 永不过期 / 延迟过期
    - 热点 Key 提前写入 Redis；
    - 设置较长 TTL，或者不设置过期；
    - 用后台任务周期性刷新。
  - 用互斥锁或信号量保证同一时刻只有一个线程回源数据库；其他线程等待该线程加载完毕后再返回结果。
  - 限流 + 降级
    - 对热点接口进行限流；
    - Redis 异常或延迟时使用降级策略（返回缓存数据或默认值）。
  - 异步更新与消息队列
    - 请求先写入 MQ；
    - 后台消费者异步批量更新 Redis；
    - 再定期同步到数据库。
  - 检测热点 Key 的方法
    - Redis 命令
    ```
    redis-cli --bigkeys
    redis-cli monitor | grep hotkey

    ```
    - Redis 热点 Key 采样
      - 使用 redis-cli --latency、--stat 查看延迟；
      - 使用 INFO commandstats 分析命令执行频率；
      - 开启 hot key sampling（Redis 4.0+）：
      ```
      CONFIG SET hotkeys-tracking yes

      ```

- 若Redis在执行过程中掉电或集群网络短暂中断，如何恢复数据？如何保证数据一致性？是否存在不一致的时机？
  - Redis 掉电或网络中断后的数据恢复机制
    - RDB
    - AOF
    - RDB + AOF 混合模式
  - 集群或主从同步下的恢复逻辑
    - 主从复制机制
      - 从节点通过复制偏移量（replication offset）与主节点保持一致；
      - 网络短暂中断后，从节点通过 PSYNC 增量同步缺失的数据；
      - 若主节点重启或中断时间过长，会触发全量同步（发送整个 RDB 快照）。
    -  集群网络分区（脑裂）问题
      - 当网络分区导致主节点与部分从节点隔离时
        - 两个主节点可能都认为自己是“主”，接受写操作；
        - 网络恢复后可能出现数据不一致（部分写丢失或回滚）。
      - Redis 的防护机制：
        - min-slaves-to-write / min-replicas-to-write：限制主节点在没有足够从节点时停止写入；
        - Cluster 模式下：  通过 Epoch（配置纪元） 和 投票机制 决定新的主节点；保证只有一个合法主节点继续接受写操作。 
  - Redis 属于 AP（高可用 + 分区容忍）系统，一致性是弱化的。  但可以通过以下措施尽量提高一致性：
    #image("Screenshot_20251028_164532.png")
  - 是否存在不一致的时机？
    - 写入后尚未落盘即掉电，内存数据未同步至磁盘  
    - 主从异步复制，写入尚未同步至从节点时主挂掉
    - 网络分区（脑裂），双主各自接受写操作
    - 使用 everysec 策略，一秒内未落盘的数据丢失

  - 数据校对过程的时效、实现方案是什么？
    - Redis 中的数据校对（Data Reconciliation / Data Consistency Check）主要用于以下几种情况：
      - 主从节点间检查数据偏移量、key 数量、hash 校验，保证主从一致
      - REDIS和AOF RDB之间确认内存数据与磁盘文件数据一致
      - REDIS和DB确保缓存与数据库最终一致（缓存一致性问题）       
    - 校对的触发时机（时效性）
      - 主从偏移量对比：每次心跳（默认 1 秒）自动触发  秒级
      - AOF/RDB文件一致性检测 ：Redis 启动时或定时任务执行时  分钟级 / 小时级
      - 缓存与数据库一致性：应用层定期任务触发（如每 5 分钟 / 每小时）
      - 人工检测触发全量校验
    - AOF的数据校对：
      - Redis 在写入时会维护 AOF 文件的 CRC 校验值；
      - 重启时 Redis 会使用 redis-check-aof 工具或自动检测文件末尾；
      - 如果发现 AOF 文件尾部不完整（掉电中断造成），会截断到最后一个完整命令为止；
      - 然后重放所有命令

    - REDIS和DB的数据校对实现方案
      - XXL-JOB定时校对，不一致时恢复
      - 增量校对（实时修复）：  写操作时同时记录变更流水，定时扫描变更流水，对 Redis 中相应 key 重构缓存； 增量校对其实就是模仿写日志的流程：更新数据库时同时写日志，然后再根据日志写到 Redis。    
      - 双写校验 + 异步补偿 ： 每次写数据库后，再写 Redis； 若 Redis 返回错误或超时，写入补偿队列（Kafka / RabbitMQ）；消费者异步消费MQ



- 将本地缓存扩展为 Redis 集群后，如何确定某个 key 存储在哪个机器上？
  - Redis Cluster 并不是随机存放数据的，而是将整个键空间划分为 16384 个槽（Slot）。
    - Redis 使用 CRC16 哈希算法计算每个 key 的哈希值；然后对 16384 取模得到SLOT
    - 每个 Redis 节点负责一部分连续的 slot 区间。
    - 只要知道 key 对应的 slot 值，就能立即知道它归属于哪个节点。
  - 特殊情况：Hash Tag（哈希标签）
    - 有时你希望多个 key 落在同一个 slot：如 
    ```
    mget user:{1001}:name user:{1001}:age

    ```
    - Redis 会只取 {} 内的部分来计算 slot：
    ```
    slot = CRC16("1001") % 16384

    ```
    - 这样两个KEY会落到同一个节点上


- redis的主从同步是怎么实现的
  - 从节点发起复制请求
    - 连接主节点。
    - 发送 PING 以测试主从之间网络是否通畅。
    - 进行认证（如果主节点设置了 requirepass）。
    - 发送 PSYNC 命令请求同步。
  - 主从协商同步方式
    - 主节点根据 PSYNC 命令决定同步模式：
      - 全量同步（Full Resync）
      - 部分同步（Partial Resync）
  - 全量同步过程
    - 全量同步是最初始的、最耗时的一次同步
    - 主节点创建 RDB 快照，主节点执行 BGSAVE，在后台生成一个 RDB 文件。
    - RDB 传输，RDB 文件生成完毕后，主节点将文件通过 socket 发送给从节点。从节点接收 RDB 文件后：
      - 清空本地旧数据；
      - 加载新的 RDB 到内存。
    - 命令传播缓冲
      - 在主节点生成 RDB 期间，如果有新的写命令进来，主机会将这些命令写入一个缓冲区（称为 Replication Buffer 或 backlog buffer）。当 RDB 传输完成后，主节点会将缓冲区的写操作再发给从节点，以保持最终一致。
  - 增量同步
    - 当主从断开后重新连接，如果主节点仍然保留了从节点上次同步的复制偏移量（offset） 和 runid，则可以进行增量同步。
    - 从节点发送 PSYNC <runid> <offset>。
    - 主节点检查 backlog buffer 是否仍然有该 offset 之后的数据：
      - 有：返回 CONTINUE，仅发送增量命令。
      - 无：返回 FULLRESYNC，重新全量同步。
      - 这就是 Redis 2.8+ 后改进的 部分重同步机制
  - 主从完成一次全量或部分同步后，会进入命令传播阶段：
    - 主节点每执行一个写命令（如 SET、DEL、LPUSH 等），都会将该命令传播给所有从节点；
    - 从节点按顺序执行这些命令；

  - 部分同步的目标
    - 在早期（Redis 2.8 以前），主从断开后，从节点只能重新全量同步：
    - 部分同步让主从短暂断开后，只同步“断开期间”丢失的那一小部分数据，而不是重新同步全部数据。

  - 如果同步后有增量同步 那不是只要一次全量同步就好了吗
    - 只要主从完成一次全量同步，之后只要连接不断、网络稳定，主从之间确实就会一直通过 增量同步（命令传播） 保持一致，不需要再做任何全量同步。
    - 因为在真实环境中，有几种情况会打破这种理想状态，导致无法继续增量同步，只能重新全量。
      - 主从网络断开，错过了太多数据
      - 主节点重启了（runid 改变）
      - 从节点第一次加入复制集
      - 主从数据不一致（人为修改或过期）

  - 主从同步的间隔
    - Redis 主从同步不是定时拉取的
      - Redis 的主从复制是事件驱动 + 异步推送机制，
      - 主节点执行写命令 → 主节点立即推送给从节点。
    - 但为了保证主从状态健康，它们确实有“定期通信”
      - 主从之间确实会定期发送一些心跳包、offset 信息等
        - 检测连接是否正常
        - 判断延迟和同步进度
        - 确认是否需要补发数据
      #image("Screenshot_20251015_113321.png")
    - 从节点会每秒向主节点发送一次 REPLCONF ACK <offset> 命令：主节点会保存每个从节点的最新 offset，用来判断每个从节点的复制延迟与健康状态。
    - 主节点保存所有从节点的复制状态信息，主节点通过这些信息：
      - 知道哪些从节点落后；
      - 触发部分同步（PSYNC）时判断是否能补齐；
      - 在 Sentinel / Cluster 模式下评估从节点是否可被提升为主。
    - backlog是个固定长度的环形缓冲区（circular buffer），用于保存最近写入命令的数据流。
      - 当从节点断开后又重连时，如果它上次同步的位置还在 backlog 范围内，就可以执行部分重同步（增量同步）；
      - 否则，只能执行全量同步。
        - 因为是环形，当backlog写满后会覆盖原来的数据，如果从节点长时间没有与主节点进行部分同步，backlog一直增加就会造成覆盖
    #image("Screenshot_20251015_113641.png")

- Redis的大key问题 
  -  Redis的大Key问题是什么？
    - Redis大key问题指的是某个key对应的value值所占的内存空间比较大，导致Redis的性能下降、内存不足、数据不均衡以及主从同步延迟等问题。
    - 到底多大的数据量才算是大key？
    - 没有固定的判别标准，通常认为字符串类型的key对应的value值占用空间大于1M，或者集合类型的k元素数量超过1万个，就算是大key。
    - Redis大key问题的定义及评判准则并非一成不变，而应根据Redis的实际运用以及业务需求来综合评估。
    - 例如，在高并发且低延迟的场景中，仅10kb可能就已构成大key；然而在低并发、高容量的环境下，大key的界限可能在100kb。因此，在设计与运用Redis时，要依据业务需求与性能指标来确立合理的大key阈值。
  - 大Key问题的缺点？
    - 内存占用过高。大Key占用过多的内存空间，可能导致可用内存不足，从而触发内存淘汰策略。在极端情况下，可能导致内存耗尽，Redis实例崩溃，影响系统的稳定性。
    - 性能下降。大Key会占用大量内存空间，导致内存碎片增加，进而影响Redis的性能。对于大Key的操作，如读取、写入、删除等，都会消耗更多的CPU时间和内存资源，进一步降低系统性能。
    - 阻塞其他操作。某些对大Key的操作可能会导致Redis实例阻塞。例如，使用DEL命令删除一个大Key时，可能会导致Redis实例在一段时间内无法响应其他客户端请求，从而影响系统的响应时间和吞吐量。
    - 网络拥塞。每次获取大key产生的网络流量较大，可能造成机器或局域网的带宽被打满，同时波及其他服务。例如：一个大key占用空间是1MB，每秒访问1000次，就有1000MB的流量。
    - 主从同步延迟。当Redis实例配置了主从同步时，大Key可能导致主从同步延迟。由于大Key占用较多内存，同步过程中需要传输大量数据，这会导致主从之间的网络传输延迟增加，进而影响数据一致性。
    - 数据倾斜。在Redis集群模式中，某个数据分片的内存使用率远超其他数据分片，无法使数据分片的内存资源达到均衡。另外也可能造成Redis内存达到maxmemory参数定义的上限导致重要的key被逐出，甚至引发内存溢出。

  - Redis大key如何解决？
    - 对大Key进行拆分。例如将含有数万成员的一个HASH Key拆分为多个HASH Key，并确保每个Key的成员数量在合理范围。在Redis集群架构中，拆分大Key能对数据分片间的内存平衡起到显著作用。
    - 对大Key进行清理。将不适用Redis能力的数据存至其它存储，并在Redis中删除此类数据。注意，要使用异步删除。
    - 监控Redis的内存水位。可以通过监控系统设置合理的Redis内存报警阈值进行提醒，例如Redis内存使用率超过70%、Redis的内存在1小时内增长率超过20%等。
    - 对过期数据进行定期清。堆积大量过期数据会造成大Key的产生，例如在HASH数据类型中以增量的形式不断写入大量数据而忽略了数据的时效性。可以通过定时任务的方式对失效数据进行清理。

- redis的过期删除和缓存淘汰
  - 过期删除策略和内存淘汰策略有什么区别？
    - 区别：
      - 内存淘汰策略是在内存满了的时候，redis 会触发内存淘汰策略，来淘汰一些不必要的内存资源，以腾出空间，来保存新的内容
      - 过期键删除策略是将已过期的键值对进行删除，Redis 采用的删除策略是惰性删除+定期删除。
  - 介绍一下Redis 内存淘汰策略
    - 在 32 位操作系统中，maxmemory 的默认值是 3G，因为 32 位的机器最大只支持 4GB 的内存，而系统本身就需要一定的内存资源来支持运行，所以 32 位操作系统限制最大 3 GB 的可用内存是非常合理的，这样可以避免因为内存不足而导致 Redis 实例崩溃。
    - Redis 内存淘汰策略共有八种，这八种策略大体分为「不进行数据淘汰」和「进行数据淘汰」两类策略。
    - 不进行数据淘汰的策略：
      - noeviction（Redis3.0之后，默认的内存淘汰策略） ：它表示当运行内存超过最大设置内存时，不淘汰任何数据，这时如果有新的数据写入，会报错通知禁止写入，不淘汰任何数据，但是如果没用数据写入的话，只是单纯的查询或者删除操作的话，还是可以正常工作。
    - 进行数据淘汰的策略：
      - 针对「进行数据淘汰」这一类策略，又可以细分为「在设置了过期时间的数据中进行淘汰」和「在所有数据范围内进行淘汰」这两类策略。
        - 在设置了过期时间的数据中进行淘汰：
          - volatile-random：随机淘汰设置了过期时间的任意键值；
          - volatile-ttl：优先淘汰更早过期的键值。
          - volatile-lru（Redis3.0 之前，默认的内存淘汰策略）：淘汰所有设置了过期时间的键值中，最久未使用的键值；
          - volatile-lfu（Redis 4.0 后新增的内存淘汰策略）：淘汰所有设置了过期时间的键值中，最少使用的键值；
        - 在所有数据范围内进行淘汰：
          - allkeys-random：随机淘汰任意键值;
          - allkeys-lru：淘汰整个键值中最久未使用的键值；
          - allkeys-lfu（Redis 4.0 后新增的内存淘汰策略）：淘汰整个键值中最少使用的键值。

  - 介绍一下Redis过期删除策略
    - Redis 选择「惰性删除+定期删除」这两种策略配和使用，以求在合理使用 CPU 时间和避免内存浪费之间取得平衡。
    - Redis 的惰性删除策略由 db.c 文件中的 expireIfNeeded 函数实现
    - Redis 在访问或者修改 key 之前，都会调用 expireIfNeeded 函数对其进行检查，检查 key 是否过期：
      - 如果过期，则删除该 key，至于选择异步删除，还是选择同步删除，根据 lazyfree_lazy_expire 参数配置决定（Redis 4.0版本开始提供参数），然后返回 null 客户端；
      - 如果没有过期，不做任何处理，然后返回正常的键值对给客户端；
    - Redis 的定期删除是每隔一段时间「随机」从数据库中取出一定数量的 key 进行检查，并删除其中的过期key。
      - 这个间隔检查的时间是多长呢？
        - 在 Redis 中，默认每秒进行 10 次过期检查一次数据库，此配置可通过 Redis 的配置文件 redis.conf 进行配置，配置键为 hz 它的默认值是 hz 10。特别强调下，每次检查数据库并不是遍历过期字典中的所有 key，而是从数据库中随机抽取一定数量的 key 进行过期检查。
      - 随机抽查的数量是多少呢？
        - 我查了下源码，定期删除的实现在 expire.c 文件下的 activeExpireCycle 函数中，其中随机抽查的数量由 ACTIVE_EXPIRE_CYCLE_LOOKUPS_PER_LOOP 定义的，它是写死在代码中的，数值是 20。也就是说，数据库每轮抽查时，会随机选择 20 个 key 判断是否过期。接下来，详细说说 Redis 的定期删除的流程：
          - 从过期字典中随机抽取 20 个 key；
          - 检查这 20 个 key 是否过期，并删除已过期的 key；
          - 如果本轮检查的已过期 key 的数量，超过 5 个（20/4），也就是「已过期 key 的数量」占比「随机抽取 key 的数量」大于 25%，则继续重复步骤 1；如果已过期的 key 比例小于 25%，则停止继续删除过期 key，然后等待下一轮再检查。
      - 可以看到，定期删除是一个循环的流程。那 Redis 为了保证定期删除不会出现循环过度，导致线程卡死现象，为此增加了定期删除循环流程的时间上限，默认不会超过 25ms。
  - Redis的缓存失效会不会立即删除？
    - 不会，Redis 的过期删除策略是选择「惰性删除+定期删除」这两种策略配和使用。
      - 惰性删除策略的做法是，不主动删除过期键，每次从数据库访问 key 时，都检测 key 是否过期，如果过期则删除该 key。
      - 定期删除策略的做法是，每隔一段时间「随机」从数据库中取出一定数量的 key 进行检查，并删除其中的过期key。

  - 那为什么我不过期立即删除？
    - 在过期 key 比较多的情况下，删除过期 key 可能会占用相当一部分 CPU 时间，在内存不紧张但 CPU 时间紧张的情况下，将 CPU 时间用于删除和当前任务无关的过期键上，无疑会对服务器的响应时间和吞吐量造成影响。所以，定时删除策略对 CPU 不友好。

- Redis是怎么找到key存储在哪个节点上
  - Redis Cluster 将整个 key 空间划分为 16384 个槽（slot），每个主节点负责一部分槽（slot 范围），每个槽对应若干个KEY
  - Redis 对 key 的槽编号计算规则是：slot = CRC16(key) % 16384 得到槽号（0 ~ 16383）。
  - 客户端如何知道 key 在哪个节点？
    - 客户端连接 Redis 集群时，最初只知道一个节点。Redis 使用一种“跳转机制”来引导客户端找到正确节点：
      - 客户端向某个节点发送命令；
      - 若该节点不负责该 key 对应的槽，会返回 MOVED <slot> <target-ip:port>
      - 客户端收到后更新本地槽映射表（slot → 节点）直接重定向请求到正确节点。
  - 槽迁移
    - 当你添加或删除节点时，Redis 通过迁移槽（slot）实现数据再平衡
    - Redis 会将部分槽从 Node A 挪到新节点 Node D；
    - 在迁移期间：
      - 源节点仍接收请求，但可能返回 ASK；这表示：这个槽我正在迁移中，数据可能已经到另一台机器，请你这次请求去目标节点处理，但不要更新路由表！
      - 客户端会临时跳转到目标节点；
    - 迁移完成后，更新全局槽映射。


- String 是使用什么存储的?为什么不用 c 语言中的字符串?
  - Redis 的 String 字符串是用 SDS 数据结构存储的。
  - 结构中的每个成员变量分别介绍下：
    - len，记录了字符串长度。这样获取字符串长度的时候，只需要返回这个成员变量值就行，时间复杂度只需要 O（1）。
    - alloc，分配给字符数组的空间长度。这样在修改字符串的时候，可以通过 alloc - len 计算出剩余的空间大小，可以用来判断空间是否满足修改需求，如果不满足的话，就会自动将 SDS 的空间扩展至执行修改所需的大小，然后才执行实际的修改操作，所以使用 SDS 既不需要手动修改 SDS 的空间大小，也不会出现前面所说的缓冲区溢出的问题。
    - flags，用来表示不同类型的 SDS。一共设计了 5 种类型，分别是 sdshdr5、sdshdr8、sdshdr16、sdshdr32 和 sdshdr64，后面在说明区别之处。
    - buf[]，字符数组，用来保存实际数据。不仅可以保存字符串，也可以保存二进制数据。
  - 总的来说，Redis 的 SDS 结构在原本字符数组之上，增加了三个元数据：len、alloc、flags，用来解决 C 语言字符串的缺陷。
    - O（1）复杂度获取字符串长度
      - C 语言的字符串长度获取 strlen 函数，需要通过遍历的方式来统计字符串长度，时间复杂度是 O（N）。
      - 而 Redis 的 SDS 结构因为加入了 len 成员变量，那么获取字符串长度的时候，直接返回这个成员变量的值就行，所以复杂度只有 O（1）。
    - 二进制安全
      - 因为 SDS 不需要用 “\0” 字符来标识字符串结尾了，而是有个专门的 len 成员变量来记录长度，所以可存储包含 “\0” 的数据。但是 SDS 为了兼容部分 C 语言标准库的函数， SDS 字符串结尾还是会加上 “\0” 字符。
      - 因此， SDS 的 API 都是以处理二进制的方式来处理 SDS 存放在 buf[] 里的数据，程序不会对其中的数据做任何限制，数据写入的时候时什么样的，它被读取时就是什么样的。
      - 通过使用二进制安全的 SDS，而不是 C 字符串，使得 Redis 不仅可以保存文本数据，也可以保存任意格式的二进制数据。
    - 不会发生缓冲区溢出
      - C 语言的字符串标准库提供的字符串操作函数，大多数（比如 strcat 追加字符串函数）都是不安全的，因为这些函数把缓冲区大小是否满足操作需求的工作交由开发者来保证，程序内部并不会判断缓冲区大小是否足够用，当发生了缓冲区溢出就有可能造成程序异常结束。
      - 所以，Redis 的 SDS 结构里引入了 alloc 和 len 成员变量，这样 SDS API 通过 alloc - len 计算，可以算出剩余可用的空间大小，这样在对字符串做修改操作的时候，就可以由程序内部判断缓冲区大小是否足够用。
      - 而且，当判断出缓冲区大小不够用时，Redis 会自动将扩大 SDS 的空间大小，以满足修改所需的大小。


- Redis实现并发锁的方式
  - setnx
  - redisson
    - 可重入锁（同线程可多次加锁）
    - 自动续期机制（看门狗 Watchdog）
    - Lua 脚本保证原子性
  - redlock
    - 当系统是 多 Redis 实例（分布式 Redis 集群） 时，用 RedLock 算法确保高可靠性。
    - 实现思路
      - 在 N 个独立 Redis 实例 上同时尝试加锁（推荐 N=5）
      - 如果在 超过一半实例（N/2+1）加锁成功 且时间未超时，则认为加锁成功
      - 加锁失败则在所有实例上释放锁并重试
    - RedLock 的优势
      - 不依赖单点 Redis（一个实例挂了锁仍然安全）
      - 解决了单实例 Redis 在主从延迟或 failover 时的安全问题

- redis存登陆token 如果token被淘汰了怎么办 如果token泄漏了怎么办
  - 如果 token 被 Redis 淘汰了怎么办？
    - 使用独立 Redis 实例或数据库
    - 双层机制：Redis + JWT 自验证
      - 即使 Redis 挂了或丢失缓存，也能通过 JWT 自身验证继续生效。
    -  Redis 持久化
  - 如果 token 泄漏了怎么办？
    - 缩短 token 过期时间，被盗的 token 也只能短期生效。
    -  加入 Redis 校验机制（黑名单）当用户登出、改密、异常登录时，主动删除或加入黑名单：
    - 绑定客户端信息在 JWT payload 中嵌入部分信息：验证时比对 IP、UA 等信息不符则可以强制前一个 token 失效
    - 使用 HTTPS
    - Refresh Token 机制
      - 用户用 refresh token 换取新 access token；
      - 一旦泄漏，可立即让 refresh token 失效，彻底断开会话。
  
- 什么场景下会考虑用 Redisson？
  - 分布式锁
    - 可重入锁（同线程可多次加锁）
    - 自动续期机制（看门狗）
    - 公平锁
  - 分布式信号量 / 限流器
    - 控制某个资源的最大并发数
    - 对应 Redisson：
      - RSemaphore（信号量）
      - RRateLimiter（限流器）
  - 分布式集合、Map、Queue、Topic
    - 对应 Redisson：
      - RMap, RList, RSet, RQueue, RDeque
      - RTopic（发布/订阅消息）
      - RBlockingQueue（阻塞队列，适合任务调度）
  - 分布式同步器（锁以外的协作机制）
    - 想实现类似 Java 并发包中的 CountDownLatch、CyclicBarrier、Lock 等机制，但在分布式环境下用。
    - 对应 Redisson：
      - RCountDownLatch：多个服务等待同一个事件；
      - RReadWriteLock：分布式读写锁；
      - RPermitExpirableSemaphore：带有效期的许可。

-  Redisson 的看门狗机制了解吗？它是怎么防止锁被提前释放的？
  - 问题：当业务执行时间超过锁的过期时间，锁会自动释放，导致其他线程“误以为”锁可用，从而出现并发修改。
  - Redisson 为了解决这个问题，引入了 “看门狗（Watchdog）”。
  - 看门狗的作用：当一个线程成功获得分布式锁后，Redisson 会在后台启动一个守护线程，周期性地为这把锁“续命”，防止锁在业务执行期间被 Redis 自动删除。
  - 工作机制详解
    - Step 1：加锁时
      - 调用 Lua 脚本执行 SETNX；
      - 设置默认过期时间为 30 秒；
      - 保存当前线程 ID 到 Redis 的锁值中；
    - Step 2：启动看门狗线程
      - Redisson 会启动一个 后台定时任务（watchdog），每隔一段时间（默认 10 秒）执行一次判断，确认线程是否还持有该锁，若还持有则刷新过期时间
    - Step 3：锁释放时
      - Redisson 会：删除 Redis 中的锁键；停止对应的看门狗线程；

- 介绍缓存穿透的解决方案及相关经验。
  - 缓存穿透是指查询一个一定不存在的数据，既不会命中缓存，也查不到数据库结果，导致每次请求都要打到数据库。
  - 缓存穿透的成因
    - 恶意攻击或爬虫：故意请求不存在的 key；
    - 业务bug：请求参数校验缺失；
    - 数据确实未存在且未缓存空值；
    - 缓存过期+查询空数据未缓存。
  - 后果
    - 数据库压力骤增；
    - 系统整体响应延迟上升甚至崩溃。
  - 解决方案 
    - 缓存空对象
      - 优点：容易实现
      - 缺点：
        - 占用缓存空间，可能被频繁访问
        - 缓存空值 TTL 要设置得当（太长浪费内存，太短不防穿透）。
    - 使用布隆过滤器（Bloom Filter）  
      - 原理：使用哈希算法映射一个“存在性标记”；若布隆过滤器判断“不存在”，直接拦截请求；若判断“可能存在”，再去查询缓存/数据库。
      - 优点：
        - 内存占用低，查询速度快
        - 能有效拦截绝大多数不存在的请求
      - 缺点：
        - 有一定误判率（可能误判为存在）
        - 需要维护过滤器数据同步（新增、删除时更新）。
    - 接口层参数校验
      - 直接在 API 层防止非法请求进入缓存/数据库层。
    - 限流 + 黑名单
      - 针对异常访问（如同一 IP 高频访问不存在的 key），进行限流或拉黑。
      - 统计每个 IP 的请求失败率；超阈值后临时封禁。
    - 
      



- 除了分布式锁，Redis 缓存还常用在哪些场景？
  - 热点数据缓存
  - 缓存穿透、击穿、雪崩防护
  - 实时排行榜（ZSet）
  - 接口限流（计数器或漏桶算法）
  - 计数器统计，用户访问量统计，点赞数 / 收藏数 / 商品浏览量统计
  - 使用 List / Stream 做简易消息队列
  - 登录态、Session共享。在分布式部署下，用 Redis 存用户 Session
  - 延迟队列。在 Redisson 中可直接用 RDelayedQueue

- Redis 是怎么做持久化的？讲讲 RDB 和 AOF。
  - RDB是快照持久化
    - Redis 会周期性地将 内存中的数据快照 保存到磁盘（生成一个 .rdb 文件）。
    - 可以理解为“某一时刻的全量备份”。
  - RDB的执行
    ```java
    save 900 1      # 900秒内有1次写操作就触发RDB
    save 300 10     # 300秒内有10次写操作就触发RDB
    save 60 10000   # 60秒内有10000次写操作就触发RDB
 
    ```
    或
    ```java
    SAVE      # 同步执行，阻塞主线程
    BGSAVE    # 异步执行，fork子进程完成

    ```
    - BGSAVE 的流程如下
      - 主进程执行 fork() 创建一个子进程；
      - 子进程将当前内存数据写入一个临时文件；
      - 写完后替换原有的 dump.rdb；
      - 主进程继续处理请求（几乎无阻塞）。
    - 优点
      - 性能好：主进程 fork 后，几乎零阻塞。
      - 恢复快：加载一个 RDB 文件即可恢复。
      - 文件紧凑：二进制格式，占空间小。
    - 缺点： 
      - 丢数据风险高：可能丢失最后一次快照后的所有数据。
      - 生成文件开销大：fork + 写磁盘，对大数据量影响较明显。
  - AOF是 追加日志持久化（Append Only File）
  - Redis 会把每次执行的写命令（set/del/incr...）追加到日志文件 aof 文件中；
  - 重启时，Redis 会重放 AOF 日志，重新构建数据。
  - AOF 开启方式：
    ```java
        appendonly yes
    appendfilename "appendonly.aof"
 
    ```
  - 刷盘策略
    - always 
      - 每次写操作都立即 fsync
      - 最慢
      - 最安全
    - everysec
      - 默认
      - 每秒 fsync 一次
      - 折中
      - 最常用
    - no
      - 由操作系统决定（异步写磁盘）
      - 最快
      - 可能丢失较多数据
  - AOF重写 
    - AOF 文件会越来越大，所以 Redis 会：
      - fork 一个子进程；
      - 重写（rewrite） 文件，只保留能恢复当前状态的最少命令；
      - 新文件写好后覆盖旧文件
    - 过程完全异步，不阻塞主线程
  - 优点
    - 数据更安全：丢失窗口可控制在 1 秒内（默认 everysec）。
    - 日志可读：AOF 文件是纯文本命令，可手动修复。
    - 更灵活：支持增量记录、重写。
  - 缺点： 
    - 文件更大：比 RDB 占空间多。
    - 恢复稍慢：需要重放日志。
    - 写入更频繁：性能略低于 RDB。
  - 混合持久化
    - 从 Redis 4.0 开始，引入了 RDB + AOF 混合模式
    - 重写 AOF 时，先写入一份 RDB 格式的快照；
    - 然后再追加最近的增量 AOF 命令。
    - 这样既能：快速恢复也能保证数据安全

- redis为什么快
  - 基于内存 + 紧凑的数据编码（高效的数据结构）
    - Redis 所有数据都存在 RAM 中，读写延迟在 微秒级。
    - 但更厉害的是它对每种数据结构都做了高度优化：
    - Redis 会根据数据大小自动切换编码（例如 ziplist → hashtable）
  -  零拷贝 + 高效的内存分配策略
    - Redis 使用自定义的内存分配器（默认是 jemalloc 或 malloc）
    - Redis 几乎所有内存操作都避免了系统调用的开销。
  - 高效的网络模型：非阻塞 I/O + 多路复用 + 单线程事件循环
    - Redis 使用 epoll (Linux) / kqueue (BSD) 做 I/O 多路复用
    - 单线程事件循环
    - 每次从就绪队列中批量处理 I/O
    - 避免上下文切换、锁竞争
  - 极简的通信协议（RESP）
    - 直接基于 TCP 流解析
  - 缓存友好的数据布局（CPU Cache Friendly）
    - Redis 尽可能使用 连续内存结构（如 ziplist、intset），保证数据局部性（locality）。
    - 当 CPU 读取内存时，会提前把相邻数据读进 cache line。
  -  减少系统调用和锁竞争
    - Redis 的核心线程只做三件事：
      - 处理网络事件（读写）
      - 执行命令
      - 解析命令
    - 持久化（RDB/AOF）和过期清理都在 后台线程 异步执行。这意味着主线程 几乎无阻塞操作，执行路径非常短。  
  - 命令复杂度极低 + 单命令原子性
    - Redis 命令几乎都是 O(1) 或 O(logN) 操作






- TCP 的 TIME_WAIT 状态是怎么产生的，用什么命令可以查看当前有多少连接处于 TIME_WAIT 状态？
  - 在 TCP 四次挥手（连接关闭）过程中，主动发起关闭的一方（也就是先发出 FIN 的一方）最终会进入 TIME_WAIT 状态。
  - 四次挥手的过程
    - 客户端 → 服务端： 发送 FIN，表示我这边的数据发完了。
    - 服务端 → 客户端： 回复 ACK，确认收到你的 FIN。
    - 服务端 → 客户端： 当服务端也发送完数据后，发出自己的 FIN。
    - 客户端 → 服务端： 回复 ACK 确认收到。
  - 为什么要进入 TIME_WAIT？
    - 确保对方收到最后的 ACK（防止丢失导致连接状态不同步）；
    - 让旧连接的延迟包在网络中自然消失，防止新连接误收旧包。
    - 因此，TCP 规范（RFC 793）要求主动关闭方在进入 TIME_WAIT 后 保持 2MSL（Maximum Segment Lifetime）时间。MSL（报文最大生存时间）通常取 30 秒或 60 秒，所以 TIME_WAIT 一般持续 60~120 秒。
  - 查看当前有多少连接处于 TIME_WAIT 状态
    - netstat -an | grep TIME_WAIT | wc -l
    - ss -ant state time-wait | wc -l

- TCP Server 在网络通信时会涉及哪些系统调用？
  #image("Screenshot_20251015_145233.png")
  #image("Screenshot_20251015_145303.png")

- io多路复用 SELECT和EPOLL和POLL
  - #image("Screenshot_20251015_145638.png")
  - select 每次调用都要遍历整个 FD 集合，即使只有一个就绪。select 使用固定大小的位图（通常 FD_SETSIZE = 1024），超过就不行；
  - epoll 由内核事件回调机制维护就绪队列，只返回活跃的 FD。

  - epoll底层 
    - 红黑树+就绪链表+等待队列
    - 所有监听 FD 存在红黑树中，增删改查为 O(logN)
    - 事件触发时直接放入 ready list，不需要扫描全部 FD
    - 回调机制触发由内核事件驱动而非轮询
    - 一次注册、持续监听
  - poll 相比 select 的改进
    - poll 使用一个可变长的数组 pollfd[]，数量只受系统内存限制。不再受 FD 数量限制
    - poll 的 events 支持更精细的事件，如 POLLIN, POLLOUT, POLLERR, POLLHUP 等，比 select 的 read/write/exception 更灵活。

- Redis 网络 IO 瓶颈是什么？
  - 指客户端与 Redis 之间的socket 通信过程：数据包收发、TCP 读写、内核缓冲区拷贝等。
  - 即使命令执行极快（微秒级），网络传输、系统调用、协议解析仍可能占主要耗时。

- TCP三次握手过程说一下？
  - 一开始，客户端和服务端都处于 CLOSE 状态。先是服务端主动监听某个端口，处于 LISTEN 状态
  - 客户端会随机初始化序号（client_isn），将此序号置于 TCP 首部的「序号」字段中，同时把 SYN 标志位置为 1，表示 SYN 报文。接着把第一个 SYN 报文发送给服务端，表示向服务端发起连接，该报文不包含应用层数据，之后客户端处于 SYN-SENT 状态。
  - 服务端收到客户端的 SYN 报文后，首先服务端也随机初始化自己的序号（server_isn），将此序号填入 TCP 首部的「序号」字段中，其次把 TCP 首部的「确认应答号」字段填入 client_isn + 1, 接着把 SYN 和 ACK 标志位置为 1。最后把该报文发给客户端，该报文也不包含应用层数据，之后服务端处于 SYN-RCVD 状态。
  - 客户端收到服务端报文后，还要向服务端回应最后一个应答报文，首先该应答报文 TCP 首部 ACK 标志位置为 1 ，其次「确认应答号」字段填入 server_isn + 1 ，最后把报文发送给服务端，这次报文可以携带客户到服务端的数据，之后客户端处于 ESTABLISHED 状态。
  - 服务端收到客户端的应答报文后，也进入 ESTABLISHED 状态。
  - 从上面的过程可以发现第三次握手是可以携带数据的，前两次握手是不可以携带数据的，这也是面试常问的题。
  - 一旦完成三次握手，双方都处于 ESTABLISHED 状态，此时连接就已建立完成，客户端和服务端就可以相互发送数据了。

- tcp为什么需要三次握手建立连接？
  - 三次握手的原因：
    - 三次握手才可以阻止重复历史连接的初始化（主要原因）
    - 三次握手才可以同步双方的初始序列号
    - 三次握手才可以避免资源浪费
  - 原因一：避免历史连接
    - 我们考虑一个场景，客户端先发送了 SYN（seq = 90）报文，然后客户端宕机了，而且这个 SYN 报文还被网络阻塞了，服务并没有收到，接着客户端重启后，又重新向服务端建立连接，发送了 SYN（seq = 100）报文（注意！不是重传 SYN，重传的 SYN 的序列号是一样的）。
    - 客户端连续发送多次 SYN（都是同一个四元组）建立连接的报文，在网络拥堵情况下：
      - 一个「旧 SYN 报文」比「最新的 SYN」 报文早到达了服务端，那么此时服务端就会回一个 SYN + ACK 报文给客户端，此报文中的确认号是 91（90+1）。
      - 客户端收到后，发现自己期望收到的确认号应该是 100 + 1，而不是 90 + 1，于是就会回 RST 报文。
      - 服务端收到 RST 报文后，就会释放连接。
      - 后续最新的 SYN 抵达了服务端后，客户端与服务端就可以正常的完成三次握手了。
    - 上述中的「旧 SYN 报文」称为历史连接，TCP 使用三次握手建立连接的最主要原因就是防止「历史连接」初始化了连接。
    - 如果是两次握手连接，就无法阻止历史连接，那为什么 TCP 两次握手为什么无法阻止历史连接呢？
    - 主要是因为在两次握手的情况下，服务端没有中间状态给客户端来阻止历史连接，导致服务端可能建立一个历史连接，造成资源浪费。
    - 你想想，在两次握手的情况下，服务端在收到 SYN 报文后，就进入 ESTABLISHED 状态，意味着这时可以给对方发送数据，但是客户端此时还没有进入 ESTABLISHED 状态，假设这次是历史连接，客户端判断到此次连接为历史连接，那么就会回 RST 报文来断开连接，而服务端在第一次握手的时候就进入 ESTABLISHED 状态，所以它可以发送数据的，但是它并不知道这个是历史连接，它只有在收到 RST 报文后，才会断开连接。
    - 可以看到，如果采用两次握手建立 TCP 连接的场景下，服务端在向客户端发送数据前，并没有阻止掉历史连接，导致服务端建立了一个历史连接，又白白发送了数据，妥妥地浪费了服务端的资源。
    - 因此，要解决这种现象，最好就是在服务端发送数据前，也就是建立连接之前，要阻止掉历史连接，这样就不会造成资源浪费，而要实现这个功能，就需要三次握手。
  - 原因二：同步双方初始序列号
    - TCP 协议的通信双方， 都必须维护一个「序列号」， 序列号是可靠传输的一个关键因素，它的作用：
      - 接收方可以去除重复的数据；
      - 接收方可以根据数据包的序列号按序接收；
      - 可以标识发送出去的数据包中， 哪些是已经被对方收到的（通过 ACK 报文中的序列号知道）；
    - 可见，序列号在 TCP 连接中占据着非常重要的作用，所以当客户端发送携带「初始序列号」的 SYN 报文的时候，需要服务端回一个 ACK 应答报文，表示客户端的 SYN 报文已被服务端成功接收，那当服务端发送「初始序列号」给客户端的时候，依然也要得到客户端的应答回应，这样一来一回，才能确保双方的初始序列号能被可靠的同步。
    - 四次握手与三次握手
      - 四次握手其实也能够可靠的同步双方的初始化序号，但由于第二步和第三步可以优化成一步，所以就成了「三次握手」。
      - 而两次握手只保证了一方的初始序列号能被对方成功接收，没办法保证双方的初始序列号都能被确认接收。
  - 原因三：避免资源浪费 
    - 如果只有「两次握手」，当客户端发生的 SYN 报文在网络中阻塞，客户端没有接收到 ACK 报文，就会重新发送 SYN ，由于没有第三次握手，服务端不清楚客户端是否收到了自己回复的 ACK 报文，所以服务端每收到一个 SYN 就只能先主动建立一个连接，这会造成什么情况呢？
    - 如果客户端发送的 SYN 报文在网络中阻塞了，重复发送多次 SYN 报文，那么服务端在收到请求后就会建立多个冗余的无效链接，造成不必要的资源浪费。
    - 即两次握手会造成消息滞留情况下，服务端重复接受无用的连接请求 SYN 报文，而造成重复分配资源。

    
- 描述一下打开百度首页后发生的网络过程
  - 解析URL：分析 URL 所需要使用的传输协议和请求的资源路径。如果输入的 URL 中的协议或者主机名不合法，将会把地址栏中输入的内容传递给搜索引擎。如果没有问题，浏览器会检查 URL 中是否出现了非法字符，则对非法字符进行转义后在进行下一过程。
  - 缓存判断：浏览器缓存 → 系统缓存（hosts 文件） → 路由器缓存 → ISP 的 DNS 缓存，如果其中某个缓存存在，直接返回服务器的IP地址。
  - DNS解析（把域名解析为 IP 地址）：如果缓存未命中，浏览器向本地 DNS 服务器发起请求，最终可能通过根域名服务器、顶级域名服务器（.com）、权威域名服务器逐级查询，直到获取目标域名的 IP 地址。
  - 获取MAC地址（唯一标识网卡，只在局域网内有效，不会跨路由传播）：当浏览器得到 IP 地址后，数据传输还需要知道目的主机 MAC 地址，因为应用层下发数据给传输层，TCP 协议会指定源端口号和目的端口号，然后下发给网络层。网络层会将本机地址作为源地址，获取的 IP 地址作为目的地址。然后将下发给数据链路层，数据链路层的发送需要加入通信双方的 MAC 地址，本机的 MAC 地址作为源 MAC 地址，目的 MAC 地址需要分情况处理。通过将 IP 地址与本机的子网掩码相结合，可以判断是否与请求主机在同一个子网里，如果在同一个子网里，可以使用 ARP 协议获取到目的主机的 MAC 地址，如果不在一个子网里，那么请求应该转发给网关，由它代为转发，此时同样可以通过 ARP 协议来获取网关的 MAC 地址，此时目的主机的 MAC 地址应该为网关的地址。
  - 建立TCP连接：主机将使用目标 IP地址和目标MAC地址发送一个TCP SYN包，请求建立一个TCP连接，然后交给路由器转发，等路由器转到目标服务器后，服务器回复一个SYN-ACK包，确认连接请求。然后，主机发送一个ACK包，确认已收到服务器的确认，然后 TCP 连接建立完成。
  - HTTPS 的 TLS 四次握手：如果使用的是 HTTPS 协议，在通信前还存在 TLS 的四次握手。
  - 发送HTTP请求：连接建立后，浏览器会向服务器发送HTTP请求。请求中包含了用户需要获取的资源的信息，例如网页的URL、请求方法（GET、POST等）等。
  - 服务器处理请求并返回响应：服务器收到请求后，会根据请求的内容进行相应的处理。例如，如果是请求网页，服务器会读取相应的网页文件，并生成HTTP响应。
- 建立 HTTP 连接后，请求是如何传递到后端程序的?
  - 客户端构造 HTTP 请求：浏览器通过 TCP 将这个请求字节流发送给服务器的端口。
  - 服务器监听某个端口（如 80 或 443）：
    - Web 服务器软件（如 Nginx、Apache、Tomcat、Node.js 的 HTTP 模块）接收到 TCP 数据流。
      - Web 容器（Web Container） 是一个运行 Web 应用的服务器环境，它：
        - 负责 监听端口（如 8080）；
        - 负责 接收 HTTP 请求；
        - 负责 创建/管理 Servlet 对象；
        - 负责 调度生命周期方法
    - 解析 TCP 数据流成HTTP 请求报文：
      - 请求行（方法、路径、HTTP 版本）
      - 请求头（Host、Cookie、User-Agent…）
      - 请求体（POST/PUT 的 JSON、表单、文件等）
    -  封装为 HttpServletRequest 和 HttpServletResponse 对象
    - 找到要处理的 Servlet（如 DispatcherServlet）
    - 调用 Servlet 的 service() 方法
    
  - 拦截器会在进入你的业务逻辑（Controller）之前，拿到请求头（如 Token、Cookie、Session 等）进行权限校验。
  - DispatcherServlet的任务是接管所有进入应用的 HTTP 请求，然后根据配置分发给正确的 Controller。服务器根据URL 路径 + HTTP 方法决定由哪个后端程序处理：
    - 在 Java 中：Servlet 容器（Tomcat、Jetty）根据 web.xml 或注解 \@RequestMapping 匹配到具体 Controller。

- 登陆方案
  - 单 token + JWT + Redis（可选黑名单/设备绑定）
  - 双 token（Access + Refresh）
  - 双 token + 单点登录系统（SSO） + OAuth2 / OpenID Connect


- Springboot相比较spring好处
  - 先看 Spring 有哪些“痛点”
    - 配置繁琐（XML 地狱）
    - 依赖管理复杂
      - 版本冲突等
    - 环境部署麻烦
      - 传统 Spring Web 应用需要：打成 .war 部署到 Tomcat 或其他外部容器中
  - Springboot相比较spring好处
    - 自动配置
      - 不再需要写大量 XML 或 \@Configuration； 
      - 通过 “约定大于配置” 的理念，自动为你配置好常用组件。
    - 起步依赖
      - starter 依赖
    - 内嵌服务器
      - 无需外部部署 WAR 包
    - 健康检查与监控
    - 一致的配置方式（application.yml / .properties）
    - 与微服务体系兼容良好

- SPRINGBOOT的自动配置
  - Spring Boot 会在应用启动时自动帮你配置好常用的 Bean，不需要你手动在 \@Configuration 或 applicationContext.xml 中写一堆繁琐的配置。
  - 如果你引入了依赖      
    ```
    <dependency>
    <groupId>spring-boot-starter-web</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
  </dependency>

    ```
    - Spring Boot 会自动配置好：
      - DispatcherServlet
      - Tomcat 服务器
      - Jackson JSON 解析器
      - 静态资源处理器
      - 常用的 MVC 组件
  - 自动配置的核心注解
    - \@SpringBootApplication
      - 这是一个组合注解，包含了 \@EnableAutoConfiguration、\@ComponentScan 和 \@Configuration
    - \@EnableAutoConfiguration
      - 告诉 Spring Boot 启用自动配置功能 
  - \@EnableAutoConfiguration 的工作原理
    - \@EnableAutoConfiguration 实际上是通过 \@Import 导入了一个叫AutoConfigurationImportSelector 的类，这个类负责真正的“自动加载配置”。
    - 它从 META-INF/spring.factories（Spring Boot 2.x）或 META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports（Spring Boot 3.x 之后）里读取所有可以被自动配置的类；然后判断哪些条件满足（比如是否有某个类、Bean、环境变量等），再有选择性地加载对应的配置类。
      - 这些文件来自你通过 Maven（或 Gradle）导入的依赖包（JAR）中的资源文件，
  - Spring Boot 不会盲目加载所有配置类，它依赖于大量的 条件注解（\@Conditional）。
    - ConditionalOnClass 当某个类存在于 classpath 时才生效
    - ConditionalOnMissingBean 当某个 Bean 不存在时才生效
    - ConditionalOnProperty 根据配置属性的值决定是否生效
    - ConditionalOnBean 当某个 Bean 存在时才生效
    - ConditionalOnWebApplication 仅在 Web 应用环境下生效

- Spring Boot 自动装配原理
  - SpringBoot 的自动装配原理是基于Spring Framework的条件化配置和\@EnableAutoConfiguration注解实现的。这种机制允许开发者在项目中引入相关的依赖，SpringBoot 将根据这些依赖自动配置应用程序的上下文和功能。
  - SpringBoot 定义了一套接口规范，这套规范规定：SpringBoot 在启动时会扫描外部引用 jar 包中的META-INF/spring.factories文件，将文件中配置的类型信息加载到 Spring 容器（此处涉及到 JVM 类加载机制与 Spring 的容器知识），并执行类中定义的各种操作。对于外部 jar 来说，只需要按照 SpringBoot 定义的标准，就能将自己的功能装置进 SpringBoot。
  - 通俗来讲，自动装配就是通过注解或一些简单的配置就可以在SpringBoot的帮助下开启和配置各种功能，比如数据库访问、Web开发。
  - \@EnableAutoConfiguration: 这个注解是 Spring Boot 自动装配的核心。它告诉 Spring oot 启用自动配置机制，根据项目的依赖和配置自动配置应用程序的上下文。通过这个注解，SpringBoot 将尝试根据类路径上的依赖自动配置应用程序。
  - \@AutoConfigurationPackage，将项目src中main包下的所有组件注册到容器中，例如标注了Component注解的类等
  - \@Import({AutoConfigurationImportSelector.class})，是自动装配的核心，接下来分析一下这个注解
    - AutoConfigurationImportSelector 是 Spring Boot 中一个重要的类，它实现了 ImportSelector 接口，用于实现自动配置的选择和导入。具体来说，它通过分析项目的类路径和条件来决定应该导入哪些自动配置类。
      - 扫描类路径: 在应用程序启动时，AutoConfigurationImportSelector 会扫描类路径上的 META-INF/spring.factories 文件，这个文件中包含了各种 Spring 配置和扩展的定义。在这里，它会查找所有实现了 AutoConfiguration 接口的类,具体的实现为getCandidateConfigurations方法。
      - 条件判断: 对于每一个发现的自动配置类，AutoConfigurationImportSelector 会使用条件判断机制（通常是通过 \@ConditionalOnXxx注解）来确定是否满足导入条件。这些条件可以是配置属性、类是否存在、Bean是否存在等等。
      - 根据条件导入自动配置类: 满足条件的自动配置类将被导入到应用程序的上下文中。这意味着它们会被实例化并应用于应用程序的配置。



-  标准Web项目（如基于Spring MVC的HTTP服务）中，Spring Boot提供了哪些模块来实现相关能力？其集成能力如何？
  - Web层
    - spring-boot-starter-web
    - spring-boot-starter-webflux
    - spring-boot-starter-thymeleaf / freemarker
    - spring-boot-starter-tomcat / jetty / undertow   
  - 数据库层
    - spring-boot-starter-jdbc
    - spring-boot-starter-data-redis / mongodb / elasticsearch
  - 安全认证层
    - spring-boot-starter-security
    - spring-boot-starter-oauth2-resource-server / client
  - 监控运维层
    - spring-boot-starter-logging
    - spring-boot-starter-test
  - 消息与异步任务
    - spring-boot-starter-amqp
    - spring-boot-starter-kafka
  - Spring Boot 的集成能力
    - Spring Boot 的核心集成机制是基于以下几点：
      - 自动配置机制
      - Starter 启动器统一依赖管理
      - 内嵌容器与一体化运行
      - 配置与环境管理  


- 如何在Spring中连接MySQL？具体连接过程（初始化时机、初始化方式）是怎样的？
  - 依赖准备
  - 配置数据库连接 
    - SPRINGBOOT 在 application.properties 或 application.yml 中
    - 非 Boot 手动配置 DataSource。HikariCP 是 Spring Boot 默认使用的连接池，也可以选择 DBCP、C3P0 等。
  - 初始化时机
    - Spring 容器启动阶段
      - 容器扫描\@Configuration 类，解析 \@Bean。
      - DataSource Bean 被创建（初始化连接池，准备连接）。  
    - 第一次使用时 
     - 对于懒加载 DataSource，可能连接池会延迟初始化，第一次获取连接时才真正连接数据库。
    - 事务管理与数据库访问
      - DataSource 初始化完成后，JdbcTemplate、MyBatis SqlSessionFactory 或 JPA EntityManager 就可以使用 DataSource 进行数据库操作。
    - 总结：初始化分为 容器启动初始化 Bean 和 第一次获取连接使用 两个阶段。

- 为什么需要Mybatis这类ORM框架？它相比“裸写SQL”有什么优势？
  - 裸写 SQL 的问题
    - 重复代码多,每次操作都需要写连接、关闭、异常处理、ResultSet 转对象的逻辑，代码冗余。
    - 维护成本高
      - 表结构改变或字段变化时，需要手动修改大量 SQL 和映射逻辑。
    - 类型安全差
      - ResultSet.getXXX 全部手动处理，容易出错。
    - 动态 SQL 难维护
      - 复杂条件拼接 SQL 很麻烦，容易出错。
  - MyBatis 的优势
    - 代码简洁：自动映射 ResultSet 到 Java 对象，不用手动遍历 ResultSet
    - 可维护性：SQL 写在 XML 或注解里，业务逻辑和数据库逻辑分离，修改 SQL 不影响 Java 代码结构
    - 动态SQL：提供 <if>、<choose>、\${}、\#{} 等动态 SQL 标签
    - 类型安全：\#{} 会做类型转换和防 SQL 注入
    - 缓存支持：一级缓存、二级缓存
    - 与 Spring 等框架无缝集成

- Mybatis的二级缓存
  - 一级缓存
    - 同一个 SqlSession 对同一条 SQL 查询，如果参数相同，第二次会直接从缓存取，不会再查询数据库
    - 清空时期：
      - SqlSession 关闭
      - 执行了增删改操作（INSERT、UPDATE、DELETE）
      - 手动调用 clearCache() 
  - 二级缓存（Global Cache）  
    - 默认关闭
    - 同一个 Mapper 的查询结果可以被不同的 SqlSession 共享。  
    - 清空时期：
      - Mapper 下执行了增删改操作
      - 手动清除缓存
      - 过期时间或容量策略触发清理  

  - mapper底层是靠sqlsession实现的
    - 若在事务中，也就是代码加上transaction注解，所有在这个线程中执行的 Mapper 方法都会共用这个 SqlSession。    
    - 没有事务，每次调用 Mapper 方法时，SqlSessionTemplate 检查线程上下文：没有事务 → 当前线程无 SqlSession → 新建一个。用完立即关闭  

- 依赖注入底层
  - 依赖注入：依赖注入和控制反转恰恰相反，它是一种具体的编码技巧。我们不通过 new 的方式在类内部创建依赖类的对象，而是将依赖的类对象在外部创建好之后，通过构造函数、函数参数等方式传递（或注入）给类来使用。
  - Spring依赖注入怎么把private属性注入的
    - Spring 能把 private 属性注入进去，原理是通过反射（reflection）绕过可见性限制来设置字段值。虽然字段注入（field injection）直接在 private 字段上加注解最简单，但在可测试性、可维护性和设计上通常推荐使用构造器注入。
  - setter注入有空对象问题
    ```java
        @Component
    public class A {
        private B b;

        @Autowired
        public void setB(B b) {
            this.b = b;
        }

        // 构造函数里访问 b（此时 b 还没注入）
        public A() {
            System.out.println(b.doSomething()); // ❌ NullPointerException
        }
    }
 
    ```
    - 此时 b 还没注入，调用 b.doSomething() 会抛空指针异常。

  - 除了使用反射还有什么方法来进行值的设置
    - Spring 的优化方式：BeanWrapper + PropertyAccessor
    - Spring 后来为了性能引入了：CGLIB / ASM 动态字节码访问
      - Spring 为了提升性能，在频繁调用 setter 的场景下（比如大批量注入）可能会启用
        - ReflectUtils（基于 CGLIB）
        - BeanUtils（基于 ASM）
        - 来 动态生成访问器类（Accessor）。
      - 这样它可以在运行时生成类似下面的代码：
        ```java
                class User$$BeanAccessor {
            void setName(User bean, String value) { bean.setName(value); }
        }

        ```
        - 然后后续注入时就直接调用这个方法，而不是用反射。
    - Spring 还能利用：MethodHandle / VarHandle（JDK 8+ 优化）
      - 这些是 Java 的轻量级反射机制，底层能直接使用 JVM 的调用指令


- spring是如何解决循环依赖的？
  - 循环依赖指的是两个类中的属性相互依赖对方：例如 A 类中有 B 属性，B 类中有 A属性，从而形成了一个依赖闭环
  - 循环依赖问题在Spring中主要有三种情况：
    - 第一种：通过构造方法进行依赖注入时产生的循环依赖问题。
    - 第二种：通过setter方法进行依赖注入且是在多例（原型）模式下产生的循环依赖问题。
    - 第三种：通过setter方法进行依赖注入且是在单例模式下产生的循环依赖问题。
  - 只有【第三种方式】的循环依赖问题被 Spring 解决了，其他两种方式在遇到循环依赖问题时，Spring都会产生异常。
  - Spring 在 DefaultSingletonBeanRegistry 类中维护了三个重要的缓存 (Map)，称为“三级缓存”：
    - singletonObjects (一级缓存)：存放的是完全初始化好的、可用的 Bean 实例，getBean() 方法最终返回的就是这里面的 Bean。此时 Bean 已实例化、属性已填充、初始化方法已执行、AOP 代理（如果需要）也已生成。
    - earlySingletonObjects (二级缓存)：存放的是提前暴露的 Bean 的原始对象引用 或 早期代理对象引用，专门用来处理循环依赖。当一个 Bean 还在创建过程中（尚未完成属性填充和初始化），但它的引用需要被注入到另一个 Bean 时，就暂时放在这里。此时 Bean 已实例化（调用了构造函数），但属性尚未填充，初始化方法尚未执行，它可能是一个原始对象，也可能是一个为了解决 AOP 代理问题而提前生成的代理对象。
    - singletonFactories (三级缓存)：存放的是 Bean 的 ObjectFactory 工厂对象。，这是解决循环依赖和 AOP 代理协同工作的关键。当 Bean 被实例化后（刚调完构造函数），Spring 会创建一个 ObjectFactory 并将其放入三级缓存。这个工厂的 getObject() 方法负责返回该 Bean 的早期引用（可能是原始对象，也可能是提前生成的代理对象），当检测到循环依赖需要注入一个尚未完全初始化的 Bean 时，就会调用这个工厂来获取早期引用。
  - Spring 通过 三级缓存 和 提前暴露未完全初始化的对象引用 的机制来解决单例作用域 Bean 的 sette注入方式的循环依赖问题。
  - 假设存在两个相互依赖的单例Bean：BeanA 依赖 BeanB，同时 BeanB 也依赖 BeanA。当Spring容器启动时，它会按照以下流程处理：
    - 第一步：创建BeanA的实例并提前暴露工厂。
      - Spring首先调用BeanA的构造函数进行实例化，此时得到一个原始对象（尚未填充属性）。紧接着，Spring会将一个特殊的ObjectFactory工厂对象存入第三级缓存（singletonFactories）。这个工厂的使命是：当其他Bean需要引用BeanA时，它能动态返回当前这个半成品的BeanA（可能是原始对象，也可能是为应对AOP而提前生成的代理对象）。此时BeanA的状态是"已实例化但未初始化"，像一座刚搭好钢筋骨架的大楼。
    - 第二步：填充BeanA的属性时触发BeanB的创建。
      - Spring开始为BeanA注入属性，发现它依赖BeanB。于是容器转向创建BeanB，同样先调用其构造函数实例化，并将BeanB对应的ObjectFactory工厂存入三级缓存。至此，三级缓存中同时存在BeanA和BeanB的工厂，它们都代表未完成初始化的半成品。
    - 第三步：BeanB属性注入时发现循环依赖。
      - 当Spring试图填充BeanB的属性时，检测到它需要注入BeanA。此时容器启动依赖查找：
        - 在一级缓存（存放完整Bean）中未找到BeanA；
        - 在二级缓存（存放已暴露的早期引用）中同样未命中；
        - 最终在三级缓存中定位到BeanA的工厂。
      - Spring立即调用该工厂的getObject()方法。这个方法会执行关键决策：若BeanA需要AOP代理，则动态生成代理对象（即使BeanA还未初始化）；若无需代理，则直接返回原始对象。得到的这个早期引用（可能是代理）被放入二级缓存（earlySingletonObjects），同时从三级缓存清理工厂条目。最后，Spring将这个早期引用注入到BeanB的属性中。至此，BeanB成功持有BeanA的引用——尽管BeanA此时仍是个半成品。
    - 第四步：完成BeanB的生命周期。
      - BeanB获得所有依赖后，Spring执行其初始化方法（如PostConstruct），将其转化为完整可用的Bean。随后，BeanB被提升至一级缓存（singletonObjects），二级和三级缓存中关于BeanB的临时条目均被清除。此时BeanB已准备就绪，可被其他对象使用。
    - 第五步：回溯完成BeanA的构建。
      - 随着BeanB创建完毕，流程回溯到最初中断的BeanA属性注入环节。Spring将已完备的BeanB实例注入BeanA，接着执行BeanA的初始化方法。这里有个精妙细节：若之前为BeanA生成过早期代理，Spring会直接复用二级缓存中的代理对象作为最终Bean，而非重复创建。最终，完全初始化的BeanA（可能是原始对象或代理）入驻一级缓存，其早期引用从二级缓存移除。至此循环闭环完成，两个Bean皆可用。
  - 三级缓存的设计的精髓：
    - 三级缓存工厂（singletonFactories）负责在实例化后立刻暴露对象生成能力，兼顾AOP代理的提前生成；
    - 二级缓存（earlySingletonObjects）临时存储已确定的早期引用，避免重复生成代理；
    - 一级缓存（singletonObjects）最终交付完整Bean。
  - 整个机制通过中断初始化流程、逆向注入半成品、延迟代理生成三大策略，将循环依赖的死结转化为有序的接力协作。
  - 值得注意的是，此方案仅适用于Setter/Field注入的单例Bean；构造器注入因必须在实例化前获得依赖，仍会导致无解的死锁。


- Spring为什么用3级缓存解决循环依赖问题？用2级缓存不行吗？
  - Spring 必须用三级缓存解决循环依赖，核心是为了正确处理需要 AOP 代理的 Bean。如果只用二级缓存，会导致注入的对象形态错误，甚至破坏单例原则。
  - 举个例子：假设 Bean A 依赖 B，B 又依赖 A，且 A 需要被动态代理（比如加了 Transactional）。如果只有二级缓存，当 B 创建时去注入 A，拿到的是 A 的原始对象。但 A 在后续初始化完成后才会生成代理对象，结果就是：B 拿着原始对象 A，而 Spring 容器里存的是代理对象 A —— 同一个 Bean 出现了两个不同实例，这直接违反了单例的核心约束。
  - 三级缓存中的 ObjectFactory 就是解决这个问题的关键。它不是直接缓存对象，而是存了一个能生产对象的工厂。当发生循环依赖时，调用这个工厂的 getObject() 方法，这时 Spring 会智能判断：如果这个 Bean 最终需要代理，就提前生成代理对象并放入二级缓存；如果不需要代理，就返回原始对象。这样一来，B 注入的 A 就是最终形态（可能是代理对象），后续 A 初始化完成后也不会再创建新代理，保证了对象全局唯一。
  - 简单说，三级缓存的本质是 “按需延迟生成正确引用” 。它既维持了 Bean 生命周期的完整性（正常流程在初始化后生成代理），又在循环依赖时特殊处理，避免逻辑矛盾。而二级缓存缺乏这种动态决策能力，因此无法替代三级缓存。
  - 当 A 创建时，A 还没完成，无法立即知道是否需要代理（AOP 是在初始化后才判定的）。
    - AOP代理的生成，不是在「实例化」或「依赖注入」阶段，而是在：初始化阶段（initializeBean）调用 BeanPostProcessor 的 postProcessAfterInitialization() 时才发生。  
    - 实例化阶段创建 Bean 的空对象（裸对象），仅调用构造函数
    - 依赖注入阶段给对象注入依赖（属性赋值）
    - 初始化阶段	调用各种后置处理器、\@PostConstruct、InitializingBean、生成AOP代理等

- spring三级缓存的数据结构是什么？
  - 都是 Map类型的缓存，比如Map {k:name; v:bean}。
  - 一级缓存（Singleton Objects）：这是一个Map类型的缓存，存储的是已经完全初始化好的bean，即完全准备好可以使用的bean实例。键是bean的名称，值是bean的实例。这个缓存在DefaultSingletonBeanRegistry类中的singletonObjects属性中。
  - 二级缓存（Early Singleton Objects）：这同样是一个Map类型的缓存，存储的是早期的bean引用，即已经实例化但还未完全初始化的bean。这些bean已经被实例化，但是可能还没有进行属性注入等操作。这个缓存在DefaultSingletonBeanRegistry类中的earlySingletonObjects属性中。
  -     三级缓存（Singleton Factories）：这也是一个Map类型的缓存，存储的是ObjectFactory对象，这些对象可以生成早期的bean引用。当一个bean正在创建过程中，如果它被其他bean依赖，那么这个正在创建的bean就会通过这个ObjectFactory来创建一个早期引用，从而解决循环依赖的问题。这个缓存在DefaultSingletonBeanRegistry类中的singletonFactories属性中。

- 即使是三级依赖注入工厂对象，又是如何知道要生成代理对象还是原始对象的？
  - spring在暴露对象到二级缓存之前，在singletonFactories.put(beanName, () -> getEarlyBeanReference(beanName, beanInstance));这个函数里，会询问所有的 BeanPostProcessor，这些后置处理器可以决定：这个 Bean 是否需要被代理。
  - Spring 判断一个 Bean 是否要被代理（例如 \@Transactional），是通过扫描其类上的注解、切面表达式、接口匹配等静态信息实现的，根本不用等 Bean 初始化完成
  #image("Screenshot_20251026_112807.png")


- AOP在哪一层缓存实现的
  - 在 Spring 的三级缓存机制中，AOP 代理对象最早是由三级缓存中的 ObjectFactory 创建的，并被放入 二级缓存（earlySingletonObjects） 中，以解决循环依赖问题。所以说——AOP 代理最终出现在二级缓存中，但其创建逻辑源自三级缓存的工厂。

- 什么是IOC 
  - 即控制反转的意思，它是一种创建和获取对象的技术思想，依赖注入(DI)是实现这种技术的一种方式。传统开发过程中，我们需要通过new关键字来创建对象。使用IoC思想开发方式的话，我们不通过new关键字创建对象，而是通过IoC容器来帮我们实例化对象。 通过IoC的方式，可以大大降低对象之间的耦合度。
  - Spring IOC 实现机制
    - 反射：Spring IOC容器利用Java的反射机制动态地加载类、创建对象实例及调用对象方法，反射允许在运行时检查类、方法、属性等信息，从而实现灵活的对象实例化和管理。
    - 依赖注入：IOC的核心概念是依赖注入，即容器负责管理应用程序组件之间的依赖关系。Spring通过构造函数注入、属性注入或方法注入，将组件之间的依赖关系描述在配置文件中或使用注解。
    - 设计模式 - 工厂模式：Spring IOC容器通常采用工厂模式来管理对象的创建和生命周期。容器作为工厂负责实例化Bean并管理它们的生命周期，将Bean的实例化过程交给容器来管理。
    - 容器实现：Spring IOC容器是实现IOC的核心，通常使用BeanFactory或ApplicationContext来管理Bean。BeanFactory是IOC容器的基本形式，提供基本的IOC功能；ApplicationContext是BeanFactory的扩展，并提供更多企业级功能。

- 什么是Aop
  - 是面向切面编程，能够将那些与业务无关，却为业务模块所共同调用的逻辑封装起来，以减少系统的重复代码，降低模块间的耦合度。Spring AOP 就是基于动态代理的，如果要代理的对象，实现了某个接口，那么 Spring AOP 会使用 JDK Proxy，去创建代理对象，而对于没有实现接口的对象，就无法使用 JDK Proxy 去进行代理了，这时候 Spring AOP 会使用 Cglib 生成一个被代理对象的子类来作为代理。
  - Spring AOP 实现机制
    - Spring AOP的实现依赖于动态代理技术。动态代理是在运行时动态生成代理对象，而不是在编译时。它允许开发者在运行时指定要代理的接口和行为，从而实现在不修改源码的情况下增强方法的功能。
    - 基于JDK的动态代理：使用java.lang.reflect.Proxy类和java.lang.reflect.InvocationHandler接口实现。这种方式需要代理的类实现一个或多个接口。
    - 基于CGLIB的动态代理：当被代理的类没有实现接口时，Spring会使用CGLIB库生成一个被代理类的子类作为代理。CGLIB（Code Generation Library）是一个第三方代码生成库，通过继承方式实现代理。
  - AOP在spring中的应用
    - 事务管理
    - 日志记录
    - 权限控制
- 依赖注入了解吗？怎么实现依赖注入的？
  - 而依赖注入则是将对象的创建和依赖关系的管理交给 Spring 容器来完成，类只需要声明自己所依赖的对象，容器会在运行时将这些依赖对象注入到类中，从而降低了类与类之间的耦合度，提高了代码的可维护性和可测试性。
  - 具体到Spring中，常见的依赖注入的实现方式，比如构造器注入、Setter方法注入，还有字段注入。
  - 构造器注入：通过构造函数传递依赖对象，保证对象初始化时依赖已就绪。
  - SETTER方法注入：通过 Setter 方法设置依赖，灵活性高，但依赖可能未完全初始化。
  - 字段注入：直接通过\@Autowired 注解字段，代码简洁但隐藏依赖关系，不推荐生产代码。

- 运行时如何判定一个对象的类型？具体怎么用？
  - 使用 instanceof
    - instanceof 用来判断对象是否是某个类或其子类（或实现某个接口）的实例
    - 返回值是 boolean 类型（true 或 false）
    - 如果对象是 null，instanceof 会直接返回 false，不会抛出异常
  - 使用 getClass()
    - 和 instanceof 不同，它不会匹配子类；
    - getClass() 返回对象的 实际运行时类型
    - 如果要判断一个对象的精确类型，必须使用 getClass()；

- 能否通过反射拿到class上所有的方法（包括私有方法）？静态变量可以获得吗？
  - 可以。用 Java 反射你能拿到类上（以及父类链上）的所有方法、字段，包括私有的；静态变量也可以读取和修改，但有若干限制（模块系统 / final /安全管理器 等）。
  - getMethods()：返回 所有 public 方法（包含从父类/接口继承的 public）。
  - getDeclaredMethods()：返回 当前类声明的所有方法（包括私有、受保护、默认访问），但不包含父类的私有方法。
  - 如果想拿到父类链上的私有方法，需要沿着 Class getSuperclass() 逐级向上遍历并对每个类调用 getDeclaredMethods()。
  - 对于私有方法 / 字段，调用前需 method.setAccessible(true) 或 field.setAccessible(true)（在 Java 9+ 模块化后，可能触发非法反射访问/受限，需要 --add-opens 或使用 MethodHandles）。
  - 静态字段可以通过 Field.get(null) 读取，Field.set(null, value) 修改（null 表示没有实例）。如果字段是 final / 编译时常量，修改可能无效或行为不可预测。

- 反射能获取私有方法时，作用域范围是什么？能否调用私有方法？
  -  反射可以获取并调用私有方法，但前提是你在同一个 JVM 内部并且有权限绕过访问检查（通过 setAccessible(true)）
  - 作用域范围
    - 如果 不调用 setAccessible(true)：
      - 只能调用当前可见范围内的成员；
      - 私有方法、受保护方法、包私有方法等将抛出 IllegalAccessException。
    - 调用 setAccessible(true) 后
      - 你就告诉 JVM：“我确认要跳过 Java 语言层级的访问检查”。
      - 这是在同一个 JVM、同一个进程内的反射访问；
  - Java 9 引入 模块系统（Module System），即使 setAccessible(true)，跨模块访问未导出的包中的私有成员也会抛出：

- 私有方法可被反射获取，是否会导致私有属性/方法的安全问题？这种情况合理吗？
  - 从安全角度来看，这确实打破了 Java 封装性，如果被滥用，可能造成敏感数据泄露或破坏对象状态，因此在生产环境下应谨慎使用。
  - 但设计上这是有意为之：反射是框架和底层工具（如 Spring、JPA、序列化框架）实现通用功能的重要手段，它让框架能在不知道具体类结构的情况下动态创建对象、注入属性、调用方法。
  - 因此，从语言设计上讲这是合理的“受控开放”。
  - 如果确实需要限制反射访问，可以：
    - 使用 Java 模块系统（module-info.java）限制反射访问
    - 或通过框架约束和安全规范控制反射使用范围
    - 启用安全管理器（Security Manager，虽然在新版本中逐步弃用）
  - 反射确实能访问私有成员，会带来一定安全隐患，但这是 Java 有意提供的能力，用于框架、工具等特殊场景。正常业务代码应避免直接反射操作私有成员。




- A调用B的method1, B的method1调用this.method2, 代理会生效吗, 讲下原理
  - 代理不会生效
  ```
  A.call() → bProxy.method1() → target.method1() → target.method2()
  ```

  - 解决方案
    - 通过代理调用自己
      ```java
          @Autowired
    private UserService self; // 注意，注入的是代理对象自己

    public void method1() {
        self.method2(); // ✅ 走代理
    }
 
      ``` 
      - 也可以用((UserService) AopContext.currentProxy()).method2();但要先在配置类中启用：\@EnableAspectJAutoProxy(exposeProxy = true)
    - 方案2：把 method2 移到另一个类中
    ```java
          @Service
      public class B {
          @Autowired
          private C c;

          public void method1() {
              c.method2(); // 通过代理类调用
          }
      }

      @Service
      public class C {
          @Transactional
          public void method2() { ... }
      }
        
    ```



- 数据库主从同步延迟导致读脏数据，如何解决?
  - 为什么会出现“读脏数据”
    - 主从复制机制本身存在延迟。主从复制一般是：主库写入 → 写 binlog → 从库读取 binlog → 回放执行。如果主库压力大、从库落后（比如网络、IO、SQL 执行慢），就会出现从库延迟几百毫秒甚至几秒的情况。
  - 解决方案 
    - 读写分离 + 延迟检测（读主）
      ```java
      if (isAfterWriteOperation(userId)) {
          readFromMaster();
      } else {
          readFromSlave();
      }

      ```
      - 缺点：增加了读主的压力，降低了读性能。
    - 写后延迟读（等待主从同步）
      - 在写完后，等从库追上主库再读。
      - 基于 binlog 位点（GTID 或 File+Pos）
        - 记录写入时主库的 GTID；
        - 查询时要求从库已追到该 GTID 才允许读；
    - 读写一致性缓存层（推荐）
      - 写主库后，同时写缓存；
      - 读时优先读缓存；
      - 从库落后时不会读出旧数据；
      - 缓存可在主从同步后自动刷新。
      - 缓存一致性策略要设计好（写穿、失效）。
    - 半同步复制 (Semi-sync Replication)
      - 主库写入后必须等待至少一个从库确认接收 binlog 才返回成功。

- 分库分表后，如何解决跨分片查询?
  - 为什么分库分表后会有跨分片问题
    - 某些查询语句无法只在一个分片上完成：
      - 聚合类查询：SELECT COUNT(\*) FROM user;
      - 跨分表 JOIN：SELECT \* FROM order o JOIN user u ON o.user_id = u.id;
      - 全局排序 / 分页：ORDER BY create_time LIMIT 10
      - 模糊匹配 / 范围查询：WHERE id BETWEEN 1000 AND 2000
      - 全局唯一约束 / 唯一索引
  - 跨分片查询常见解决方案
    - 中间件层统一路由 + SQL 合并（推荐通用方案）
      - 大多数业务推荐用 ShardingSphere-JDBC（Java 应用内嵌） 或 ShardingSphere-Proxy（独立代理层）；
      - 原理：
        - SQL 解析：中间件拦截 SQL，分析路由规则；
        - 分片路由：判断需要访问哪些分片；
        - 并行查询：分发 SQL 到对应分片；
        - 结果合并：将结果集聚合、排序、去重后返回。
      - 缺点：  
        - 查询性能受限：跨分片 SQL 聚合代价大；
        - 中间件成为瓶颈；
    - 应用层聚合（手动路由 + 合并结果）
      - 应用程序根据分片键自己决定查询哪些分表；
      - 在程序中执行多次查询
      - 在内存中合并结果。
    - 引入全局索引 / 全局表
      - 将经常参与关联或查询的关键字段放到一个独立全局索引表；查询时先在索引表定位，再访问目标分片
    - 使用分布式数据库（自动路由 + 全局视图）
      - 代表：TiDB、OceanBase、PolarDB、CockroachDB

- MySQL索引的实现原理有哪些？
  - InnoDB 是最常用的存储引擎，它的索引采用 B+ 树（Balance Plus Tree） 结构。 
    - 每个节点是一个数据页（默认16KB）；
    - 非叶子节点 存储键值和子节点指针；
    - 叶子节点 存储实际数据（或主键引用）；
    - 所有叶子节点通过双向链表相连，方便范围查询。
    - 为什么是 B+ 树 而不是 B 树？
      - B+ 树的所有数据都在叶子节点，查询性能更稳定；
      - 叶子节点间有链表结构，支持高效的范围查询；
      - 非叶子节点只存键值，不存数据，单页可容纳更多索引项，降低树高，提高检索效率。
  - Hash 索引（Memory 引擎）
    - 基于 哈希表（Hash Table） 实现；
    - 只适用于等值查询（=、IN），不支持范围、排序；
    - 时间复杂度 O(1)，但是：
      - 不支持范围扫描；
      - 不稳定（哈希冲突会影响性能）；
      - 不支持部分匹配（like ‘abc%’）。
  - R-Tree（空间索引）
    - 用于地理空间类型（如 GEOMETRY、POINT）；
    - 支持矩形范围查询；
    - 应用场景如地图位置匹配。
  - 全文索引（Full-Text Index）
    - 实现原理：倒排索引（Inverted Index）；
    - 维护词 -> 文档ID 的映射；
    - 适合文本搜索（如新闻标题、商品描述）。



- 什么时候联合索引失效
  - 违反最左匹配原则
  - 最左列使用了范围查询后再查别的列
  - like 不是前缀匹配 如'%Tom%' % 开头会导致索引失效
  - 使用函数或运算
  - 发生隐式类型转换可能失效
  - OR 混用未建索引列 WHERE age = 30 OR gender = 'M' gender 无索引导致整体失效
  - 查询优化器判断全表扫描更优


- 用过explain吗？介绍其返回结果中主要字段的意义。
  - EXPLAIN 用于分析 MySQL 查询语句的执行计划，帮助我们了解优化器是如何访问表、使用哪些索引、扫描了多少行数据。
  - 重点字段深入说明
    - type（访问类型）是最关键指标，反映查询性能的好坏，常见取值从好到坏：
      - SYSTEM：表中只有一行数据（系统表）
      - const：通过主键或唯一索引一次命中
      - eq_ref：多表连接时，主键或唯一索引匹配
      - ref：非唯一索引或前缀索引匹配
      - range：范围扫描索引
      - index：全索引扫描
      - ALL：全表扫描，性能最差
      - 优化目标是尽量让 type 到达 range 级别以上（最好是 ref 或 const）。
    - Extra 常见取值（反映优化空间）
      - using index：使用了覆盖索引（性能好）
      - using where：需要通过 WHERE 过滤数据
      - using temporary：使用了临时表（性能差）
      - using filesort：使用了文件排序（性能差）
      - Using join buffer：使用了连接缓存（说明没走索引）
      - Impossible WHERE：条件恒为假
      - Select tables optimized away：优化器优化掉了子查询  
    - key：实际使用的索引名称
    - rows：估算需要扫描的行数，行数越少越好
    - filtered：表示经过 WHERE 过滤后剩余行的比例

- 基于“主键为xxxid，查询未删除（软删，有deleted_at字段）的数量，explain显示扫描10条，filter命中50%”的场景，说明SQL执行时做了哪些事情？
  - 解析 SQL 语句、确定表和列，检查语法、确认字段名
  - 优化阶段，选择执行计划，决定是否走索引
    - MySQL 优化器分析 WHERE 条件：
      - deleted_at IS NULL
      - 如果 deleted_at 没有索引，优化器决定 全表扫描（type=ALL）；
      - 如果有索引但选择性低（很多都是 NULL 或非 NULL），优化器可能仍选择 不走索引；
  - 执行器拿到执行计划后，做以下几件事：
    - 从存储引擎读取行数据
      - 若 type=ALL，执行器会扫描整个表（假设有 10 行数据）；
      - 若 type=range，则按索引范围扫描部分行。  
    - 逐行应用过滤条件
      - 对每行判断 deleted_at IS NULL；
    - 统计符合条件的行数
      - 对于 COUNT(\*)，不返回行内容，只增加计数器。  
    - 返回聚合结果  
  - 从binlog层面介绍上述SQL执行过程中的相关操作。
    - 这条 SQL 是 查询语句（SELECT），因此它是只读操作，不会对数据产生修改。所以它不会生成 binlog 日志。
    - binlog记录所有会修改数据库内容的语句或行事件（用于主从复制、数据恢复）。


- 介绍MySQL事务？
  + 事务的定义
    - 事务（Transaction） 是一组操作的逻辑单元，这些操作要么全部执行成功，要么在发生错误时全部回滚（撤销）。
  + 事务的四大特性（ACID）
    - 原子性
    - 一致性
    - 隔离性
    - 持久性
  + 事务的隔离级别
  + 事务实现原理
    - Redo Log 持久性
    - undo log 原子性
    - MVCC 可重复读和并发性能
    - 锁机制（行锁/间隙锁）保证隔离性


- MySQL事务隔离级别？分别解决什么问题？
  - 读未提交
  - 读可提交
    - 解决脏读问题
      - 每次select生成快照
      - 脏读：读到事务未提交的数据
  - 可重复读
    - 解决脏读和不可重复读问题
      - sql标准：锁当前行，读数据加共享锁，写数据加排他锁
      - 不可重复读：两次读到的数据不一样
  - 可串行化
    - 强制加锁，串行执行
    - 解决幻读问题
      - 幻读：两次读到的数据条数不一样

- sql标准的rr和innodb的rr不一样
  - SQL 标准的 RR 只保证“已读行不变”，但不锁定查询范围，所以其他事务可以插入新行导致“幻读”。RR 在标准里 ≠ “事务级快照”，而是 “行级锁定可重复读”。
  - InnoDB 的 RR 加了 MVCC + 间隙锁，既能保持行内容一致，又能锁定范围，从而防止幻读。

- 可重复读如何实现的
  - 可重复读（Repeatable Read）的实现核心是：在同一个事务中，多次读取同一条数据时，保证结果一致，即防止不可重复读。实现方式主要依赖于 锁机制 或 多版本控制（MVCC）
  - 基于锁的实现（Pessimistic Lock）
    - 当事务读取数据时，会对读取的行加共享锁（S锁）。
    - 如果事务要修改数据，会申请排他锁（X锁）。
    - 其他事务在未释放共享锁前，不能修改这条数据。  
    - 幻读可能通过范围锁（Range Lock）进一步解决（MySQL InnoDB 可加间隙锁）。
  - 基于 MVCC 的实现（Optimistic, MySQL InnoDB 的实现方式）
    - 数据库为每行数据维护一个版本号或时间戳。
    - 事务开始时，会记录当前数据库版本号（snapshot）。
    - 事务读取数据时，总是读取该事务开始时存在的最新版本。
    - 写操作仍然会加行锁，保证写一致性。
    - 幻读仍可能出现（除非加额外间隙锁）。



- 三类存储引擎分别支持哪些索引？
  #image("Screenshot_20251018_193137.png")
  - InnoDB —— B+ Tree 索引 + 聚簇索引
    - 主键索引：聚簇索引（Clustered Index）
      - 叶子节点存储整行数据。
    - 二级索引（辅助索引）：B+ Tree
      - 叶子节点存储主键值，而非数据本身。
    - 还使用了 自适应哈希索引（Adaptive Hash Index），自动维护高频查询的哈希缓存。
  - MyISAM —— B+ Tree 索引 + 非聚簇结构
    - 主索引与数据分离：
      - .MYI 文件存索引；
      - .MYD 文件存数据。
    - 叶子节点存的是数据文件的物理地址（偏移量）。    
    - 读操作非常快，但不支持事务与崩溃恢复。
  - MEMORY —— Hash 索引（默认）或 B+Tree
    - 默认使用 Hash 索引（等值查找快，范围查找差）；
    - 也可以手动指定 USING BTREE；
    - 数据存于内存，掉电即失。

- 不同存储引擎的优缺点？
  - InnoDB
    - 优点：
      - 支持 事务（ACID），保证数据一致性。
      - 行级锁，高并发写入性能好。
      - 支持 外键约束，保证参照完整性。
      - 默认采用 聚簇索引，查询主键非常快。
      - 支持崩溃恢复（redo log、undo log）。
    - 缺点：
      - 相比 MyISAM，占用空间大。
      - 全文索引支持起步晚（MySQL 5.6+）。
      - 写入稍慢（事务、行锁、日志开销）。
  -  MyISAM
    - 优点
      - 存储格式简单，查询速度快，尤其是 读密集型场景。
      - 全文索引支持早，适合全文搜索。
      - 占用空间比 InnoDB 小。   
    - 缺点：
      - MyISAM 不支持事务（Transaction），也没有 ROLLBACK、COMMIT、SAVEPOINT 等机制。
      - 仅支持表级锁（Table Lock）
      - MyISAM 表结构简单但容易损坏（尤其是异常关机或系统崩溃时）。
      - 不支持外键（Foreign Key）
      - 写入性能差（在高并发环境下）
      - 不支持崩溃恢复与日志（无 redo/undo log）
    - 以读为主的系统（如日志分析、搜索引擎索引）；
    - 不要求事务一致性的离线分析场景；
    - 小型嵌入式应用或内存受限系统。
  - Memory
    - 优点：
      - 数据 全部存储在内存，读写速度极快。
      - 支持 表级锁、哈希索引，精确查找速度快。
    - 缺点：
      - 数据 断电或重启丢失，不持久化。
      - 哈希索引只适合精确匹配，范围查询性能差。
      - 表大小受内存限制，通常用于 临时表或缓存。
  - CSV
    - 每行数据存成 CSV 文本，易于导入导出

- 聚簇索引和非聚簇索引
  - 聚簇索引：通常是 B+ 树叶子节点存储实际数据行。查询主键数据直接命中叶子节点，无需再回表。
  - 非聚簇索引：B+ 树叶子节点只存 索引列 + 指向数据行的地址（InnoDB 是主键，MyISAM 是物理行地址）。查询非主键列时，需要先查索引，再根据 rowid 回表取数据。

- MySQL中聚合函数之后可以使用子查询嘛？
  - 可以，但要分场景。  
  - 在 SELECT 中使用子查询（允许）
  - 在 WHERE 中使用聚合函数不允许
    - WHERE 在 GROUP BY 之前执行；此时聚合函数还没执行，AVG(salary) 还不存在；
  - HAVING 可以使用聚合函数
    - HAVING 在 GROUP BY 之后执行，此时聚合结果已生成，可以用 AVG(salary) 过滤分组；
    ```
        SELECT department_id, AVG(salary)
    FROM employees
    WHERE AVG(salary) > 5000  -- ❌ 报错
    GROUP BY department_id;

    ```
          ```
          SELECT department_id, AVG(salary)
      FROM employees
      GROUP BY department_id
      HAVING AVG(salary) > 5000;

    ```
  - 在 FROM 子句中使用子查询（聚合在子查询内）
  - 在聚合函数内部使用子查询（允许但要小心性能）
    ```
        SELECT 
        SUM((SELECT MAX(price) FROM products WHERE category_id = c.id)) AS total_max_price
    FROM categories c;

    ```
   - 每行都要执行一次子查询，性能可能很差。

- mysql中的主流的日期函数？
  - NOW()   	2025-10-27 16:05:33
  - SYSDATE()  2025-10-27 16:05:33
  - CURDATE()  2025-10-27 
  - CURRENT_TIMESTAMP   2025-10-27 16:05:33
  - CURTIME()   16:05:33
  - DATE_ADD(date, INTERVAL n unit)  SELECT DATE_ADD('2025-10-27', INTERVAL 7 DAY);   2025-11-03
  - SELECT DATE_FORMAT(NOW(), '%Y/%m/%d %H:%i:%s');

- MySQL中查询前两天的数据该使用什么时间函数？
  ```
      SELECT *
    FROM your_table
    WHERE date_column >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)
      AND date_column < CURDATE();

  ```
  OR
  ```
    SELECT *
  FROM your_table
  WHERE date_column >= NOW() - INTERVAL 2 DAY;

  ``` 

- mysql中.delete和drop的区别？
  - 删除表中的部分数据
  DELETE FROM user WHERE id = 5;

  - 删除表中所有数据
  DELETE FROM user;

  - 删除整个表
  DROP TABLE user;

  -删除整个数据库
  DROP DATABASE testdb;
  - DELETE可以使用WHERE子句来删除符合条件的行，而DROP是直接删除整个表或数据库，无法指定条件。
  - DELETE删除数据后，表结构和索引仍然存在，而DROP会删除表结构和所有相关的索引。
  - DELETE操作可以通过事务回滚，而DROP操作一旦执行，数据无法恢复。
  - DELETE会触发触发器，而DROP不会触发任何触发器。
  - DELETE 不会立即释放磁盘空间（仅标记删除），而 DROP 会立即释放表所占用的所有磁盘空间。


- 什么是触发器
  - 触发器（Trigger） 是一种由数据库自动执行的 特殊存储过程，当特定的数据库事件（如 INSERT、UPDATE、DELETE）在某张表上发生时，数据库会自动执行触发器中定义的逻辑。
  - 在 MySQL 中，触发器分为两种触发时机：
    - BEFORE 触发器：在数据操作之前执行，可以用来验证或修改即将插入/更新的数据。
    - AFTER 触发器：在数据操作之后执行，通常用于记录日志或  
  ```
      -- 创建触发器：在插入 user 表之前，自动将 name 转为大写
    CREATE TRIGGER before_user_insert
    BEFORE INSERT ON user
    FOR EACH ROW
    BEGIN
        SET NEW.name = UPPER(NEW.name);
    END;

  ```
  - 常见用途
    - 数据验证和清洗
    - 自动生成衍生数据
    - 维护审计日志
    - 实现复杂的业务规则

- mysql中truncate和delete的区别？
  - delete可以条件删除，truncate清空整张表
  - delete会逐行删除，触发删除触发器，性能较慢；truncate是快速删除，重置表，不能触发删除触发器，性能快。
  - delete删除的数据可以回滚，truncate删除的数据不能回滚。
  - truncate会重置自增ID，delete不会。
  - truncate是DDL语句，会隐式提交事务，delete是DML语句

- DDL和DML
  - DDL 管结构，定义数据库对象。
  - DML 管数据，操作数据库内容。   
  #image("Screenshot_20251027_162145.png")

- MySQL中行转列，列转行如何操作？
  - 行转列
    #image("Screenshot_20251027_162429-1.png")
    - 使用 CASE WHEN 手动透视（推荐方式）
    
    ```
        SELECT
          name,
          MAX(CASE WHEN subject = '语文' THEN score END) AS 语文,
          MAX(CASE WHEN subject = '数学' THEN score END) AS 数学
      FROM score
      GROUP BY name;
    
    ```
    - 用 WHERE  
      - 你只能做两个查询然后手动去 join：
            ```
            SELECT
        a.name,
        a.语文,
        b.数学
      FROM
        (SELECT name, score AS 语文 FROM score WHERE subject='语文') a
      LEFT JOIN
        (SELECT name, score AS 数学 FROM score WHERE subject='数学') b
      ON a.name = b.name;

      ```     
      - 结果虽然一样，但需要写两次子查询和一次 JOIN，
  - 列转行（Column → Row）
    #image("Screenshot_20251027_162517.png")
    - 方法：使用 UNION ALL
    ```
        SELECT name, '语文' AS subject, 语文 AS score FROM score_table
    UNION ALL
    SELECT name, '数学' AS subject, 数学 AS score FROM score_table;

    ```

- 了解过游标吗？
  - 游标（Cursor） 是一种能让你“逐行”处理查询结果集的机制。   
  - 通常我们执行 SQL 查询时，是一次性返回整个结果集。但如果你希望 逐行地读取、判断、处理 结果集（比如循环更新、计算、条件控制），这时候普通 SQL 不够用了，就可以用“游标”。
  - 游标的使用
    - 定义    
    ```
        DECLARE emp_cursor CURSOR FOR
    SELECT id, name, salary FROM employee WHERE salary < 5000;

    ```
    - 声明变量（用于接收每行数据）
    ```
        DECLARE v_id INT;
    DECLARE v_name VARCHAR(100);
    DECLARE v_salary DECIMAL(10,2);
    ```
    - 打开游标
    ```
        OPEN emp_cursor;
    ```
    - 读取数据，使用 FETCH 从游标中逐行取数据： 
    ```      
      FETCH emp_cursor INTO v_id, v_name, v_salary;
    ```
      - 通常会配合一个循环结构：
    ```
        read_loop: LOOP
        FETCH emp_cursor INTO v_id, v_name, v_salary;
        IF done THEN
            LEAVE read_loop;
        END IF;
    ```
    - 关闭游标  
    ```
        CLOSE emp_cursor;
    ```
- 有两个数据库，一个查询数据库，一个写入数据库，如何使用mybatis随意切换这两个数据库？
  - 在 Spring Boot 的配置文件里配置两个数据库连接
  - 定义枚举标识不同数据源
  - 使用 ThreadLocal 保存当前线程使用的数据源
  - 创建动态数据源路由类
    - 这个类继承 Spring 的 AbstractRoutingDataSource，根据 ThreadLocal 动态返回目标数据源
  - 注册 Bean（组合两个数据源）
  - 配置 MyBatis 使用动态数据源
  - 提供注解方式切换数据源（推荐）
  - 这样，你在方法上加个注解即可随意切换数据库。

- mabatis中如何进行批量插入
  - 使用 \<foreach> 标签批量插入（最常见、推荐） 
  ```
    <!-- Mapper.xml -->
  <insert id="insertBatch" parameterType="list">
      INSERT INTO user (name, age)
      VALUES
      <foreach collection="list" item="item" separator=",">
          (#{item.name}, #{item.age})
      </foreach>
  </insert>

  ``` 
  - 使用 MyBatis 的批处理模式（ExecutorType.BATCH）
    - 这种方式使用 MyBatis 的底层批处理特性，每次调用 insert() 都不会立即发送 SQL，而是累积到批中，最后统一执行。
    ```
        SqlSession sqlSession = sqlSessionFactory.openSession(ExecutorType.BATCH);
    UserMapper mapper = sqlSession.getMapper(UserMapper.class);

    for (int i = 0; i < 10000; i++) {
        User user = new User();
        user.setName("User_" + i);
        user.setAge(20 + i % 10);
        mapper.insert(user); // 单条 insert
    }

    sqlSession.flushStatements(); // 执行批量提交
    sqlSession.commit();
    sqlSession.close();

    ```
- 怎么保证kafka消费的顺序
  - Kafka 的顺序保证是“分区级别的
    - Kafka 只能保证同一分区（Partition）内消息的顺序。不同分区之间的消息是无法保证顺序的。
    - 原因：一个 Topic 通常有多个 Partition；每个 Partition 内消息按偏移量（offset）有序；多个 Partition 并行消费，因此整体上消息到达消费者的顺序可能乱序。
  - 在同一 Partition 内，Kafka 如何保证顺序？
    - 日志结构（append-only log）
      - Kafka 的 Partition 是一个顺序写入的日志文件；
      - 每条消息都有自增的 offset；
      - 消费者按 offset 顺序拉取数据，因此天然有序。
    - 单线程读写
      - Producer 向某个 Partition 发送消息时是顺序写；
      - Consumer 在一个 Partition 上消费时也是单线程拉取消息。  
  - 如果业务要“全局顺序”怎么办？
    - Kafka 本身无法保证 跨分区顺序，但可以通过“合理分区策略”实现局部顺序或业务内顺序：
    - 按业务 key（如 userId）做分区
      - Kafka 会将相同 key 的消息映射到同一个 Partition。
      - 同一用户的所有消息在同一 Partition 内，自然顺序不乱
    - 消费者保持单线程消费同一 Partition
      - 每个 Partition 只能被一个消费者线程消费：

- Kafka 为什么快
  - 顺序写入日志
    - Kafka 不像数据库那样频繁随机写磁盘，而是采用 顺序写日志（append-only log） 的方式。
    - 数据写入时只追加到文件末尾，不做修改或随机插入。
    - 磁盘顺序写速度非常快（接近内存的速度），可达上百 MB/s
  - 页缓存（Page Cache）+ 零拷贝（Zero Copy）
    - Kafka 充分利用了操作系统提供的 Page Cache（文件系统缓存），并通过 零拷贝机制 提升性能：
      - Page Cache
        - Kafka 不自己缓存数据，而是依赖 OS 文件系统缓存。
        - 数据写入文件后会留在 OS 内核缓存中（dirty page），读写都走缓存，避免频繁磁盘 IO。
      - 零拷贝（Zero Copy） 
        - Kafka 使用 sendfile() 系统调用，将文件直接从内核缓冲区发送到 Socket。
        - 避免了 “内核态 ↔ 用户态” 的多次数据拷贝和上下文切换。
      - 批量发送与压缩（Batch + Compression）
        - Producer 将多条消息合并成一个 batch 再发送。
        - Broker 落盘时也按 batch 写入。
        - Consumer 拉取时一次性取多个 batch。
        - 此外支持 GZIP、LZ4、ZSTD 等压缩算法，对整个 batch 压缩，大幅降低带宽和磁盘使用。
      - 顺序读 + 零索引查找
        - Kafka 的消费是顺序读取日志文件（按 offset），无需复杂索引查找。
        - 每个 partition 是一个追加日志文件，消费者根据 offset 直接定位位置：
        - 消费者 offset 存储在独立的 topic（__consumer_offsets）中，轻量又持久。
      - 分区（Partition）并行 + 多副本复制
        - 每个 Topic 拆成多个 Partition；
        - 不同 Partition 可分布在不同 Broker 上；
        - Producer、Consumer 并发访问不同 Partition；
        - 副本（replica）异步复制，不阻塞主写流程。
      - 拉取模型（Pull）代替推送（Push）
        - Consumer 自己决定何时、拉多少数据；
        - 减少了 Broker 的推送压力；
      - 简单的存储结构（Log Segment + Index）
        - 每个 Partition 是一个 append-only 文件；
        - 通过 offset + index 文件快速定位；
        - 不需要复杂的锁竞争（append-only，写锁简单）；
        - 旧数据只需按 segment 删除（无需 GC）。
      - 内部线程模型优化
        - I/O 线程负责网络收发；
        - 后台线程负责落盘和副本同步；
        - Reactor 模型（Selector + poll）高并发处理连接；
        - 少量线程即可支撑成千上万个连接。
      #image("Screenshot_20251029_204640.png")
      #image("Screenshot_20251029_204652.png")

- KAFKA如何实现死信队列
  - Kafka 本身不自动处理死信消息，需要 应用层自己创建一个单独的 topic 作为死信队列
  - 消费者在消费主Topic时：若多次重试仍失败 → 将该消息发送到死信Topic。
  - 和rabbitmq不同
    - RabbitMQ 有内置的死信交换机和队列机制，配置后自动转发死信消息。
    - Kafka 需要应用代码显式处理死信逻辑。

- 死信队列的作用
  -	避免失败消息被系统直接丢弃
  - 防止坏消息反复重试、阻塞正常消费
  - 可以看到失败消息的内容、时间、异常原因
  - 可以人工修复或系统定时重新推送

- 消息丢失，消息重复消费怎么解决
  - 消息丢失
    - 生产端
      - ACK
      - 重试机制（重试次数、间隔）
      - 持久化消息到数据库即本地消息表（事务消息）
    - Broker 端
      - 多副本机制（replication factor ≥ 2）
      - 开启持久化（RabbitMQ durable queue + persistent message；Kafka 本身通过磁盘日志持久化）
      - 定期备份
    - 消费端
      - 消费者手动 ACK（处理成功后再确认）
      - 消费位点持久化（offset commit）
      - 消费确认机制
  - 消息重复消费
    - 每条消息带唯一 ID（如订单号、事务 ID）消费者处理前检查数据库是否存在该消息ID的处理记录
    - 用 Redis SET 或 String 记录已处理消息ID，SETNX messageId true EX 3600
    - 利用数据库幂等约束唯一索引
    - 专门的“消息消费表”记录 messageId 和状态


- 怎么在mq做订单业务的时候保证事务
  - 利用 MQ 自身的「半消息（half message）」机制来实现分布式事务。
    - 缺点：
      - 并非所有 MQ 支持（RabbitMQ 事务性能差，Kafka 要2.5+版本）
      - 增加 MQ 管理复杂度（事务回查）
    - 优点：
      - 原生支持事务，消息与业务操作强一致
      - 不依赖外部数据库表
      - 支持回查机制（MQ 会主动询问事务状态）
  - 本地消息表（经典方案）
    - 比如订单业务写入数据库时，同时写入一个消息表，这样，即使后续 MQ 宕机，消息也不会丢失。
    - 定时任务（或异步线程）扫描消息表：
      - 读取未发送的消息
      - 调用 MQ 发送消息
      - 更新消息状态为已发送
      - 不断重试，直到 MQ 发送成功为止。
      
  - 最终一致性 + 幂等消费（适用于高并发）
    - 每条消息带唯一 msgId
    - 消费端保存MSGid的消费状态
    - 超时未成功处理的消息由补偿任务重发


- 消息队列堆积如何快速处理?
  - 分析堆积原因
    - 消费者挂了/宕机
      - 恢复消费者服务
    - 消费逻辑太慢
      - 优化消费逻辑
    - 消息积压分布不均
      - 	增加分区或调整分配策略
    - 消费者线程数不足
      - 提高并发消费
    - 下游系统（DB/接口）慢
      - 异步写入或限流下游
  - 短期“应急”处理方案
    - 临时扩容消费者实例
      - 注意：Kafka 分区数决定最大并行度，如果分区不够，消费实例再多也无效。可考虑 临时增加 partition 数量。
    - 提升消费并发度
      - 每个消费者实例内使用 线程池并行处理消息
    - 批量拉取 N 条消息一次处理（减少网络往返）。
    - 对部分非关键任务（如日志、统计）暂存到本地或缓存中，延迟处理。

- 为何将“丢弃最老消息”作为消息队列满时的拒绝策略？该策略适合什么场景？哪些应用的MQ会侧重时效性？
  - 常见策略
    - 阻塞生产者
    - 丢弃新消息    
    - 丢弃最老消息
    - 抛异常
  - 为什么选择“丢弃最老消息（Drop Oldest）”
    - 系统优先保证数据的时效性（freshness）而非完整性（completeness）。 
    - 优势
      - 维持系统实时性（最新消息总能进入队列）
      - 避免队列阻塞上游系统（不会阻塞生产者）
      - 可保持系统可用性与响应性
    - 劣势
      - 丢弃旧消息意味着数据不完整；
      - 不适用于必须处理“每条消息”的系统。
    - 适合“时效性优先”的场景
      - 股票/行情推送系统
      - 游戏状态
      - 传感器数据
      - 视频
      - 实时监控系统    

- MQ适合的场景有哪些？在容量有限的场景下，延迟消息和削峰填谷场景分别适合什么拒绝策略？
  - MQ 适合的典型场景
    - 系统解耦
    - 异步分流
    - 流量削峰      
    - 延时/定时任务
    - 流式处理
    - 日志收集
    - 广播 / 分发 
  - 延迟消息（可靠性优先）
    - 阻塞生产者（Block）
    - 重试入队
    - 抛异常 + 业务回退
  - 削峰填谷（实时性优先）
    - 丢弃最老消息（Drop Oldest）
    - 限流
    - 降级处理（Fallback）
    - 丢弃最新消息（让上游重试 ）
      - 视频转码、文件处理、订单清算。   



 - Elasticsearch 构建倒排索引时，文档和分词数量多导致内存占用大，有哪些节省空间、提高性能的办法？
   - 减少分词数量（源头减量） 
     - 控制分词粒度（使用合理分词器）
       - 中文分词器如 ik_max_word 会把句子切得非常碎，产生指数级 term 数量。
       - 建议改为"analyzer": "ik_smart"
       - 一般可减少 40%~60% 的 term 数量。
    - 对不搜索的字段禁用分词
      - 例如商品的 ID、类别、品牌代码、商户ID、SKU 等，只需精确匹配，不用分词。
    - 合并字段（减少冗余）
  - 索引层优化（节省倒排索引空间）
    - 开启压缩算法
    - 减少 source 或存储字段
    - 如果 source 太大（商品描述、图片URL等），可以只保留必要字段
    - 合理使用 doc_values
  - 索引过程与 segment 管理优化
    - 调整 segment merge 策略
      - 索引构建时，Lucene 会不断合并小 segment → 大 segment，非常耗内存和 CPU。
    - 调整 refresh 与 flush 策略
      - 默认 ES 每秒刷新一次内存 buffer 为 segment，产生大量小段。批量导入时可关闭
  - 运行时内存与 JVM 调优
    - 增大堆外内存利用率
      - ES 大部分索引结构（倒排表、FST、term dictionary）在 堆外（off-heap） 管理。
    - 禁用 fielddata（或按需加载）
      - fielddata 是 ES 在内存中为 text 字段构建的倒排缓存，非常吃内存。


- jvm调参常用参数有哪些
  #image("Screenshot_20251029_201923.png")
  - xms 初始堆大小 如：-Xms512m 这是VM 启动时分配的堆内存大小。通常与 -Xmx 设为相同，避免动态扩容。
  - xmx 最大堆大小 如：-Xmx2g 这是 VM 可使用的最大堆内存大小。根据应用需求和服务器内存设置。	限制 JVM 可用的最大堆内存，防止 OOM。
  - xmn 年轻代大小 如：-Xmn256m 设置年轻代内存大小。年轻代越大，Minor GC 越少，但会占用更多堆空间。
  - xss 线程栈大小 如：-Xss512k 设置每个线程的栈大小。栈太小可能导致 StackOverflowError，太大可以有更多线程空间但线程数受限。
  - -XX:MetaspaceSize / -XX:MaxMetaspaceSize 元空间初始 / 最大大小 如：	-XX:MaxMetaspaceSize=256m
  - -XX:+UseG1GC 启用 G1 垃圾收集器 适用于大内存应用，低延迟需求。
  - -XX:+UseConcMarkSweepGC 启用 CMS 垃圾收集器 适用于低延迟应用，但已被 G1 取代。
  - -XX:+UseParallelGC 启用并行垃圾收集器 适用于吞吐量优先的应用。
  - XX:+UseZGC 启用 ZGC 垃圾收集器 适用于超大内存应用，极低延迟需求（JDK 11+）。
  - XX:MaxGCPauseMillis 最大停顿时间目标 JVM 希望（但不保证） 每次垃圾回收导致的应用线程停顿时间 不超过这个目标值。
  - XX:GCTimeRatio GC 吞吐量目标 如：-XX:GCTimeRatio=9 表示 10% 时间用于 GC，90% 用于应用。
  - XX:+HeapDumpOnOutOfMemoryError OOM 时生成堆快照也就是堆转储文件，便于分析内存泄漏。
  - -Xlog:gc\* GC 日志记录（JDK 9+） 如：-Xlog:gc\*:file=gc.log:time,uptime,level,tags



- 一个实时聊天系统，一个文件上传系统，这两个系统JVM参数怎么设置
  - 实时聊天系统（低延迟、高并发）
    - 要求 GC 延迟极低
    - 一般是 CPU/线程调度密集型
      - 基础内存：固定内存，避免动态扩容导致停顿。
      - GC算法：	G1 适合低延迟，ZGC 适合极低延迟（JDK 11+）
      - 暂停时间目标：G1 的目标暂停时间（可根据业务调到 50ms）
      - 线程栈大小-Xss256k：	聊天系统线程多（例如 Netty），减小栈空间节约内存
      - 直接内存-XX:MaxDirectMemorySize=512m：Netty 使用直接内存；需根据连接数和 buffer 估算
      - GC日志
  - 文件上传系统（I/O 密集、吞吐优先）
    - 要求 高吞吐、较大堆空间
    - 通常有异步线程池、缓存、临时文件缓冲
      - 基础内存-Xms2g -Xmx4g：文件缓存较多，适度放大堆
      - GC 算法：Parallel 吞吐优先；G1 更平衡
      - GC 吞吐目标-XX:GCTimeRatio=9：表示 10% 时间用于 GC（吞吐优先）
      - 直接内存-XX:MaxDirectMemorySize=1g：文件传输常用 NIO DirectBuffer
      - 文件缓存优化：-Dio.netty.maxDirectMemory=1g：若使用 Netty 传文件
      - 线程池优化：降低过多上传线程，防止上下文切换浪费 CPU
      - GC日志
  
- io密集型和cpu密集型有什么区别
  - I/O 密集型
    - 主要瓶颈在 输入/输出（I/O）操作 上，比如 磁盘读写、网络请求、数据库访问。
    - CPU 大部分时间在等待数据（磁盘、网络）返回；
    - CPU 利用率低，而 I/O 子系统繁忙；
    - 并发数量多可以显著提高吞吐量（因为 I/O 等待时可切换任务）。
  - CPU 密集型
    - 主要瓶颈在 处理器计算能力 上，比如 大量数学运算、图像处理、视频编码等。     
    - CPU 利用率高，几乎一直在工作
    - 并发数太多不会提升性能，反而增加上下文切换负担。



- 程序申请100字节的内存，操作系统是马上拿出100字节的内存吗？
  - malloc 只是向操作系统申请“虚拟内存地址空间”
  - 操作系统只是在页表中登记了这块地址空间属于该进程，但并没有真正分配物理内存页。
  - 真正的物理内存在以下时机才会被分配：
    - 当程序第一次访问（读/写）那块虚拟地址空间时，CPU 触发缺页异常（page fault）；
      - 缺页异常
        - 如果页表项中发现该页不存在（没有分配物理页），或者在磁盘上（被换出去了），或者权限不匹配（只读页被写入）
      - 缺页异常处理的详细步骤
        - CPU 发现页表无效
        - 内核判断缺页原因
        #image("Screenshot_20251020_201239.png")
        - 如果合法 → 分配/加载物理页
        - 恢复执行
    - 操作系统捕获异常后，才会从物理内存（或交换区）中分配实际的页（通常4KB一页）；
    - 然后更新页表，使这块虚拟地址指向真实的物理页。
  - 操作系统以 页（page） 为最小分配单位（通常一页=4KB）。
  - 所以实际上你“只用了100字节”，但系统给了你4096字节的物理内存。


- 假如我现在要从磁盘上去读一个文件，读完之后对它进行修改，然后再写回去。这个过程操作系统的内核它会做什么事情？


- 从 Redis 视角，接收“get key”请求时，网络及操作系统层面的处理过程是怎样的？

