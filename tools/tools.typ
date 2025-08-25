- ARMS系统监控
  - 阿里云
  - 探针技术 javaagent 在java应用启动时或运行时动态修改字节码 无侵入式监控
  - prometheus+Grafana
    - prometheus
      - 时序数据库 拉取模式 
      - 指标类型
      - 内存 预写日志 持久化到硬盘
    - Grafana
      - 数据可视化
- mongodb
  - 文件和集合
  - BSON
  - 数据页，页号，层级
  - 写时复制，b+树
  - cache
  - 写前日志，顺序写入（磁盘随机写入）
  - checkpoint
  - wiredtiger存储引擎
  - server层
    - 解析器
    - 优化器
    - 执行器
  - 路由mongos。，分片
  - 副本集，类似于主从
  - 和mysql对比
  #image("Screenshot_20250823_101851.png")
  #image("Screenshot_20250823_101923.png")
  #image("Screenshot_20250823_101931.png")