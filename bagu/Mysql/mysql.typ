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
  - 字符串函数
    - CONCAT(str1, str2, ...)：连接多个字符串，返回一个合并后的字符串。
    - LENGTH(str)：返回字符串的长度（字符数）。
    - SUBSTRING(str, pos, len)：从指定位置开始，截取指定长度的子字符串。
    - REPLACE(str, from_str, to_str)：将字符串中的某部分替换为另一个字符串。
  - 数值函数
    - ABS(num)：返回数字的绝对值。
    - POWER(num, exponent)：返回指定数字的指定幂次方。
  - 日期和时间函数
    - NOW()：返回当前日期和时间。
    - CURDATE()：返回当前日期。
  - 聚合函数
    - COUNT(column)：计算指定列中的非NULL值的个数。
    - SUM(column)：计算指定列的总和。
    - AVG(column)：计算指定列的平均值。
    - MAX(column)：返回指定列的最大值。
    - MIN(column)：返回指定列的最小值。
- SQL查询语句的执行顺序是怎么样的？
  - 所有的查询语句都是从FROM开始执行，在执行过程中，每个步骤都会生成一个虚拟表，这个虚拟表将作为下一个执行步骤的输入，最后一个步骤产生的虚拟表即为输出结果。
  ```SQL
    (9) SELECT 
  (10) DISTINCT <column>,
  (6) AGG_FUNC <column> or <expression>, ...
  (1) FROM <left_table> 
      (3) <join_type>JOIN<right_table>
      (2) ON<join_condition>
  (4) WHERE <where_condition>
  (5) GROUP BY <group_by_list>
  (7) WITH {CUBE|ROLLUP}
  (8) HAVING <having_condtion>
  (11) ORDER BY <order_by_list>
  (12) LIMIT <limit_number>; 
  ```
  #image("Screenshot_20250921_120826.png")
- sql题：给学生表、课程成绩表，求不存在01课程但存在02课程的学生的成绩
  - 方法1：使用LEFT JOIN 和 IS NULL
  ```SQL
    SELECT s.sid, s.sname, sc2.cid, sc2.score
  FROM Student s
  LEFT JOIN Score AS sc1 ON s.sid = sc1.sid AND sc1.cid = '01'
  LEFT JOIN Score AS sc2 ON s.sid = sc2.sid AND sc2.cid = '02'
  WHERE sc1.cid IS NULL AND sc2.cid IS NOT NULL;
  ```
  - 方法2：使用NOT EXISTS
  ```SQL
    SELECT s.sid, s.sname, sc.cid, sc.score
  FROM Student s
  JOIN Score sc ON s.sid = sc.sid AND sc.cid = '02'
  WHERE NOT EXISTS (
      SELECT 1 FROM Score sc1 WHERE sc1.sid = s.sid AND sc1.cid = '01'
  );
 
  ```
- 给定一个学生表 student_score（stu_id，subject_id，score），查询总分排名在5-10名的学生id及对应的总分
  - 其中我们先计算每个学生的总分，然后为其分配一个排名，最后检索排名在 5 到 10 之间的记录。
  ```SQL
      WITH StudentTotalScores AS (
        SELECT 
            stu_id,
            SUM(score) AS total_score
        FROM 
            student_score
        GROUP BY 
            stu_id
    ),
    RankedStudents AS (
        SELECT
            stu_id,
            total_score,
            RANK() OVER (ORDER BY total_score DESC) AS ranking
        FROM
            StudentTotalScores
    )
    SELECT
        stu_id,
        total_score
    FROM
        RankedStudents
    WHERE
        ranking BETWEEN 5 AND 10;

  ```
  - 子查询 StudentTotalScores 中，我们通过对 student_score 表中的 stu_id 分组来计算每个学生的总分。
  - 子查询 RankedStudents 中，我们使用 RANK() 函数为每个学生分配一个排名，按总分从高到低排序。
  - 最后，我们在主查询中选择排名在 5 到 10 之间的学生。
- SQL题：查某个班级下所有学生的选课情况
  ```SQL
      SELECT 
        s.student_id,
        s.student_name,
        cs.course_name
    FROM 
        students s
    JOIN 
        course_selections cs ON s.student_id = cs.student_id
    JOIN 
        classes c ON s.class_id = c.class_id
    WHERE 
        c.class_name = 'Class A';

  ```
