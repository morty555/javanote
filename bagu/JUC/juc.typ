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
      


