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










      