- 如何用 MySQL 实现一个可重入的锁？
  - 创建一个保存锁记录的表：
  ```java
    CREATE TABLE `lock_table` (
      `id` INT AUTO_INCREMENT PRIMARY KEY,
      //该字段用于存储锁的名称，作为锁的唯一标识符。
      `lock_name` VARCHAR(255) NOT NULL, 
      // holder_thread该字段存储当前持有锁的线程的名称，用于标识哪个线程持有该锁。
      `holder_thread` VARCHAR(255),   
      // reentry_count 该字段存储锁的重入次数，用于实现锁的可重入性
      `reentry_count` INT DEFAULT 0
  );
  ```
  - 加锁的实现逻辑
    - 开启事务
    - 执行 SQL SELECT holder_thread, reentry_count FROM lock_table WHERE lock_name =? FOR UPDATE，查询是否存在该记录：
      - 如果记录不存在，则直接加锁，执行 INSERT INTO lock_table (lock_name, holder_thread, reentry_count) VALUES (?,?, 1)
      - 如果记录存在，且持有者是同一个线程，则可冲入，增加重入次数，执行 UPDATE lock_table SET reentry_count = reentry_count + 1 WHERE lock_name =?
        - FOR UPDATE的作用是排他锁，其他事务如果也想更新这些行（或者也用 FOR UPDATE 查询同一行），就必须等待当前事务提交或回滚。
    - 提交事务
  - 解锁的逻辑
    - 开启事务
    - 执行 SQL SELECT holder_thread, reentry_count FROM lock_table WHERE lock_name =? FOR UPDATE，查询是否存在该记录：
      - 如果记录存在，且持有者是同一个线程，且可重入数大于 1 ，则减少重入次数 UPDATE lock_table SET reentry_count = reentry_count - 1 WHERE lock_name =?
      - 如果记录存在，且持有者是同一个线程，且可重入数小于等于 0 ，则完全释放锁，DELETE FROM lock_table WHERE lock_name =?
    - 提交事务
= 存储引擎
- 执行一条SQL请求的过程是什么？
  - 连接器：建立连接，管理连接、校验用户身份；
  - 查询缓存：查询语句如果命中查询缓存则直接返回，否则继续往下执行。MySQL 8.0 已删除该模块；
  - 解析 SQL，通过解析器对 SQL 查询语句进行词法分析、语法分析，然后构建语法树，方便后续模块读取表名、字段、语句类型；
  - 执行 SQL：执行 SQL 共有三个阶段：
    - 预处理阶段：检查表或字段是否存在；将 select \* 中的 \* 符号扩展为表上的所有列。
    - 优化阶段：基于查询成本的考虑， 选择查询成本最小的执行计划；
    - 执行阶段：根据执行计划执行 SQL 查询语句，从存储引擎读取记录，返回给客户端；
    #image("Screenshot_20250921_134009.png")
  - 为什么删除缓存
   #image("Screenshot_20250921_134228.png")
- MySQL为什么InnoDB是默认引擎？
  - InnoDB引擎在事务支持、并发性能、崩溃恢复等方面具有优势，因此被MySQL选择为默认的存储引擎。
  - 事务支持：InnoDB引擎提供了对事务的支持，可以进行ACID（原子性、一致性、隔离性、持久性）属性的操作。Myisam存储引擎是不支持事务的。
  - 并发性能：InnoDB引擎采用了行级锁定的机制，可以提供更好的并发性能，Myisam存储引擎只支持表锁，锁的粒度比较大。
  - 崩溃恢复：InnoDB引引擎通过 redolog 日志实现了崩溃恢复，可以在数据库发生异常情况（如断电）时，通过日志文件进行恢复，保证数据的持久性和一致性。Myisam是不支持崩溃恢复的。
-  说一下mysql的innodb与MyISAM的区别？
  - 事务：InnoDB 支持事务，MyISAM 不支持事务，这是 MySQL 将默认存储引擎从 MyISAM 变成 InnoDB 的重要原因之一。
  - 索引结构：InnoDB 是聚簇索引，MyISAM 是非聚簇索引。聚簇索引的文件存放在主键索引的叶子节点上，因此 InnoDB 必须要有主键，通过主键索引效率很高。但是辅助索引需要两次查询，先查询到主键，然后再通过主键查询到数据。因此，主键不应该过大，因为主键太大，其他索引也都会很大。而 MyISAM 是非聚簇索引，数据文件是分离的，索引保存的是数据文件的指针。主键索引和辅助索引是独立的。
  - 锁粒度：InnoDB 最小的锁粒度是行锁，MyISAM 最小的锁粒度是表锁。一个更新语句会锁住整张表，导致其他查询和更新都会被阻塞，因此并发访问受限。
  - count 的效率：InnoDB 不保存表的具体行数，执行 select count(\*) from table 时需要全表扫描。而MyISAM 用一个变量保存了整个表的行数，执行上述语句时只需要读出该变量即可，速度很快。
