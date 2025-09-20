= Mysql面试题 
- SQL基础
  - NOSQL和SQL的区别？
    - SQL数据库，指关系型数据库 - 主要代表：SQL Server，Oracle，MySQL(开源)，PostgreSQL(开源)。
    - 关系型数据库存储结构化数据。这些数据逻辑上以行列二维表的形式存在，每一列代表数据的一种属性，每一行代表一个数据实体。
    - NoSQL指非关系型数据库 ，主要代表：MongoDB，Redis。NoSQL 数据库逻辑上提供了不同于二维表的存储方式，存储方式可以是JSON文档、哈希表或者其他方式。
  - 选择 SQL vs NoSQL，考虑以下因素。
    - ACID vs BASE
      - 关系型数据库支持 ACID 即原子性，一致性，隔离性和持续性。相对而言，NoSQL 采用更宽松的模型 BASE ， 即基本可用，软状态和最终一致性。
      - 从实用的角度出发，我们需要考虑对于面对的应用场景，ACID 是否是必须的。比如银行应用就必须保证 ACID，否则一笔钱可能被使用两次；又比如社交软件不必保证 ACID，因为一条状态的更新对于所有用户读取先后时间有数秒不同并不影响使用。
      - 对于需要保证 ACID 的应用，我们可以优先考虑 SQL。反之则可以优先考虑 NoSQL。
      #image("Screenshot_20250919_150710.png")
      #image("Screenshot_20250919_150731.png")
      #image("Screenshot_20250919_150851.png")
    - 扩展性对比
      - NoSQL数据之间无关系，这样就非常容易扩展，也无形之间，在架构的层面上带来了可扩展的能力。比如 redis 自带主从复制模式、哨兵模式、切片集群模式。
      - 相反关系型数据库的数据之间存在关联性，水平扩展较难 ，需要解决跨服务器 JOIN，分布式事务等问题。
- 数据库三大范式是什么？
  - 第一范式（1NF）：要求数据库表的每一列都是不可分割的原子数据项。
    #image("Screenshot_20250920_152855.png")
  - 第二范式（2NF）：在1NF的基础上，非码属性必须完全依赖于候选码（在1NF基础上消除非主属性对主码的部分函数依赖）
  - 第二范式需要确保数据库表中的每一列都和主键相关，而不能只与主键的某一部分相关（主要针对联合主键而言）。
    #image("Screenshot_20250920_153032.png")
  - 第三范式（3NF）：在2NF基础上，任何非主属性 (opens new window)不依赖于其它非主属性（在2NF基础上消除传递依赖）
  - 第三范式需要确保数据表中的每一列数据都和主键直接相关，而不能间接相关。
    #image("Screenshot_20250920_153118.png")
- MySQL 怎么连表查询？
  - 数据库有以下几种联表查询类型：
    - 内连接 (INNER JOIN)
    - 左外连接 (LEFT JOIN)
    - 右外连接 (RIGHT JOIN)
    - 全外连接 (FULL JOIN)
    #image("Screenshot_20250920_153221.png")
  - 全外连接返回两个表中所有行，包括非匹配行，在MySQL中，FULL JOIN 需要使用 UNION 来实现，因为 MySQL 不直接支持 FULL JOIN。
  ```SQL
      SELECT employees.name, departments.name
    FROM employees
    LEFT JOIN departments
    ON employees.department_id = departments.id

    UNION

    SELECT employees.name, departments.name
    FROM employees
    RIGHT JOIN departments
    ON employees.department_id = departments.id;

  ```
  - MySQL如何避免重复插入数据？
    - 方式一：使用UNIQUE约束
    ```SQL
      CREATE TABLE users (
      id INT PRIMARY KEY AUTO_INCREMENT,
      email VARCHAR(255) UNIQUE,
      name VARCHAR(255)
  );

    ```
    - 方式二：使用INSERT ... ON DUPLICATE KEY UPDATE
      - 这种语句允许在插入记录时处理重复键的情况。如果插入的记录与现有记录冲突，可以选择更新现有记录：
      ```SQL
            INSERT INTO users (email, name) 
      VALUES ('example@example.com', 'John Doe')
      ON DUPLICATE KEY UPDATE name = VALUES(name);
      ```
      - 如果 email 列是 主键 或 唯一索引，那么当插入已经存在的 email 时，就会触发 ON DUPLICATE KEY UPDATE.因此，name 会被更新，而 email 保持原值
    - 方式三：使用INSERT IGNORE： 该语句会在插入记录时忽略那些因重复键而导致的插入错误。
      ```SQL
            INSERT IGNORE INTO users (email, name) 
      VALUES ('example@example.com', 'John Doe');

      ```
      - 如果email已经存在，这条插入语句将被忽略而不会返回错误。
    - 如果需要保证全局唯一性，使用UNIQUE约束是最佳做法。
    - 如果需要插入和更新结合可以使用ON DUPLICATE KEY UPDATE。
    - 对于快速忽略重复插入，INSERT IGNORE是合适的选择。
- CHAR 和 VARCHAR有什么区别？
  - CHAR是固定长度的字符串类型，定义时需要指定固定长度，存储时会在末尾补足空格。CHAR适合存储长度固定的数据，如固定长度的代码、状态等，存储空间固定，对于短字符串效率较高。
  - VARCHAR是可变长度的字符串类型，定义时需要指定最大长度，实际存储时根据实际长度占用存储空间。VARCHAR适合存储长度可变的数据，如用户输入的文本、备注等，节约存储空间。
  - 修改char
    - 严格模式报错
    - 非严格模式截断加警告
  - 修改VARCHAR
    - 在n范围内，可以修改
    - 在n范围外
      - 严格模式报错
      - 非严格模式截断加警告
