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