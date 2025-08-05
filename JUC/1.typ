#set text(size: 2em)
- 进程和线程
  #image("Screenshot_20250722_223033.png")
  #image("Screenshot_20250722_223206.png")
- 并行和并发

  任务调度器分配CPU使用时间给不同线程使用

  线程轮流占用CPU为并发

  多核CPU，多个线程可以同时进行，为并行（多个线程在多个多核上运行）
- 同步异步
  
  需要等待结果返回才能继续运行的是同步

  不需要等待结果的是异步

  单核开多线程比单线程更慢，因为需要上下文切换，但是可以让任务轮流占用，不至于一个任务一直占用cpu
  #image("Screenshot_20250722_234757.png")
- 创建线程
  - 直接使用thread

  #image("Screenshot_20250723_223436.png")
  
  - runnable
  #image("Screenshot_20250723_223720.png")
  函数式编程
  #image("Screenshot_20250723_224128.png")

  - 关系
  #image("Screenshot_20250723_224331.png")
  - futuretask
  #image("Screenshot_20250723_224356.png")
  get需要等待线程执行完

- windows查看和杀死线程
  - tasklist 查看线程
  - taskkill 杀死线程

  
- linux查看和杀死线程
  - ps
  - kill
  - | grep
- Java
  - jps 列出当前系统上运行的所有 Java 进程（JVM）及其进程 ID（PID）
  - jstack
  - jconsole
  #image("Screenshot_20250724_221607.png")