- 数据管理里，数据文件大体分成哪几种数据文件？
  - 我们每创建一个 database（数据库） 都会在 /var/lib/mysql/ 目录里面创建一个以 database 为名的目录，然后保存表结构和表数据的文件都会存放在这个目录里。
  - 比如，我这里有一个名为 my_test 的 database，该 database 里有一张名为 t_order 数据库表。
  - 然后，我们进入 /var/lib/mysql/my_test 目录，看看里面有什么文件？
    - db.opt，用来存储当前数据库的默认字符集和字符校验规则。
    - t_order.frm ，t_order 的表结构会保存在这个文件。在 MySQL 中建立一张表都会生成一个.frm 文件，该文件是用来保存每个表的元数据信息的，主要包含表结构定义。
    - t_order.ibd，t_order 的表数据会保存在这个文件。表数据既可以存在共享表空间文件（文件名：ibdata1）里，也可以存放在独占表空间文件（文件名：表名字.ibd）。这个行为是由参数 innodb_file_per_table 控制的，若设置了参数 innodb_file_per_table 为 1，则会将存储的数据、索引等信息单独存储在一个独占表空间，从 MySQL 5.6.6 版本开始，它的默认值就是 1 了，因此从这个版本之后， MySQL 中每一张表的数据都存放在一个独立的 .ibd 文件。
= 索引
- 索引是什么？有什么好处？
  - 索引类似于书籍的目录，可以减少扫描的数据量，提高查询效率。
  - 如果查询的时候，没有用到索引就会全表扫描，这时候查询的时间复杂度是On
  - 如果用到了索引，那么查询的时候，可以基于二分查找算法，通过索引快速定位到目标数据， mysql 索引的数据结构一般是 b+树，其搜索复杂度为O(logdN)，其中 d 表示节点允许的最大子节点个数为 d 个。
