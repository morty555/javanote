- 循环优化
  - 融合
    - 把多个遍历相同范围的循环合并成一个。
  - 分块
    - 把一个大循环分解成多个小循环，以提高缓存命中率。
    ```java
    // 未优化：矩阵乘法，访问跨度大，cache miss 多
for (int i = 0; i < N; i++)
  for (int j = 0; j < N; j++)
    for (int k = 0; k < N; k++)
      C[i][j] += A[i][k] * B[k][j];

// 优化后：循环分块
for (int ii = 0; ii < N; ii += BLOCK)
  for (int jj = 0; jj < N; jj += BLOCK)
    for (int kk = 0; kk < N; kk += BLOCK)
      for (int i = ii; i < ii + BLOCK; i++)
        for (int j = jj; j < jj + BLOCK; j++)
          for (int k = kk; k < kk + BLOCK; k++)
            C[i][j] += A[i][k] * B[k][j];
 
    ```
  - 交换
    - 改变循环嵌套顺序，提高 内存访问局部性。fori forj遍历a[i][j]和a[j][i]的内存访问局部性不同。
  - 展开
    - 一次循环体执行多次迭代。
    - 比如对fori的步长为1的累加，可以变成步长为4的循环，每次累加4个元素，然后再把4个结果相加。
  
- \@AllArgsConstructor 会生成 包含类中所有字段的构造函数，不管字段上有没有 \@Autowired。

- arthas 了解么？用作干嘛的 底层原理怎么实现的
  - Arthas 是阿里开源的 Java 诊断工具，用于在线诊断 Java 应用（可以在生产环境直接排查问题），无需改代码、无需重启 JVM。常见用途：排查慢方法、查看方法入参/返回/异常、定位类加载冲突、查看线程/CPU/G C 状态、在线反编译、生成火焰图等
  - 底层实现原理
    - Arthas 通过 Java 的 Attach/Agent 机制把自己“注入”到目标 JVM 进程里（arthas-boot/as.sh 会把 agent 动态 attach 到目标 JVM，或者通过 -javaagent 启动），因此不需要重启应用。注入后它在目标 JVM 内部启动一个服务供客户端连接
    - 注入后 Arthas 会在目标进程内启动一个 TCP 服务（也支持 websocket / web-ui），客户端（arthas client / telnet / web console）通过这个通道发送命令并获得结果（因此需要目标进程允许本地进程 attach 和网络连接）。官方 FAQ 也明确说明 Arthas 启动了进程内的 tcp server。
    - 为了实现 watch、trace、monitor 等功能，Arthas 会在运行时修改/增强目标类的字节码，插入监控逻辑（例如在方法入口/出口记录时间、参数、返回值、异常、调用链信息等）。这种插桩通常借助 Java 的 java.lang.instrument（Agent + ClassFileTransformer）配合字节码操作库来实现（可以在类加载时或通过 retransform 来修改已经加载的类）。

- 软链接和硬链接了解么
  - 硬链接（Hard Link）
    - 是指向 文件数据本身（inode） 的引用。
    - 本质上是给一个已有文件取了一个别名。
    - 不会单独占用磁盘空间（除了目录项）。
    - 删除原文件名不会影响硬链接，文件内容仍然存在，只有当所有硬链接都删除后，文件才真正释放空间。
  - 软链接（Symbolic Link / Symlink）
    - 是一个 独立的文件，里面保存的是被链接文件的路径。
    - 相当于一个快捷方式。
    - 可以跨文件系统。
    - 删除原文件后，软链接会变成“悬挂链接”（dangling link），无法访问原文件。