- varchar后面代表字节还是会字符？
  - VARCHAR 后面括号里的数字代表的是字符数，而不是字节数。
  - 比如 VARCHAR(10)，这里的 10 表示该字段最多可以存储 10 个字符。字符的字节长度取决于所使用的字符集。
    - 如果字符集是 ASCII 字符集：ASCII 字符集每个字符占用 1 个字节，那么 VARCHAR(10) 最多可以存储 10 个 ASCII 字符，同时占用的存储空间最多为 10 个字节（不考虑额外的长度记录开销）。
    - 如果字符集是 UTF - 8 字符集，它的每个字符可能占用 1 到 4 个字节，对于 VARCHAR(10) 的字段，它最多可以存储 10 个字符，但占用的字节数会根据字符的不同而变化。
- int(1) int(10) 在mysql有什么不同？
  - INT(1) 和 INT(10) 的区别主要在于 显示宽度，而不是存储范围或数据类型本身的大小。以下是核心区别的总结：
  - 本质是显示宽度，不改变存储方式：INT 的存储固定为 4 字节，所有 INT（无论写成 INT(1) 还是 INT(10)）占用的存储空间 均为 4 字节。括号内的数值（如 1 或 10）是显示宽度，用于在 特定场景下 控制数值的展示格式。
  - 唯一作用场景：ZEROFILL 补零显示，当字段设置 ZEROFILL 时：数字显示时会用前导零填充至指定宽度。比如，字段类型为 INT(4) ZEROFILL，实际存入 5 → 显示为 0005，实际存入 12345 → 显示仍为 12345（宽度超限时不截断）。
  #image("Screenshot_20250920_154809.png")
- Text数据类型可以无限大吗？
  - TEXT：65,535 bytes ~64kb
  - MEDIUMTEXT：16,777,215 bytes ~16Mb
  - LONGTEXT：4,294,967,295 bytes ~4Gb
- IP地址如何在数据库里存储？
  - IPv4 地址是一个 32 位的二进制数，通常以点分十进制表示法呈现，例如 192.168.1.1。
  - 字符串类型的存储方式：直接将 IP 地址作为字符串存储在数据库中，比如可以用 VARCHAR(15)来存储。
    - 优点：直观易懂，方便直接进行数据的插入、查询和显示，不需要进行额外的转换操作。
    - 缺点：占用存储空间较大，字符串比较操作的性能相对较低，不利于进行范围查询。
  - 整数类型的存储方式：将 IPv4 地址转换为 32 位无符号整数进行存储，常用的数据类型有 INT UNSIGNED。
    - 优点：占用存储空间小，整数比较操作的性能较高，便于进行范围查询。
    - 缺点：需要进行额外的转换操作，不够直观，增加了开发的复杂度。
- 说一下外键约束
  - 外键约束的作用是维护表与表之间的关系，确保数据的完整性和一致性。让我们举一个简单的例子：
    - 假设你有两个表，一个是学生表，另一个是课程表，这两个表之间有一个关系，即一个学生可以选修多门课程，而一门课程也可以被多个学生选修。在这种情况下，我们可以在学生表中定义一个指向课程表的外键
    - 这里，students表中的course_id字段是一个外键，它指向courses表中的id字段。这个外键约束确保了每个学生所选的课程在courses表中都存在，从而维护了数据的完整性和一致性。
    - 如果没有定义外键约束，那么就有可能出现学生选了不存在的课程或者删除了一个课程而忘记从学生表中删除选修该课程的学生的情况，这会破坏数据的完整性和一致性。因此，使用外键约束可以帮助我们避免这些问题。
- MySQL的关键字in和exist
  - 在MySQL中，IN 和 EXISTS 都是用来处理子查询的关键词，但它们在功能、性能和使用场景上有各自的特点和区别。
    - IN关键字
      - IN 用于检查左边的表达式是否存在于右边的列表或子查询的结果集中。如果存在，则IN 返回TRUE，否则返回FALSE。
    - EXISTS关键字
      - EXISTS 用于判断子查询是否至少能返回一行数据。它不关心子查询返回什么数据，只关心是否有结果。如果子查询有结果，则EXISTS 返回TRUE，否则返回FALSE。
      #image("Screenshot_20250920_160036.png")
    - in和exists父查询返回的数据都会被in或exists过滤条件
  - 区别与选择：
    - 性能差异：在很多情况下，EXISTS 的性能优于 IN，特别是当子查询的表很大时。这是因为EXISTS 一旦找到匹配项就会立即停止查询，而IN可能会扫描整个子查询结果集。
    - 使用场景：如果子查询结果集较小且不频繁变动，IN 可能更直观易懂。而当子查询涉及外部查询的每一行判断，并且子查询的效率较高时，EXISTS 更为合适。
    - NULL值处理：IN 能够正确处理子查询中包含NULL值的情况，而EXISTS 不受子查询结果中NULL值的影响，因为它关注的是行的存在性，而不是具体值。
  - 子查询数据多，子表有索引，用exists
  - 子查询数据少，外层表有索引，用in
  - mysql的执行机制，即使你写了in,也可能优化成exists,主要还是看执行计划
- mysql中的一些基本函数，你知道哪些？

    