- 讲讲索引的分类是什么？
  - 按「数据结构」分类：B+tree索引、Hash索引、Full-text索引。
  - 按「物理存储」分类：聚簇索引（主键索引）、二级索引（辅助索引）。
  - 按「字段特性」分类：主键索引、唯一索引、普通索引、前缀索引。
  - 按「字段个数」分类：单列索引、联合索引。
  - 按数据结构分类
    - 从数据结构的角度来看，MySQL 常见索引有 B+Tree 索引、HASH 索引、Full-Text 索引。
    - 每一种存储引擎支持的索引类型不一定相同，我在表中总结了 MySQL 常见的存储引擎 InnoDB、MyISAM 和 Memory 分别支持的索引类型。
    #image("Screenshot_20250921_135604.png")
    - InnoDB 是在 MySQL 5.5 之后成为默认的 MySQL 存储引擎，B+Tree 索引类型也是 MySQL 存储引擎采用最多的索引类型。
    - 在创建表时，InnoDB 存储引擎会根据不同的场景选择不同的列作为索引：
      - 如果有主键，默认会使用主键作为聚簇索引的索引键（key）；
      - 如果没有主键，就选择第一个不包含 NULL 值的唯一列作为聚簇索引的索引键（key）；
      - 在上面两个都没有的情况下，InnoDB 将自动生成一个隐式自增 id 列作为聚簇索引的索引键（key）；
    - 其它索引都属于辅助索引（Secondary Index），也被称为二级索引或非聚簇索引。创建的主键索引和二级索引默认使用的是 B+Tree 索引。
    - hash索引
    #image("Screenshot_20250921_135734.png")
    - fulltext索引 
    #image("Screenshot_20250921_135849.png")
    - fulltext和es区别
    #image("Screenshot_20250921_135916.png")
  - 按物理存储分类
    - 从物理存储的角度来看，索引分为聚簇索引（主键索引）、二级索引（辅助索引）。
    - 这两个区别在前面也提到了：
      - 主键索引的 B+Tree 的叶子节点存放的是实际数据，所有完整的用户记录都存放在主键索引的 B+Tree 的叶子节点里；
      - 二级索引的 B+Tree 的叶子节点存放的是主键值，而不是实际数据。
      - 所以，在查询时使用了二级索引，如果查询的数据能在二级索引里查询的到，那么就不需要回表，这个过程就是覆盖索引。如果查询的数据不在二级索引里，就会先检索二级索引，找到对应的叶子节点，获取到主键值后，然后再检索主键索引，就能查询到数据了，这个过程就是回表。
      - 二级索引也需要走到叶子节点才能查询到信息，中间节点只是索引不存储数据
      #image("Screenshot_20250921_140247.png")
  - 按字段特性分类
    - 从字段特性的角度来看，索引分为主键索引、唯一索引、普通索引、前缀索引。
    - 主键索引
      - 主键索引就是建立在主键字段上的索引，通常在创建表的时候一起创建，一张表最多只有一个主键索引，索引列的值不允许有空值。
    - 唯一索引
      - 唯一索引建立在 UNIQUE 字段上的索引，一张表可以有多个唯一索引，索引列的值必须唯一，但是允许有空值。
      - NULL是如何存储的？
      #image("Screenshot_20250921_140535.png")
      - 但是NULL不等于NULL，只有 IS NULL / IS NOT NULL 才能正常用到索引。
    - 普通索引
      - 普通索引就是建立在普通字段上的索引，既不要求字段为主键，也不要求字段为 UNIQUE。
    - 前缀索引
      - 前缀索引是指对字符类型字段的前几个字符建立的索引，而不是在整个字段上建立的索引，前缀索引可以建立在字段类型为 char、 varchar、binary、varbinary 的列上。
      - 使用前缀索引的目的是为了减少索引占用的存储空间，提升查询效率。
  - 按字段个数分类
    - 从字段个数的角度来看，索引分为单列索引、联合索引（复合索引）。
      - 建立在单列上的索引称为单列索引，比如主键索引；
      - 建立在多列上的索引称为联合索引；
    - 通过将多个字段组合成一个索引，该索引就被称为联合索引。
    - 联合索引的非叶子节点用两个字段的值作为 B+Tree 的 key 值。当在联合索引查询数据时，先按 product_no 字段比较，在 product_no 相同的情况下再按 name 字段比较。
    - 也就是说，联合索引查询的 B+Tree 是先按 product_no 进行排序，然后再 product_no 相同的情况再按 name 字段排序。
    - 因此，使用联合索引时，存在最左匹配原则，也就是按照最左优先的方式进行索引的匹配。在使用联合索引进行查询的时候，如果不遵循「最左匹配原则」，联合索引会失效，这样就无法利用到索引快速查询的特性了。
    - 比如，如果创建了一个 (a, b, c) 联合索引，如果查询条件是以下这几种，就可以匹配上联合索引：
      ```SQL
          where a=1；
    where a=1 and b=2 and c=3；
    where a=1 and b=2；

      ```
    - 需要注意的是，因为有查询优化器，所以 a 字段在 where 子句的顺序并不重要。
    - 但是，如果查询条件是以下这几种，因为不符合最左匹配原则，所以就无法匹配上联合索引，联合索引就会失效:
    ```SQL 
    where b=2；
    where c=3；
    where b=2 and c=3；

    ```
    - 上面这些查询条件之所以会失效，是因为(a, b, c) 联合索引，是先按 a 排序，在 a 相同的情况再按 b 排序，在 b 相同的情况再按 c 排序。所以，b 和 c 是全局无序，局部相对有序的，这样在没有遵循最左匹配原则的情况下，是无法利用到索引的。
    - 联合索引有一些特殊情况，并不是查询过程使用了联合索引查询，就代表联合索引中的所有字段都用到了联合索引进行索引查询，也就是可能存在部分字段用到联合索引的 B+Tree，部分字段没有用到联合索引的 B+Tree 的情况。
    - 这种特殊情况就发生在范围查询。联合索引的最左匹配原则会一直向右匹配直到遇到「范围查询」就会停止匹配。也就是范围查询的字段可以用到联合索引，但是在范围查询字段的后面的字段无法用到联合索引。
    - 范围查询必须要一个个拿出来
    #image("Screenshot_20250921_141353.png")
    - 因此即使是大于等于的范围查询，在大于等于取等于的情况也是会让后面的索引失效的
-  MySQL聚簇索引和非聚簇索引的区别是什么？
  - 数据存储：在聚簇索引中，数据行按照索引键值的顺序存储，也就是说，索引的叶子节点包含了实际的数据行。这意味着索引结构本身就是数据的物理存储结构。非聚簇索引的叶子节点不包含完整的数据行，而是包含指向数据行的指针或主键值。数据行本身存储在聚簇索引中。
  - 索引与数据关系：由于数据与索引紧密相连，当通过聚簇索引查找数据时，可以直接从索引中获得数据行，而不需要额外的步骤去查找数据所在的位置。当通过非聚簇索引查找数据时，首先在非聚簇索引中找到对应的主键值，然后通过这个主键值回溯到聚簇索引中查找实际的数据行，这个过程称为“回表”。
  - 唯一性：聚簇索引通常是基于主键构建的，因此每个表只能有一个聚簇索引，因为数据只能有一种物理排序方式。一个表可以有多个非聚簇索引，因为它们不直接影响数据的物理存储位置。
  - 效率：对于范围查询和排序查询，聚簇索引通常更有效率，因为它避免了额外的寻址开销。非聚簇索引在使用覆盖索引进行查询时效率更高，因为它不需要读取完整的数据行。但是需要进行回表的操作，使用非聚簇索引效率比较低，因为需要进行额外的回表操作。
  - 聚簇索引不一定是主键索引
  #image("Screenshot_20250921_161048.png")
- 如果聚簇索引的数据更新，它的存储要不要变化？

    


