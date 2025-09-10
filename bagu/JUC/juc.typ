+ JAVA并发面试题
  - 多线程
    -  java里面的线程和操作系统的线程一样吗？
      - Java 底层会调用 pthread_create 来创建线程，所以本质上 java 程序创建的线程，就是和操作系统线程是一样的，是 1 对 1 的线程模型。
    - 使用多线程要注意哪些问题？
      - 要保证多线程的程序是安全，不要出现数据竞争造成的数据混乱的问题。
      - Java的线程安全在三个方面体现：
        - 原子性：提供互斥访问，同一时刻只能有一个线程对数据进行操作，在Java中使用了atomic包（这个包提供了一些支持原子操作的类，这些类可以在多线程环境下保证操作的原子性）和synchronized关键字来确保原子性；
        - 可见性：一个线程对主内存的修改可以及时地被其他线程看到，在Java中使用了synchronized和volatile这两个关键字确保可见性；
        - 有序性：一个线程观察其他线程中的指令执行顺序，由于指令重排序，该观察结果一般杂乱无序，在Java中使用了happens-before原则来确保有序性。
        - JMM 定义了几个常见的 happens-before 关系：
          + 程序次序规则

            在一个线程内，按照代码顺序，前面的操作 happens-before 后面的操作。

           （即单线程语义：写在前的代码一定先执行）
          + 监视器锁规则

            对一个锁的解锁（unlock）happens-before 后续对这个锁的加锁（lock）。

            保证临界区的内存可见性）
          + volatile 变量规则
            
            对一个 volatile 变量的写 happens-before 后续对这个变量的读。

            （保证变量的可见性，不保证复合操作的原子性）
          + 传递性
            
            如果 A happens-before B，B happens-before C，那么 A happens-before C。
          + 线程启动规则
            
            在主线程中调用 Thread.start() 之前的操作 happens-before 新线程中的任何操作。
          + 线程终止规则
            
            线程中的所有操作 happens-before 其他线程检测到它结束（如通过 Thread.join() 返回）。
          + 线程中断规则
            
            对线程 interrupt() 的调用 happens-before 被中断线程的代码检测到中断事件。
          + 对象终结规则
            
            对象的构造函数执行结束 happens-before 该对象的 finalize() 方法开始。
          - JMM
          #image("Screenshot_20250901_200847.png")
    - 保证数据的一致性有哪些方案呢？
      - 事务管理：使用数据库事务来确保一组数据库操作要么全部成功提交，要么全部失败回滚。通过ACID（原子性、一致性、隔离性、持久性）属性，数据库事务可以保证数据的一致性。
      - 锁机制：使用锁来实现对共享资源的互斥访问。在 Java 中，可以使用 synchronized 关键字、ReentrantLock 或其他锁机制来控制并发访问，从而避免并发操作导致数据不一致。
      - 版本控制：通过乐观锁的方式，在更新数据时记录数据的版本信息，从而避免同时对同一数据进行修改，进而保证数据的一致性。
    - 线程的创建方式有哪些?
      + 继承thread类
        - 这是最直接的一种方式，用户自定义类继承java.lang.Thread类，重写其run()方法，run()方法中定义了线程执行的具体任务。创建该类的实例后，通过调用start()方法启动线程。
        #image("Screenshot_20250902_103500.png")
        - 优点：编写简单，如果需要访问当前线程，无需使用Thread.currentThread ()方法，直接使用this，即可获得当前线程
        - 缺点:因为线程类已经继承了Thread类，所以不能再继承其他的父类 
      + 实现runnable接口
        - 如果一个类已经继承了其他类，就不能再继承Thread类，此时可以实现java.lang.Runnable接口。实现Runnable接口需要重写run()方法，然后将此Runnable对象作为参数传递给Thread类的构造器，创建Thread对象后调用其start()方法启动线程。
        #image("Screenshot_20250902_103835.png")
        - 优点：线程类只是实现了Runable接口，还可以继承其他的类。在这种方式下，可以多个线程共享同一个目标对象，所以非常适合多个相同线程来处理同一份资源的情况，从而可以将CPU代码和数据分开，形成清晰的模型，较好地体现了面向对象的思想。
        - 缺点：编程稍微复杂，如果需要访问当前线程，必须使用Thread.currentThread()方法。
        #image("Screenshot_20250902_104350.png")
        - 同一个runnable传入多个thread，可以达到可以多个线程共享同一个目标对象。但是如果runnable中的run方法实现没有加同步synchronized，可能会出现线程安全问题，比如票数重复卖、出现负数
      + 实现Callable接口与FutureTask
        - java.util.concurrent.Callable接口类似于Runnable，但Callable的call()方法可以有返回值并且可以抛出异常。要执行Callable任务，需将它包装进一个FutureTask，因为Thread类的构造器只接受Runnable参数，而FutureTask实现了Runnable接口。
        - 缺点：编程稍微复杂，如果需要访问当前线程，必须调用Thread.currentThread()方法。
        - 优点：线程只是实现Runnable或实现Callable接口，还可以继承其他类。这种方式下，多个线程可以共享一个target对象，非常适合多线程处理同一份资源的情形。
        - 代码实现:new一个callable接口，实现其中的call方法，new一个futuretask接口，因为其实现了runnable接口，用把实现了callable接口的对象包装给futuretask，目的是为了能被thread接受，因为thread只接受runnable参数

      + 使用线程池
        - 从Java 5开始引入的java.util.concurrent.ExecutorService和相关类提供了线程池的支持，这是一种更高效的线程管理方式，避免了频繁创建和销毁线程的开销。可以通过Executors类的静态方法创建不同类型的线程池。
        #image("Screenshot_20250902_105154.png")
        - 缺点：线程池增加了程序的复杂度，特别是当涉及线程池参数调整和故障排查时。错误的配置可能导致死锁、资源耗尽等问题，这些问题的诊断和修复可能较为复杂。
        - 优点：线程池可以重用预先创建的线程，避免了线程创建和销毁的开销，显著提高了程序的性能。对于需要快速响应的并发请求，线程池可以迅速提供线程来处理任务，减少等待时间。并且，线程池能够有效控制运行的线程数量，防止因创建过多线程导致的系统资源耗尽（如内存溢出）。通过合理配置线程池大小，可以最大化CPU利用率和系统吞吐量。
        #image("Screenshot_20250902_105522.png")  
    - 怎么启动线程 ？
      #image("Screenshot_20250902_191903.png")
    - 如何停止一个线程的运行?
      - 异常法停止：线程调用interrupt()方法后，在线程的run方法中判断当前对象的interrupted()状态，如果是中断状态则抛出异常，达到中断线程的效果。
      - 在沉睡中停止：先将线程sleep，然后调用interrupt标记中断状态，interrupt会将阻塞状态的线程中断。会抛出中断异常，达到停止线程的效果
      - stop()暴力停止：线程调用stop()方法会被暴力停止，方法已弃用，该方法会有不好的后果：强制让线程停止有可能使一些请理性的工作得不到完成。
      - 使用return停止线程：调用interrupt标记为中断状态后，在run方法中判断当前线程状态，如果为中断状态则return，能达到停止线程的效果。
    - 每个线程都一个与之关联的布尔属性来表示其中断状态，中断状态的初始值为false，当一个线程被其它线程调用Thread.interrupt()方法中断时，会根据实际情况做出响应。
      - 如果该线程正在执行低级别的可中断方法（如Thread.sleep()、Thread.join()或Object.wait()），则会解除阻塞并抛出InterruptedException异常。
      - 否则Thread.interrupt()仅设置线程的中断状态，在该被中断的线程中稍后可通过轮询中断状态来决定是否要停止当前正在执行的任务。
        - 意思是
        #image("Screenshot_20250902_192417.png")
    - java的状态有哪些
      - new 尚未启动的线程状态，即还未调用start方法的线程
      - runnable 就绪状态（调用start，等待调度）+正在运行
      - blocked 等待监视器锁时，陷入阻塞状态
      - Waiting 等待状态的线程正在等待另一线程执行特定的操作
      - TIMED_WAITING 具有指定等待时间的等待状态
      - TERMINATED 线程完成执行，终止状态
    -  sleep 和 wait的区别是什么？
      - 所属分类的不同：sleep 是 Thread 类的静态方法，可以在任何地方直接通过 Thread.sleep() 调用，无需依赖对象实例。wait 是 Object 类的实例方法，这意味着必须通过对象实例来调用。
      - 锁释放的情况：Thread.sleep() 在调用时，线程会暂停执行指定的时间，但不会释放持有的对象锁。也就是说，在 sleep 期间，其他线程无法获得该线程持有的锁。Object.wait()：调用该方法时，线程会释放持有的对象锁，进入等待状态，直到其他线程调用相同对象的 notify() 或 notifyAll() 方法唤醒它
      - 使用条件：sleep 可在任意位置调用，无需事先获取锁。 wait 必须在同步块或同步方法内调用（即线程需持有该对象的锁），否则抛出 IllegalMonitorStateException。
      - 唤醒机制：sleep 休眠时间结束后，线程 自动恢复 到就绪状态，等待CPU调度。wait 需要其他线程调用相同对象的 notify() 或 notifyAll() 方法才能被唤醒。notify() 会随机唤醒一个在该对象上等待的线程，而 notifyAll() 会唤醒所有在该对象上等待的线程。
    - sleep会释放cpu吗？
      - 是的，调用 Thread.sleep() 时，线程会释放 CPU，但不会释放持有的锁。
      - 当线程调用 sleep() 后，会主动让出 CPU 时间片，进入 TIMED_WAITING 状态。此时操作系统会触发调度，将 CPU 分配给其他处于就绪状态的线程。这样其他线程（无论是需要同一锁的线程还是不相关线程）便有机会执行。
      - sleep() 不会释放线程已持有的任何锁（如 synchronized 同步代码块或方法中获取的锁）。因此，如果有其他线程试图获取同一把锁，它们仍会被阻塞，直到原线程退出同步代码块。
    -  blocked和waiting有啥区别
      - 触发条件:线程进入BLOCKED状态通常是因为试图获取一个对象的锁（monitor lock），但该锁已经被另一个线程持有。这通常发生在尝试进入synchronized块或方法时，如果锁已被占用，则线程将被阻塞直到锁可用。线程进入WAITING状态是因为它正在等待另一个线程执行某些操作，例如调用Object.wait()方法、Thread.join()方法或LockSupport.park()方法。在这种状态下，线程将不会消耗CPU资源，并且不会参与锁的竞争。
      - 唤醒机制:当一个线程被阻塞等待锁时，一旦锁被释放，线程将有机会重新尝试获取锁。如果锁此时未被其他线程获取，那么线程可以从BLOCKED状态变为RUNNABLE状态。线程在WAITING状态中需要被显式唤醒。例如，如果线程调用了Object.wait()，那么它必须等待另一个线程调用同一对象上的Object.notify()或Object.notifyAll()方法才能被唤醒。
      - 所以，BLOCKED和WAITING两个状态最大的区别有两个：
        - BLOCKED是锁竞争失败后被被动触发的状态，WAITING是人为的主动触发的状态
        - BLCKED的唤醒时自动触发的，而WAITING状态是必须要通过特定的方法来主动唤醒
    - wait 状态下的线程如何进行恢复到 running 状态?
      - 线程从 等待（WAIT） 状态恢复到 运行（RUNNING） 状态的核心机制是 通过外部事件触发或资源可用性变化，比如等待的线程被其他线程对象唤醒，notify()和notifyAll()。
    - notify 和 notifyAll 的区别?
      - notify：唤醒一个线程，其他线程依然处于wait的等待唤醒状态，如果被唤醒的线程结束时没调用notify，其他线程就永远没人去唤醒，只能等待超时，或者被中断
      - notifyAll：所有线程退出wait的状态，开始竞争锁，但只有一个线程能抢到，这个线程执行完后，其他线程又会有一个幸运儿脱颖而出得到锁
        - 自我理解:除了竞争到锁之外的锁变成blocked状态
    - notify 选择哪个线程?
      - notify在源码的注释中说到notify选择唤醒的线程是任意的，但是依赖于具体实现的jvm。
      - JVM有很多实现，比较流行的就是hotspot，hotspot对notofy()的实现并不是我们以为的随机唤醒,，而是“先进先出”的顺序唤醒。
    -  不同的线程之间如何通信？
      - 共享变量是最基本的线程间通信方式。多个线程可以访问和修改同一个共享变量，从而实现信息的传递。为了保证线程安全，通常需要使用 synchronized 关键字或 volatile 关键字。
      - volatile 关键字确保了 flag 变量在多个线程之间的可见性，即一个线程修改了 flag 的值，其他线程能立即看到。
      - 生产者线程在睡眠 2 秒后将 flag 设置为 true，消费者线程在 flag 为 false 时一直等待，直到 flag 变为 true 才继续执行。
      ```java
      class WaitNotifyExample {
    private static final Object lock = new Object();

    public static void main(String[] args) {
        // 生产者线程
        Thread producer = new Thread(() -> {
            synchronized (lock) {
                try {
                    System.out.println("Producer: Producing...");
                    Thread.sleep(2000);
                    System.out.println("Producer: Production finished. Notifying consumer.");
                    // 唤醒等待的线程
                    lock.notify();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        // 消费者线程
        Thread consumer = new Thread(() -> {
            synchronized (lock) {
                try {
                    System.out.println("Consumer: Waiting for production to finish.");
                    // 进入等待状态
                    lock.wait();
                    System.out.println("Consumer: Production finished. Consuming...");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        consumer.start();
        producer.start();
    }
}
 
      ```
      - lock 是一个用于同步的对象，生产者和消费者线程都需要获取该对象的锁才能执行相应的操作。
      - 消费者线程调用 lock.wait() 方法进入等待状态，释放锁；生产者线程执行完生产任务后调用 lock.notify() 方法唤醒等待的消费者线程。
      - java.util.concurrent.locks 包中的 Lock 和 Condition 接口提供了比 synchronized 更灵活的线程间通信方式。Condition 接口的 await() 方法类似于 wait() 方法，signal() 方法类似于 notify() 方法，signalAll() 方法类似于 notifyAll() 方法。
      ```java 
      import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class LockConditionExample {
    private static final Lock lock = new ReentrantLock();
    private static final Condition condition = lock.newCondition();

    public static void main(String[] args) {
        // 生产者线程
        Thread producer = new Thread(() -> {
            lock.lock();
            try {
                System.out.println("Producer: Producing...");
                Thread.sleep(2000);
                System.out.println("Producer: Production finished. Notifying consumer.");
                // 唤醒等待的线程
                condition.signal();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        });

        // 消费者线程
        Thread consumer = new Thread(() -> {
            lock.lock();
            try {
                System.out.println("Consumer: Waiting for production to finish.");
                // 进入等待状态
                condition.await();
                System.out.println("Consumer: Production finished. Consuming...");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        });

        consumer.start();
        producer.start();
    }
}

      ```
      - ReentrantLock 是 Lock 接口的一个实现类，condition 是通过 lock.newCondition() 方法创建的。
      - 消费者线程调用 condition.await() 方法进入等待状态，生产者线程执行完生产任务后调用 condition.signal() 方法唤醒等待的消费者线程。
      - java.util.concurrent 包中的 BlockingQueue 接口提供了线程安全的队列操作，当队列满时，插入元素的线程会被阻塞；当队列为空时，获取元素的线程会被阻塞。
      ```java 
      import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

class BlockingQueueExample {
    private static final BlockingQueue<Integer> queue = new LinkedBlockingQueue<>(1);

    public static void main(String[] args) {
        // 生产者线程
        Thread producer = new Thread(() -> {
            try {
                System.out.println("Producer: Producing...");
                queue.put(1);
                System.out.println("Producer: Production finished.");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        // 消费者线程
        Thread consumer = new Thread(() -> {
            try {
                System.out.println("Consumer: Waiting for production to finish.");
                int item = queue.take();
                System.out.println("Consumer: Consumed item: " + item);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        consumer.start();
        producer.start();
    }
}

      ```
      - LinkedBlockingQueue 是 BlockingQueue 接口的一个实现类，容量为 1。
      - 生产者线程调用 queue.put(1) 方法将元素插入队列，如果队列已满，线程会被阻塞；消费者线程调用 queue.take() 方法从队列中取出元素，如果队列为空，线程会被阻塞。
    - 线程的通信方式有哪些？
      - Object 类的 wait()、notify() 和 notifyAll() 方法。这是 Java 中最基础的线程间通信方式，基于对象的监视器（锁）机制。
        - wait()：使当前线程进入等待状态，直到其他线程调用该对象的 notify() 或 notifyAll() 方法。
        - notify()：唤醒在此对象监视器上等待的单个线程。
        - notifyAll()：唤醒在此对象监视器上等待的所有线程。
      - Lock 和 Condition 接口。Lock 接口提供了比 synchronized 更灵活的锁机制，Condition 接口则配合 Lock 实现线程间的等待 / 通知机制。
        - 灵活在哪
          - synchronized 是 隐式锁，只能用 synchronized(obj) 的方式，出了作用域自动释放。而 Lock 是 显式锁，由开发者控制：
          #image("Screenshot_20250903_201557.png")
          - synchronized 只能搭配 Object.wait() / notify() / notifyAll() 使用，而且一个锁只有 一个隐含的等待队列。而 Condition 可以：
          #image("Screenshot_20250903_201633.png")
        - await()：使当前线程进入等待状态，直到被其他线程唤醒。
        - signal()：唤醒一个等待在该 Condition 上的线程。
        - signalAll()：唤醒所有等待在该 Condition 上的线程。
      - volatile 关键字。volatile 关键字用于保证变量的可见性，即当一个变量被声明为 volatile 时，它会保证对该变量的写操作会立即刷新到主内存中，而读操作会从主内存中读取最新的值。
      - CountDownLatch。CountDownLatch 是一个同步辅助类，它允许一个或多个线程等待其他线程完成操作。
        - CountDownLatch(int count)：构造函数，指定需要等待的线程数量。
        - countDown()：减少计数器的值。
        - await()：使当前线程等待，直到计数器的值为 0。
      - CyclicBarrier。CyclicBarrier 是一个同步辅助类，它允许一组线程相互等待，直到所有线程都到达某个公共屏障点。
        - CyclicBarrier(int parties, Runnable barrierAction)：构造函数，指定参与的线程数量和所有线程到达屏障点后要执行的操作。
        - await()：使当前线程等待，直到所有线程都到达屏障点。
        - 屏障点就是await函数执行
      - Semaphore。Semaphore 是一个计数信号量，它可以控制同时访问特定资源的线程数量。
        - Semaphore(int permits)：构造函数，指定信号量的初始许可数量。
        - acquire()：获取一个许可，如果没有可用许可则阻塞。
        - release()：释放一个许可。
    - 如何停止一个线程？
      - 在 Java 中，停止线程的正确方式是 通过协作式的逻辑控制线程终止，而非强制暴力终止（如已废弃的 Thread.stop()）。以下是实现安全停止线程的多种方法：
      - 第一种方式：通过共享标志位主动终止。定义一个 可见的 状态变量，由主线程控制其值，工作线程循环检测该变量以决定是否退出。
      - 第二种方式使用线程中断机制。通过 Thread.interrupt() 触发线程中断状态，结合中断检测逻辑实现安全停止。
        - interrupt() 不会立刻终止线程，只是设置中断标志位。
        - 线程需手动检查中断状态（isInterrupted()）或触发可中断操作（如sleep()，wait()，join())响应中断。
        - 阻塞操作中收到中断请求时，会抛出 InterruptedException 并清除中断状态。
      - 第三种方式通过 Future 取消任务。使用线程池提交任务，并通过 Future.cancel() 停止线程，依赖中断机制。
        - 处理不可中断的阻塞操作，某些 I/O 或同步操作（如 Socket.accept()、Lock.lock()）无法通过中断直接响应。此时需结合资源关闭操作。比如，关闭 Socket 释放阻塞。
    #image("Screenshot_20250903_202451.png")
  - 并发安全
    - juc包下你常用的类？
      线程池相关：
        - ThreadPoolExecutor：最核心的线程池类，用于创建和管理线程池。通过它可以灵活地配置线程池的参数，如核心线程数、最大线程数、任务队列等，以满足不同的并发处理需求。
        - Executors：线程池工厂类，提供了一系列静态方法来创建不同类型的线程池，如
          - newFixedThreadPool（创建固定线程数的线程池）、newCachedThreadPool（创建可缓存线程池）、newSingleThreadExecutor（创建单线程线程池）等，方便开发者快速创建线程池。
      - 并发集合类：
        - ConcurrentHashMap：线程安全的哈希映射表，用于在多线程环境下高效地存储和访问键值对。它采用了分段锁等技术，允许多个线程同时访问不同的段，提高了并发性能，在高并发场景下比传统的Hashtable性能更好。
        - CopyOnWriteArrayList：线程安全的列表，在对列表进行修改操作时，会创建一个新的底层数组，将修改操作应用到新数组上，而读操作仍然可以在旧数组上进行，从而实现了读写分离，提高了并发读的性能，适用于读多写少的场景。
          - #image("Screenshot_20250904_203826.png")
          - 保证最终一致性
      - 同步工具类：
        - CountDownLatch：允许一个或多个线程等待其他一组线程完成操作后再继续执行。它通过一个计数器来实现，计数器初始化为线程的数量，每个线程完成任务后调用countDown方法将计数器减一，当计数器为零时，等待的线程可以继续执行。常用于多个线程完成各自任务后，再进行汇总或下一步操作的场景。
        - CyclicBarrier：让一组线程互相等待，直到所有线程都到达某个屏障点后，再一起继续执行。与CountDownLatch不同的是，CyclicBarrier可以重复使用，当所有线程都通过屏障后，计数器会重置，可以再次用于下一轮的等待。适用于多个线程需要协同工作，在某个阶段完成后再一起进入下一个阶段的场景。
        - Semaphore：信号量，用于控制同时访问某个资源的线程数量。它维护了一个许可计数器，线程在访问资源前需要获取许可，如果有可用许可，则获取成功并将许可计数器减一，否则线程需要等待，直到有其他线程释放许可。常用于控制对有限资源的访问，如数据库连接池、线程池中的线程数量等。
      - 原子类：
        - AtomicInteger：原子整数类，提供了对整数类型的原子操作，如自增、自减、比较并交换等。通过硬件级别的原子指令来保证操作的原子性和线程安全性，避免了使用锁带来的性能开销，在多线程环境下对整数进行计数、状态标记等操作非常方便。
        -     AtomicReference：原子引用类，用于对对象引用进行原子操作。可以保证在多线程环境下，对对象的更新操作是原子性的，即要么全部成功，要么全部失败，不会出现数据不一致的情况。常用于实现无锁数据结构或需要对对象进行原子更新的场景。
        #image("Screenshot_20250904_204656.png")
    - 怎么保证多线程安全？
      - synchronized关键字:可以使用synchronized关键字来同步代码块或方法，确保同一时刻只有一个线程可以访问这些代码。对象锁是通过synchronized关键字锁定对象的监视器（monitor）来实现的。
      - volatile关键字:volatile关键字用于变量，确保所有线程看到的是该变量的最新值，而不是可能存储在本地寄存器中的副本。
      - Lock接口和ReentrantLock类:java.util.concurrent.locks.Lock接口提供了比synchronized更强大的锁定机制，ReentrantLock是一个实现该接口的例子，提供了更灵活的锁管理和更高的性能。
      - 原子类：Java并发库（java.util.concurrent.atomic）提供了原子类，如AtomicInteger、AtomicLong等，这些类提供了原子操作，可以用于更新基本类型的变量而无需额外的同步。
      - 线程局部变量:ThreadLocal类可以为每个线程提供独立的变量副本，这样每个线程都拥有自己的变量，消除了竞争条件。
      - 并发集合:使用java.util.concurrent包中的线程安全集合，如ConcurrentHashMap、ConcurrentLinkedQueue等，这些集合内部已经实现了线程安全的逻辑。
      - JUC工具类: 使用java.util.concurrent包中的一些工具类可以用于控制线程间的同步和协作。例如：Semaphore和CyclicBarrier等。
    - Java中有哪些常用的锁，在什么场景下使用？
      - 内置锁（synchronized）：Java中的synchronized关键字是内置锁机制的基础，可以用于方法或代码块。当一个线程进入synchronized代码块或方法时，它会获取关联对象的锁；当线程离开该代码块或方法时，锁会被释放。如果其他线程尝试获取同一个对象的锁，它们将被阻塞，直到锁被释放。其中，syncronized加锁时有无锁、偏向锁、轻量级锁和重量级锁几个级别。偏向锁用于当一个线程进入同步块时，如果没有任何其他线程竞争，就会使用偏向锁，以减少锁的开销。轻量级锁使用线程栈上的数据结构，避免了操作系统级别的锁。重量级锁则涉及操作系统级的互斥锁。
      - ReentrantLock：java.util.concurrent.locks.ReentrantLock是一个显式的锁类，提供了比synchronized更高级的功能，如可中断的锁等待、定时锁等待、公平锁选项等。ReentrantLock使用lock()和unlock()方法来获取和释放锁。其中，公平锁按照线程请求锁的顺序来分配锁，保证了锁分配的公平性，但可能增加锁的等待时间。非公平锁不保证锁分配的顺序，可以减少锁的竞争，提高性能，但可能造成某些线程的饥饿。
      - 读写锁（ReadWriteLock）：java.util.concurrent.locks.ReadWriteLock接口定义了一种锁，允许多个读取者同时访问共享资源，但只允许一个写入者。读写锁通常用于读取远多于写入的情况，以提高并发性。
      - 乐观锁和悲观锁：悲观锁（Pessimistic Locking）通常指在访问数据前就锁定资源，假设最坏的情况，即数据很可能被其他线程修改。synchronized和ReentrantLock都是悲观锁的例子。乐观锁（Optimistic Locking）通常不锁定资源，而是在更新数据时检查数据是否已被其他线程修改。乐观锁常使用版本号或时间戳来实现。
      - 自旋锁：自旋锁是一种锁机制，线程在等待锁时会持续循环检查锁是否可用，而不是放弃CPU并阻塞。通常可以使用CAS来实现。这在锁等待时间很短的情况下可以提高性能，但过度自旋会浪费CPU资源。
    - 怎么在实践中用锁的？
      - synchronized
        #image("Screenshot_20250906_111536.png")
      - 使用Lock接口
        #image("Screenshot_20250906_112005.png")
        #image("Screenshot_20250906_112325.png")
      - 使用ReadWriteLock
        #image("Screenshot_20250906_112559.png")
    - Java 并发工具你知道哪些？
      - CountDownLatch：CountDownLatch 是一个同步辅助类，它允许一个或多个线程等待其他线程完成操作。它使用一个计数器进行初始化，调用 countDown() 方法会使计数器减一，当计数器的值减为 0 时，等待的线程会被唤醒。可以把它想象成一个倒计时器，当倒计时结束（计数器为 0）时，等待的事件就会发生。示例代码：
      #image("Screenshot_20250906_123407.png")
      - CyclicBarrier：CyclicBarrier 允许一组线程互相等待，直到到达一个公共的屏障点。当所有线程都到达这个屏障点后，它们可以继续执行后续操作，并且这个屏障可以被重置循环使用。与 CountDownLatch 不同，CyclicBarrier 侧重于线程间的相互等待，而不是等待某些操作完成。示例代码：
      #image("Screenshot_20250906_123708.png")
      #image("Screenshot_20250906_123656.png")
      - Semaphore：Semaphore 是一个计数信号量，用于控制同时访问某个共享资源的线程数量。通过 acquire() 方法获取许可，使用 release() 方法释放许可。如果没有许可可用，线程将被阻塞，直到有许可被释放。可以用来限制对某些资源（如数据库连接池、文件操作等）的并发访问量。代码如下：
      #image("Screenshot_20250906_123737.png")
      - Future 和 Callable：Callable 是一个类似于 Runnable 的接口，但它可以返回结果，并且可以抛出异常。Future 用于表示一个异步计算的结果，可以通过它来获取 Callable 任务的执行结果或取消任务。代码如下：
      #image("Screenshot_20250906_124206.png")
      - ConcurrentHashMap：ConcurrentHashMap 是一个线程安全的哈希表，它允许多个线程同时进行读操作，在一定程度上支持并发的修改操作，避免了 HashMap 在多线程环境下需要使用 synchronized 或 Collections.synchronizedMap() 进行同步的性能问题。代码如下：
      #image("Screenshot_20250906_124336.png")
    - CountDownLatch 是做什么的讲一讲？
      - CountDownLatch 是 Java 并发包（java.util.concurrent）中的一个同步工具类，用于让一个或多个线程等待其他线程完成操作后再继续执行。
      - 其核心是通过一个计数器（Counter）实现线程间的协调，常用于多线程任务的分阶段控制或主线程等待多个子线程就绪的场景，核心原理：
        - 初始化计数器：创建 CountDownLatch 时指定一个初始计数值（如 N）。
        - 等待线程阻塞：调用 await() 的线程会被阻塞，直到计数器变为 0。
        - 任务完成通知：其他线程完成任务后调用 countDown()，使计数器减 1。
        - 唤醒等待线程：当计数器减到 0 时，所有等待的线程会被唤醒。
    -  synchronized和reentrantlock及其应用场景？
      - synchronized工作原理
        - synchronized是Java提供的原子性内置锁，这种内置的并且使用者看不到的锁也被称为监视器锁
        - 使用synchronized之后，会在编译之后在同步的代码块前后加上monitorenter和monitorexit字节码指令，他依赖操作系统底层互斥锁实现。他的作用主要就是实现原子性操作和解决共享变量的内存可见性问题。
        - 执行monitorenter指令时会尝试获取对象锁，如果对象没有被锁定或者已经获得了锁，锁的计数器+1。此时其他竞争锁的线程则会进入等待队列中。执行monitorexit指令时则会把计数器-1，当计数器值为0时，则锁释放，处于等待队列中的线程再继续竞争锁
        - synchronized是排它锁，当一个线程获得锁之后，其他线程必须等待该线程释放锁后才能获得锁，而且由于Java中的线程和操作系统原生线程是一一对应的，线程被阻塞或者唤醒时时会从用户态切换到内核态，这种转换非常消耗性能。
        - 从内存语义来说，加锁的过程会清除工作内存中的共享变量，再从主内存读取，而释放锁的过程则是将工作内存中的共享变量写回主内存。
        - 如果再深入到源码来说，synchronized实际上有两个队列waitSet和entryList
          - 当多个线程进入同步代码块，首先进入entrylist
          - 有一个线程获取到monitor锁后，就赋值给当前线程，并且计数器+1
          - 如果线程调用wait方法，将释放锁，当前线程置为null，计数器-1,同时进入waitset等待被唤醒，调用notify或者notifyall之后又会进去entrylist竞争锁
          - 如果线程执行完毕，同样释放锁，计数器-1,当前线程置为null
      - reentrantlock工作原理
        - ReentrantLock 的底层实现主要依赖于 AbstractQueuedSynchronizer（AQS）这个抽象类。AQS 是一个提供了基本同步机制的框架，其中包括了队列、状态值等。
        - ReentrantLock 在 AQS 的基础上通过内部类 Sync 来实现具体的锁操作。不同的 Sync 子类实现了公平锁和非公平锁的不同逻辑：
          - 可中断性： ReentrantLock 实现了可中断性，这意味着线程在等待锁的过程中，可以被其他线程中断而提前结束等待。在底层，ReentrantLock 使用了与 LockSupport.park() 和 LockSupport.unpark() 相关的机制来实现可中断性。
          - 设置超时时间： ReentrantLock 支持在尝试获取锁时设置超时时间，即等待一定时间后如果还未获得锁，则放弃锁的获取。这是通过内部的 tryAcquireNanos 方法来实现的。
          - 公平锁和非公平锁： 在直接创建 ReentrantLock 对象时，默认情况下是非公平锁。公平锁是按照线程等待的顺序来获取锁，而非公平锁则允许多个线程在同一时刻竞争锁，不考虑它们申请锁的顺序。公平锁可以通过在创建 ReentrantLock 时传入 true 来设置，例如：
          - 多个条件变量： ReentrantLock 支持多个条件变量，每个条件变量可以与一个 ReentrantLock 关联。这使得线程可以更灵活地进行等待和唤醒操作，而不仅仅是基于对象监视器的 wait() 和 notify()。多个条件变量的实现依赖于 Condition 接口，例如：
          - 可重入性： ReentrantLock 支持可重入性，即同一个线程可以多次获得同一把锁，而不会造成死锁。这是通过内部的 holdCount 计数来实现的。当一个线程多次获取锁时，holdCount 递增，释放锁时递减，只有当 holdCount 为零时，其他线程才有机会获取锁。
        - 应用场景的区别
          - synchronized:
            - 简单同步需求： 当你需要对代码块或方法进行简单的同步控制时，synchronized是一个很好的选择。它使用起来简单，不需要额外的资源管理，因为锁会在方法退出或代码块执行完毕后自动释放。
            - 代码块同步： 如果你想对特定代码段进行同步，而不是整个方法，可以使用synchronized代码块。这可以让你更精细地控制同步的范围，从而减少锁的持有时间，提高并发性能。
            - 内置锁的使用： synchronized关键字使用对象的内置锁（也称为监视器锁），这在需要使用对象作为锁对象的情况下很有用，尤其是在对象状态与锁保护的代码紧密相关时。
          - reentrantlock
            - 高级锁功能需求：ReentrantLock提供了synchronized所不具备的高级功能，如公平锁、响应中断、定时锁尝试、以及多个条件变量。当你需要这些功能时，ReentrantLock是更好的选择。
            - 性能优化： 在高度竞争的环境中，ReentrantLock可以提供比synchronized更好的性能，因为它提供了更细粒度的控制，如尝试锁定和定时锁定，可以减少线程阻塞的可能性。
            - 复杂同步结构： 当你需要更复杂的同步结构，如需要多个条件变量来协调线程之间的通信时，ReentrantLock及其配套的Condition对象可以提供更灵活的解决方案。
        - 综上，synchronized适用于简单同步需求和不需要额外锁功能的场景，而ReentrantLock适用于需要更高级锁功能、性能优化或复杂同步逻辑的情况。选择哪种同步机制取决于具体的应用需求和性能考虑。
      - 除了用synchronized，还有什么方法可以实现线程同步？
        - 使用ReentrantLock类：ReentrantLock是一个可重入的互斥锁，相比synchronized提供了更灵活的锁定和解锁操作。它还支持公平锁和非公平锁，以及可以响应中断的锁获取操作。
        - 使用volatile关键字：虽然volatile不是一种锁机制，但它可以确保变量的可见性。当一个变量被声明为volatile后，线程将直接从主内存中读取该变量的值，这样就能保证线程间变量的可见性。但它不具备原子性。
        - 使用Atomic类：Java提供了一系列的原子类，例如AtomicInteger、AtomicLong、AtomicReference等，用于实现对单个变量的原子操作，这些类在实现细节上利用了CAS（Compare-And-Swap）算法，可以用来实现无锁的线程安全。 
      -  synchronized锁静态方法和普通方法区别？
        - 锁的对象不同：
          - 普通方法：锁的是当前对象实例（this）。同一对象实例的 synchronized 普通方法，同一时间只能被一个线程访问；不同对象实例间互不影响，可被不同线程同时访问各自的同步普通方法。
          - 静态方法：锁的是类的 Class 对象（ClassName.class）。无论多少个对象实例，同一类的 synchronized 静态方法，同一时间只能被一个线程访问；
        - 作用范围不同：
          - 普通方法：仅对同一对象实例的同步方法调用互斥，不同对象实例的同步普通方法可并行执行。
          - 静态方法：对整个类的所有实例的该静态方法调用都互斥，一个线程进入静态同步方法，其他线程无法进入同一类任何实例的该方法。
        - 多实例场景影响不同：
          - 普通方法：多线程访问不同对象实例的同步普通方法时，可同时执行。
          - 静态方法：不管有多少对象实例，同一时间仅一个线程能执行该静态同步方法。
      - synchronized和reentrantlock区别？
        - synchronized 和 ReentrantLock 都是 Java 中提供的可重入锁：
          - 用法不同：synchronized 可用来修饰普通方法、静态方法和代码块，而 ReentrantLock 只能用在代码块上。
          - 获取锁和释放锁的方式不同：synchronized 会自动加锁和释放锁，当进入 synchronized 修饰的代码块之后会自动加锁，当离开 synchronized 的代码段之后会自动释放锁。而 ReentrantLock 需要手动加锁和释放锁
          - 锁的类型不同：synchronized 属于非公平锁，而 ReentrantLock 既可以是公平锁也可以是非公平锁。
          - 响应中断不同：ReentrantLock 可以响应中断，解决死锁的问题，而 synchronized 不能响应中断。
          - 底层实现不同：synchronized 是 JVM 层面通过监视器实现的，而 ReentrantLock 是基于 AQS 实现的。
      - 如何理解可重入锁
        - 可重入锁是指同一个线程在获取了锁之后，可以再次重复获取该锁而不会造成死锁或其他问题。当一个线程持有锁时，如果再次尝试获取该锁，就会成功获取而不会被阻塞。
        - ReentrantLock实现可重入锁的机制是基于线程持有锁的计数器。
          - 当一个线程第一次获取锁时，计数器会加1，表示该线程持有了锁。在此之后，如果同一个线程再次获取锁，计数器会再次加1。每次线程成功获取锁时，都会将计数器加1。
          - 当线程释放锁时，计数器会相应地减1。只有当计数器减到0时，锁才会完全释放，其他线程才有机会获取锁。
        - 这种计数器的设计使得同一个线程可以多次获取同一个锁，而不会造成死锁或其他问题。每次获取锁时，计数器加1；每次释放锁时，计数器减1。只有当计数器减到0时，锁才会完全释放。
        - ReentrantLock通过这种计数器的方式，实现了可重入锁的机制。它允许同一个线程多次获取同一个锁，并且能够正确地处理锁的获取和释放，避免了死锁和其他并发问题。
        
      - synchronized支持重入吗？如何实现的？
        - synchronized是基于原子性的内部锁机制，是可重入的，因此在一个线程调用synchronized方法的同时在其方法体内部调用该对象另一个synchronized方法，也就是说一个线程得到一个对象锁后再次请求该对象锁，是允许的，这就是synchronized的可重入性。
        - synchronized底层是利用计算机系统mutex Lock实现的。每一个可重入锁都会关联一个线程ID和一个锁状态status。
        - 当一个线程请求方法时，会去检查锁状态。
          - 如果锁状态是0，代表该锁没有被占用，使用CAS操作获取锁，将线程ID替换成自己的线程ID。
          - 如果锁状态不是0，代表有线程在访问该方法。此时，如果线程ID是自己的线程ID，如果是可重入锁，会将status自增1，然后获取到该锁，进而执行相应的方法；如果是非重入锁，就会进入阻塞队列等待。
        - 在释放锁时，
          - 如果是可重入锁的，每一次退出方法，就会将status减1，直至status的值为0，最后释放该锁。
          - 如果非可重入锁的，线程退出方法，直接就会释放该锁。
      - syncronized锁升级的过程讲一下 
        - 具体的锁升级的过程是：无锁->偏向锁->轻量级锁->重量级锁。
        - 无锁：这是没有开启偏向锁的时候的状态，在JDK1.6之后偏向锁的默认开启的，但是有一个偏向延迟，需要在JVM启动之后的多少秒之后才能开启，这个可以通过JVM参数进行设置，同时是否开启偏向锁也可以通过JVM参数设置。
        - 偏向锁：这个是在偏向锁开启之后的锁的状态，如果还没有一个线程拿到这个锁的话，这个状态叫做匿名偏向，当一个线程拿到偏向锁的时候，下次想要竞争锁只需要拿线程ID跟MarkWord当中存储的线程ID进行比较，如果线程ID相同则直接获取锁（相当于锁偏向于这个线程），不需要进行CAS操作和将线程挂起的操作。
          如果不相同
          - 第一次冲突：撤销偏向
            - 撤销的过程并不是直接变成重量级锁，而是：先暂停拥有偏向锁的线程（安全点操作，比较耗时）。检查持有偏向锁的线程是否还在使用锁对象。如果没有使用，就撤销偏向，恢复为 无锁状态 或 轻量级锁。
          - 如果另一个线程想要获取这个锁，对象会 升级为轻量级锁。此时，线程需要通过 CAS（Compare-And-Swap） 操作把对象头里的 Mark Word 替换为自己线程的锁记录地址。如果 CAS 成功，线程获得锁。如果 CAS 失败（说明竞争比较激烈），则会继续升级。
          - 多线程竞争：升级为重量级锁
        - 轻量级锁：在这个状态下线程主要是通过CAS操作实现的。将对象的MarkWord存储到线程的虚拟机栈上，然后通过CAS将对象的MarkWord的内容设置为指向Displaced Mark Word的指针，如果设置成功则获取锁。在线程出临界区的时候，也需要使用CAS，如果使用CAS替换成功则同步成功，如果失败表示有其他线程在获取锁，那么就需要在释放锁之后将被挂起的线程唤醒。
        - 重量级锁：当有两个以上的线程获取锁的时候轻量级锁就会升级为重量级锁，因为CAS如果没有成功的话始终都在自旋，进行while循环操作，这是非常消耗CPU的，但是在升级为重量级锁之后，线程会被操作系统调度然后挂起，这可以节约CPU资源。
        
        #image("Screenshot_20250910_111536.png")
        #image("Screenshot_20250910_111720.png")
        - 锁升级过程
          #image("Screenshot_20250910_111818.png")
        - 线程A进入 synchronized 开始抢锁，JVM 会判断当前是否是偏向锁的状态，如果是就会根据 Mark Word 中存储的线程 ID 来判断，当前线程A是否就是持有偏向锁的线程。如果是，则忽略 check，线程A直接执行临界区内的代码。
        - 但如果 Mark Word 里的线程不是线程 A，就会通过自旋尝试获取锁，如果获取到了，就将 Mark Word 中的线程 ID 改为自己的;如果竞争失败，就会立马撤销偏向锁，膨胀为轻量级锁。
        - 后续的竞争线程都会通过自旋来尝试获取锁，如果自旋成功那么锁的状态仍然是轻量级锁。然而如果竞争失败，锁会膨胀为重量级锁，后续等待的竞争的线程都会被阻塞。
        #image("Screenshot_20250910_112015.png")
      - JVM对Synchornized的优化？
        - 锁膨胀：synchronized 从无锁升级到偏向锁，再到轻量级锁，最后到重量级锁的过程，它叫做锁膨胀也叫做锁升级。JDK 1.6 之前，synchronized 是重量级锁，也就是说 synchronized 在释放和获取锁时都会从用户态转换成内核态，而转换的效率是比较低的。但有了锁膨胀机制之后，synchronized 的状态就多了无锁、偏向锁以及轻量级锁了，这时候在进行并发操作时，大部分的场景都不需要用户态到内核态的转换了，这样就大幅的提升了 synchronized 的性能。
        - 锁消除：指的是在某些情况下，JVM 虚拟机如果检测不到某段代码被共享和竞争的可能性，就会将这段代码所属的同步锁消除掉，从而到底提高程序性能的目的。
        - 锁粗化：将多个连续的加锁、解锁操作连接在一起，扩展成一个范围更大的锁。
        - 自适应自旋锁：指通过自身循环，尝试获取锁的一种方式，优点在于它避免一些线程的挂起和恢复操作，因为挂起线程和恢复线程都需要从用户态转入内核态，这个过程是比较慢的，所以通过自旋的方式可以一定程度上避免线程挂起和恢复所造成的性能开销。
      -  介绍一下AQS

  - 线程池
    - 介绍一下线程池的原理
      - 线程池是为了减少频繁的创建线程和销毁线程带来的性能损耗，线程池的工作原理如下图：
      - 线程池分为核心线程池，线程池的最大容量，还有等待任务的队列，提交一个任务，如果核心线程没有满，就创建一个线程，如果满了，就是会加入等待队列，如果等待队列满了，就会增加线程，如果达到最大线程数量，如果都达到最大线程数量，就会按照一些丢弃的策略进行处理。
        - 核心线程就是线程池中 始终保持活动的线程，即使它们处于空闲状态（没有任务可执行），默认情况下也不会被回收。
    - 线程池的参数
      - corePoolSize：线程池核心线程数量。默认情况下，线程池中线程的数量如果 <= corePoolSize，那么即使这些线程处于空闲状态，那也不会被销毁。
      - maximumPoolSize：限制了线程池能创建的最大线程总数（包括核心线程和非核心线程），当 corePoolSize 已满 并且 尝试将新任务加入阻塞队列失败（即队列已满）并且 当前线程数 < maximumPoolSize，就会创建新线程执行此任务，但是当 corePoolSize 满 并且 队列满 并且 线程数已达 maximumPoolSize 并且 又有新任务提交时，就会触发拒绝策略。
      - keepAliveTime：当线程池中线程的数量大于corePoolSize，并且某个线程的空闲时间超过了keepAliveTime，那么这个线程就会被销毁。
      - unit：就是keepAliveTime时间的单位。
      - workQueue：工作队列。当没有空闲的线程执行新任务时，该任务就会被放入工作队列中，等待执行。
      - threadFactory：线程工厂。可以用来给线程取名字等等
        - 线程工厂作用：
        #image("Screenshot_20250904_190951.png")
      -     handler：拒绝策略。当一个新任务交给线程池，如果此时线程池中有空闲的线程，就会直接执行，如果没有空闲的线程，就会将该任务加入到阻塞队列中，如果阻塞队列满了，就会创建一个新线程，从阻塞队列头部取出一个任务来执行，并将新任务加入到阻塞队列末尾。如果当前线程池中线程的数量等于maximumPoolSize，就不会创建新线程，就会去执行拒绝策略
    - 线程池工作队列满了有哪些拒接策略？
      - CallerRunsPolicy，使用线程池的调用者所在的线程去执行被拒绝的任务，除非线程池被停止或者线程池的任务队列已有空缺。
      - AbortPolicy，直接抛出一个任务被线程池拒绝的异常。
      - DiscardPolicy,不做任何处理，静默拒绝提交的任务
      - DiscardOldestPolicy，抛弃最老的任务，然后执行该任务。
      - 自定义拒绝策略
    - 有线程池参数设置的经验吗？
      - CPU密集型：corePoolSize = CPU核数 + 1（避免过多线程竞争CPU）
      - IO密集型：corePoolSize = CPU核数 x 2（或更高，具体看IO等待时间）
      - 场景一：电商场景，特点瞬时高并发、任务处理时间短，线程池的配置可设置如下：
        #image("Screenshot_20250904_193923.png")
        - 使用SynchronousQueue确保任务直达线程，避免队列延迟。
        - 拒绝策略快速失败，前端返回“活动火爆”提示，结合降级策略（如缓存预热）。
        #image("Screenshot_20250904_194422.png")
        #image("Screenshot_20250904_194443.png")
      - 场景二：后台数据处理服务，特点稳定流量、任务处理时间长（秒级）、允许一定延迟，线程池的配置可设置如下：
        #image("Screenshot_20250904_194528.png")
        - 固定线程数避免资源波动，队列缓冲任务，拒绝策略兜底。
        - 配合监控告警（如队列使用率>80%触发扩容）。
      - 场景三：微服务HTTP请求处理，特点IO密集型、依赖下游服务响应时间，线程池的配置可设置如下：
        #image("Screenshot_20250904_194648.png")
        - 根据下游RT（响应时间）调整线程数，队列防止瞬时峰值。
        - 自定义拒绝策略将任务暂存Redis，异步重试。
        #image("Screenshot_20250904_195039.png")
        #image("Screenshot_20250904_195116.png")
        #image("Screenshot_20250904_195236.png")
      - 核心线程数设置为0可不可以？
        - 可以，当核心线程数为0的时候，会创建一个非核心线程进行执行。
        - 从下面的源码也可以看到，当核心线程数为 0 时，来了一个任务之后，会先将任务添加到任务队列，同时也会判断当前工作的线程数是否为 0，如果为 0，则会创建线程来执行线程池的任务。
        #image("Screenshot_20250904_195320-1.png")
      - 线程池种类有哪些？
        - ScheduledThreadPool：可以设置定期的执行任务，它支持定时或周期性执行任务，比如每隔 10 秒钟执行一次任务，我通过这个实现类设置定期执行任务的策略。
        - FixedThreadPool：它的核心线程数和最大线程数是一样的，所以可以把它看作是固定线程数的线程池，它的特点是线程池中的线程数除了初始阶段需要从 0 开始增加外，之后的线程数量就是固定的，就算任务数超过线程数，线程池也不会再创建更多的线程来处理任务，而是会把超出线程处理能力的任务放到任务队列中进行等待。而且就算任务队列满了，到了本该继续增加线程数的时候，由于它的最大线程数和核心线程数是一样的，所以也无法再增加新的线程了。
        - CachedThreadPool：可以称作可缓存线程池，它的特点在于线程数是几乎可以无限增加的（实际最大可以达到 Integer.MAX_VALUE，为 2^31-1，这个数非常大，所以基本不可能达到），而当线程闲置时还可以对线程进行回收。也就是说该线程池的线程数量不是固定不变的，当然它也有一个用于存储提交任务的队列，但这个队列是 SynchronousQueue，队列的容量为0，实际不存储任何任务，它只负责对任务进行中转和传递，所以效率比较高。
        - SingleThreadExecutor：它会使用唯一的线程去执行任务，原理和 FixedThreadPool 是一样的，只不过这里线程只有一个，如果线程在执行任务的过程中发生异常，线程池也会重新创建一个线程来执行后续的任务。这种线程池由于只有一个线程，所以非常适合用于所有任务都需要按被提交的顺序依次执行的场景，而前几种线程池不一定能够保障任务的执行顺序等于被提交的顺序，因为它们是多线程并行执行的。
        - SingleThreadScheduledExecutor：它实际和 ScheduledThreadPool 线程池非常相似，它只是 ScheduledThreadPool 的一个特例，内部只有一个线程。
        #image("Screenshot_20250904_200849.png")
      - 线程池一般是怎么用的
        - Java 中的 Executors 类定义了一些快捷的工具方法，来帮助我们快速创建线程池。《阿里巴巴 Java 开发手册》中提到，禁止使用这些方法来创建线程池，而应该手动 new ThreadPoolExecutor 来创建线程池。这一条规则的背后，是大量血淋淋的生产事故，最典型的就是 newFixedThreadPool 和 newCachedThreadPool，可能因为资源耗尽导致 OOM 问题。
        - 所以，不建议使用 Executors 提供的两种快捷的线程池，原因如下：
          - 我们需要根据自己的场景、并发情况来评估线程池的几个核心参数，包括核心线程数、最大线程数、线程回收策略、工作队列的类型，以及拒绝策略，确保线程池的工作行为符合需求，一般都需要设置有界的工作队列和可控的线程数。
          - 任何时候，都应该为自定义线程池指定有意义的名称，以方便排查问题。当出现线程数量暴增、线程死锁、线程占用大量 CPU、线程执行出现异常等问题时，我们往往会抓取线程栈。此时，有意义的线程名称，就可以方便我们定位问题。
          #image("Screenshot_20250904_201320.png")
        - 除了建议手动声明线程池以外，我还建议用一些监控手段来观察线程池的状态。线程池这个组件往往会表现得任劳任怨、默默无闻，除非是出现了拒绝策略，否则压力再大都不会抛出一个异常。如果我们能提前观察到线程池队列的积压，或者线程数量的快速膨胀，往往可以提早发现并解决问题。
        - #image("Screenshot_20250904_201438.png")
      - 线程池中shutdown ()，shutdownNow()这两个方法有什么作用？
        - shutdown使用了以后会置状态为SHUTDOWN，正在执行的任务会继续执行下去，没有被执行的则中断。此时，则不能再往线程池中添加任何任务，否则将会抛出 RejectedExecutionException 异常
        - 而 shutdownNow 为STOP，并试图停止所有正在执行的线程，不再处理还在池队列中等待的任务，当然，它会返回那些未执行的任务。 它试图终止线程的方法是通过调用 Thread.interrupt() 方法来实现的，但是这种方法的作用有限，如果线程中没有sleep 、wait、Condition、定时锁等应用, interrupt()方法是无法中断当前的线程的。所以，ShutdownNow()并不代表线程池就一定立即就能退出，它可能必须要等待所有正在执行的任务都执行完成了才能退出。
        #image("Screenshot_20250904_202331.png")
      - 提交给线程池中的任务可以被撤回吗？
        - 可以，当向线程池提交任务时，会得到一个Future对象。这个Future对象提供了几种方法来管理任务的执行，包括取消任务。
        - 取消任务的主要方法是Future接口中的cancel(boolean mayInterruptIfRunning)方法。这个方法尝试取消执行的任务。参数mayInterruptIfRunning指示是否允许中断正在执行的任务。如果设置为true，则表示如果任务已经开始执行，那么允许中断任务；如果设置为false，任务已经开始执行则不会被中断。
        - #image("Screenshot_20250904_202634.png")
        - #image("Screenshot_20250904_202658.png")
  - 场景
    - 多线程打印奇偶数，怎么控制打印的顺序
      - 可以利用wait()和notify()来控制线程的执行顺序。













      


