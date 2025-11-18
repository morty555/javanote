- 手撕 !!局部变量!! x = 5, 在方法新开一个线程修改x 为 x + 5, 最后主线程输出, 怎么做
  - 局部变量存在线程栈上，线程之间互不共享；而 lambda 捕获的变量实际上是拷贝或引用快照，必须保持不可变性才能保证线程安全。Java 的 lambda / 匿名内部类中 只能访问 final 或 effectively final 的局部变量。x 是局部变量，在线程中想修改会导致捕获变量失效。
  - 当你在 lambda/匿名类中访问方法里的局部变量时，Java 并不是直接让 lambda 去操作原来的栈帧上的变量。编译器会把 lambda 里用到的局部变量 复制一份值（或者引用）到 lambda 内部。lambda 捕获的这个变量 就是副本，原来的局部变量在方法栈里不变。如果允许 lambda 修改副本，原局部变量和副本就不同步，线程安全无法保证。
  -  解决方式 1：使用可变容器（AtomicInteger)
  - 解决方式 2：使用一元素数组（“小技巧”）
  - 解决方式 3：把变量变成成员变量
    - 成员变量是在线程共享的堆上存的，多个线程可以同时访问。
  - 解决方式 4（补充）：用 Future 拿线程计算结果
    - 线程返回新值，而不是修改外部变量。
  - 如果 x 在初始化后 没有再次被赋值，那么它就是 effectively final。
  - x.set(x.get()+5)不违反重新赋值的定义， x= new AtomicInteger(10)才违反，也就是说，修改对象的值，但是不修改对象，也是effectively final


- 手撕: 员工有工号(唯一), 姓名, 性别, 年龄, 薪水(精确小数点2位), 简介(5000字左右), 头像, 入职日期，写建表语句, 看看你怎么设计字段类型
      ```
      CREATE TABLE employee (
        emp_id BIGINT NOT NULL COMMENT '员工工号，唯一',
        name VARCHAR(100) NOT NULL COMMENT '姓名',
        gender ENUM('M','F') NOT NULL COMMENT '性别，M=男, F=女',
        age TINYINT UNSIGNED NOT NULL COMMENT '年龄',
        salary DECIMAL(10,2) NOT NULL COMMENT '薪水，保留两位小数',
        profile TEXT COMMENT '简介，5000字左右',
        avatar BLOB COMMENT '头像，二进制存储',
        hire_date DATE NOT NULL COMMENT '入职日期',
        PRIMARY KEY (emp_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工信息表';

  ```
  - BLOB（Binary Large Object）就是二进制大对象，用于存储图片、音频、视频等二进制数据。在 MySQL 里有几个等级：
    - TINYBLOB：最大 255 字节
    - BLOB：最大 65,535 字节 (~64 KB)
    - MEDIUMBLOB：最大 16 MB
    - LONGBLOB：最大 4 GB


- 基于你之前的表, 写一条查询入职时间超过2天的5名男性员工的工号, 按年龄从大到小排序
  ```
    SELECT emp_id
  FROM employee
  WHERE gender = 'M'
    AND hire_date <= DATE_SUB(CURDATE(), INTERVAL 2 DAY)
  ORDER BY age DESC
  LIMIT 5;

  ```

- 给一个链表的其中一个节点 只能从这个节点开始访问链表 删除这个节点但是不给你这个链表的头结点
  - 因为没有前驱指针也没有头节点，无法直接prev.next=node.next
  - 但是可以把下一个节点的值赋值给自己，然后删除下一个节点得到

  ```
  node.val = node.next.val;
  node.next = node.next.next;
  ```


- 区间反转链表
  ```java 
  

  class ListNode {
      int val;
      ListNode next;
      ListNode(int x) { val = x; }
  }

  public class test {
      public ListNode reverseBetween(ListNode head, int left, int right){
          if(head == null) return null;
          ListNode dummy = new ListNode(0);
          dummy.next = head;
          ListNode pre = dummy;
          for(int i = 0;i<left-1;i++){
              pre=pre.next;
          }
          ListNode curr = pre.next;
          ListNode prePoint = curr;
          while(left<right){
              ListNode next = curr.next;
              curr.next = next.next;
              next.next = prePoint;
              pre.next = next;
              prePoint = next;
              left++;
          }
          return dummy.next;

      }
      public static void main(String[] args) {
          test solution = new test();

          // 构造链表 1->2->3->4->5
          ListNode head = new ListNode(1);
          head.next = new ListNode(2);
          head.next.next = new ListNode(3);
          head.next.next.next = new ListNode(4);
          head.next.next.next.next = new ListNode(5);
          head.next.next.next.next.next = new ListNode(6);

          // 打印原链表
          System.out.print("原链表: ");
          printList(head);

          // 反转区间 2->4
          ListNode newHead = solution.reverseBetween(head, 2, 4);

          // 打印反转后链表
          System.out.print("反转后: ");
          printList(newHead);
      }

      // 打印链表辅助函数
      public static void printList(ListNode head){
          ListNode curr = head;
          while(curr != null){
              System.out.print(curr.val);
              if(curr.next != null) System.out.print("->");
              curr = curr.next;
          }
          System.out.println();
      }
  }

  ```
  - 注意循环次数是right-left,因为每次都是从curr下一个元素开始移动
  - 如反转区间2-4的链表，是从3开始把3开始往前移到1后2前，因此进行到4就结束了



- 代码题：经典的几十亿个int值去重问题
  - 位图
    - 全 32-bit 无符号整数需要 2^32 / 8 = 536,870,912 bytes ≈ 512 MiB 内存（或 mmap 文件），这对现代服务器非常可行。
    ```java
     public class BitmapDedupSimple {
        // 假设整数范围 0 ~ 9999
        static final int MAX_VALUE = 10000;
        static final byte[] bitmap = new byte[MAX_VALUE / 8 + 1];

        // 设置对应bit为1
        static void setBit(int num) {
            int byteIndex = num / 8;
            int bitIndex = num % 8;
            bitmap[byteIndex] |= (1 << bitIndex);
        }

        // 检查对应bit是否为1
        static boolean getBit(int num) {
            int byteIndex = num / 8;
            int bitIndex = num % 8;
            return (bitmap[byteIndex] & (1 << bitIndex)) != 0;
        }

        public static void main(String[] args) {
            int[] arr = {1, 5, 3, 5, 8, 3, 9, 1};

            System.out.println("原始数据：");
            for (int v : arr) System.out.print(v + " ");
            System.out.println("\n去重结果：");

            for (int v : arr) {
                if (!getBit(v)) { // 如果没出现过
                    setBit(v);    // 标记出现
                    System.out.print(v + " ");
                }
            }
        }
    }
    ```
    - java中没有原生的bitset，可以用byte数组模拟
    - 1byte有8bit，可以存8个数字的出现状态
    - 判断对应数字有没有出现过，要先找到对应的byte，因为一个byte存8个数字，所以要除以8找到byte下标，然后对8取模找到对应bit位置
    - set对应数字，就是把对应byte的对应bit位置1，用或运算
  - 外部排序（分块排序 + k-way 合并）
  - 基于哈希分区（外部哈希分割）

  - 去重手机号也可以使用BIT,只要把手机号映射到BIT的下标就行
    - 比如说手机号是11位数字，可以去掉前三位的固定前缀，然后把后8位数字映射到BIT的下标
    - 这样可以大大减少BIT的大小，同时仍然能够有效地去重手机号


- 如何用Java实现一个简易消息队列？（要求：支持单个topic、单写多消费、最多100条消息，需处理写入速率超过消费速率的问题，暂不考虑持久化）
  - 设计思路
    - 我们需要三个核心角色
      - 生产者
      - 消费者 
      - 消息队列    
    - 数据结构选型
      - BlockingQueue<String> 作为消息存储容器（如 LinkedBlockingQueue）
      - 限制容量为 100；
      - 写入速率超限时    
        - 可选择阻塞生产者（put）；
        - 或丢弃最旧消息再写入。
      - 并发控制
        - Java 的 LinkedBlockingQueue 已经内部实现了锁；
      - 消费逻辑
        - 每个消费者在独立线程中运行；
        - 不停地从队列 take() 消息（阻塞式）；
        - 当消息为空自动等待
  ```java
  import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class MiniMessageQueue {

    // 最大缓存 100 条
    private static final int MAX_CAPACITY = 100;

    // 单 Topic 的消息队列
    private final BlockingQueue<String> queue = new LinkedBlockingQueue<>(MAX_CAPACITY);

    // ========== 生产者接口 ==========
    public void produce(String message) throws InterruptedException {
        // put() 会在队列满时阻塞生产者
        queue.put(message);
        System.out.println("[生产者] 发送消息：" + message);
    }

    // ========== 消费者接口 ==========
    public String consume() throws InterruptedException {
        // take() 会在队列为空时阻塞消费者
        String msg = queue.take();
        System.out.println(Thread.currentThread().getName() + " 消费消息：" + msg);
        return msg;
    }

    // ========== 示例主程序 ==========
    public static void main(String[] args) {
        MiniMessageQueue mq = new MiniMessageQueue();

        // 启动多个消费者
        for (int i = 1; i <= 3; i++) {
            new Thread(() -> {
                try {
                    while (true) {
                        mq.consume();
                        Thread.sleep(500); // 模拟消费速度
                    }
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }, "消费者-" + i).start();
        }

        // 启动生产者
        new Thread(() -> {
            int count = 0;
            try {
                while (true) {
                    mq.produce("消息-" + count++);
                    Thread.sleep(100); // 模拟生产速度
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }, "生产者").start();
    }
}

  ```
  - 为什么选择LinkedBlockingQueue
    - 底层数据结构必须满足：
      - 线程安全
      - 有容量限制
      - 阻塞特性    
    - LinkedBlockingQueue内部使用了 ReentrantLock 实现线程安全，适合多生产者、多消费者并发访问。
    - 提供 put()、take() 方法：队列满时生产者自动阻塞；队列空时消费者自动阻塞   
    - 可设定容量上限：	构造时可传入最大容量（如 100），防止 OOM。
    - 基于链表实现：	插入/删除效率高，适合“生产-消费”模型（频繁进出队列）。
    - 可以控制是否公平锁（FIFO 公平访问）。
    - 自带阻塞机制
    - 与其他候选队列对比
    #image("Screenshot_20251028_170751.png")  


- 用空间复杂度O(1)的方案实现IP地址按点反转（如192.0.1.2反转为2.1.0.192），写出代码并讲解思路。
  - 非O（1）
  ```java
  public class ReverseIP {
    public static String reverseIP(String ip) {
        StringBuilder res = new StringBuilder();
        int i = ip.length() - 1;
        while (i >= 0) {
            int j = i;
            while (j >= 0 && ip.charAt(j) != '.') {
                j--;
            }
            if (res.length() > 0) res.append('.');
            res.append(ip, j+1, i+1);
            i = j - 1;
        }
        return res.toString();
    }

    public static void main(String[] args) {
        String ip = "192.0.1.2";
        System.out.println(reverseIP(ip)); // 输出 2.1.0.192
    }
}

  ```
  - 如果用split会开辟新数组，不满足O（1）
  - 为什么是append i+1
    - 在 Java 里，很多涉及子串的方法都是 左闭右开区间 [start, end)：      
  - O（1）
  ```java
  public class ReverseIPInPlace {   
    // 反转数组 [start, end] 左闭右闭
    private static void reverse(char[] arr, int start, int end) {
        while (start < end) {
            char tmp = arr[start];
            arr[start] = arr[end];
            arr[end] = tmp;
            start++;
            end--;
        }
    }

    public static String reverseIP(String ip) {
        char[] arr = ip.toCharArray();
        int n = arr.length;

        // 1. 反转整个数组
        reverse(arr, 0, n - 1);

        // 2. 逐段反转每个数字段
        int start = 0;
        for (int i = 0; i <= n; i++) {
            if (i == n || arr[i] == '.') {
                reverse(arr, start, i - 1);
                start = i + 1;
            }
        }

        return new String(arr);
    }

    public static void main(String[] args) {
        String ip = "192.0.1.2";
        System.out.println(reverseIP(ip));  // 输出 2.1.0.192

        String ip2 = "192.168.0.1";
        System.out.println(reverseIP(ip2)); // 输出 1.0.168.192
    }
}

  ```
  - 原生 Java 很难做到真正 O(1)
  - Java 的 String 是不可变对象，无法直接在原字符串上修改。
  - 所以在 Java 中 原地修改字符串只能借助 char[]，这在理论上仍算 O(n) 空间。

- 实现全排列的核心方法思路是什么？
  - 思路本质上是 递归 + 回溯
  - 使用 visited 数组
  ```java
  import java.util.*;

public class Permutations1 {
    public List<List<Integer>> permute(int[] nums) {
        List<List<Integer>> result = new ArrayList<>();
        boolean[] visited = new boolean[nums.length];
        backtrack(nums, new ArrayList<>(), visited, result);
        return result;
    }

    private void backtrack(int[] nums, List<Integer> path, boolean[] visited, List<List<Integer>> result) {
        if (path.size() == nums.length) {
            result.add(new ArrayList<>(path));  // 终止条件
            return;
        }

        for (int i = 0; i < nums.length; i++) {
            if (visited[i]) continue;           // 已经选择过的元素跳过
            path.add(nums[i]);
            visited[i] = true;                  // 标记已访问
            backtrack(nums, path, visited, result);
            path.remove(path.size() - 1);       // 回溯
            visited[i] = false;                 // 撤销标记
        }
    }

    public static void main(String[] args) {
        Permutations1 p = new Permutations1();
        int[] nums = {1, 2, 3};
        List<List<Integer>> res = p.permute(nums);
        System.out.println(res);
    }
}

  ```
  - 原地交换
  ```java 
  import java.util.*;

public class Permutations2 {
    public List<List<Integer>> permute(int[] nums) {
        List<List<Integer>> result = new ArrayList<>();
        backtrack(nums, 0, result);
        return result;
    }

    private void backtrack(int[] nums, int start, List<List<Integer>> result) {
        if (start == nums.length) {
            List<Integer> temp = new ArrayList<>();
            for (int num : nums) temp.add(num);
            result.add(temp);
            return;
        }

        for (int i = start; i < nums.length; i++) {
            swap(nums, start, i);          // 交换
            backtrack(nums, start + 1, result);
            swap(nums, start, i);          // 回溯
        }
    }

    private void swap(int[] nums, int i, int j) {
        int t = nums[i];
        nums[i] = nums[j];
        nums[j] = t;
    }

    public static void main(String[] args) {
        Permutations2 p = new Permutations2();
        int[] nums = {1, 2, 3};
        List<List<Integer>> res = p.permute(nums);
        System.out.println(res);
    }
}

  ```
  - 时间复杂度O(n⋅n!)



- 正则表达式匹配字符串
  - a.b → "a+b" "acb"  
    - .表示任意字符
  - \d表示数据
  - \w字母、数字、下划线
  - \s  空格（space）
  - \D \W \S大写即取反
  - \*0次或多次
    - a\* 匹配 "", "aaa"
  - +1次或多次
    - a+ 匹配 "a", "aaa"
  - ?	0或1次
    - colou?r → "color"/"colour"
  - {n}恰好n次
    - \d{4}
  - {n,}至少n次
  -  {n,m}n到m次
  - ^开头
  - \$结尾
  - \b单词边界
  - ()分组


- 手撕一个计算器，输入一个字符串，输出答案，字符串只包含括号和+、-
  ```java  
    public class BasicCalculator {
      public int calculate(String s) {
          int res = 0;      // 当前计算结果
          int num = 0;      // 当前数字
          int sign = 1;     // 当前数字前的符号：1 or -1

          java.util.Stack<Integer> stack = new java.util.Stack<>();

          for (int i = 0; i < s.length(); i++) {
              char ch = s.charAt(i);

              if (Character.isDigit(ch)) {
                  // 处理多位数
                  num = num * 10 + (ch - '0');
              } else if (ch == '+') {
                  // 遇到 +，先把之前的 num 加进去
                  res += sign * num;
                  sign = 1;
                  num = 0;
              } else if (ch == '-') {
                  res += sign * num;
                  sign = -1;
                  num = 0;
              } else if (ch == '(') {
                  // 把当前结果和符号存栈
                  stack.push(res);
                  stack.push(sign);
                  // 重置
                  res = 0;
                  sign = 1;
                  num = 0;
              } else if (ch == ')') {
                  // 先结算括号内的数
                  res += sign * num;
                  num = 0;

                  // 弹出符号，再弹结果
                  int prevSign = stack.pop();
                  int prevRes = stack.pop();
                  res = prevRes + prevSign * res;
              }
              // 空格跳过
          }

          // 最后的数字累加
          res += sign * num;
          return res;
      }

      public static void main(String[] args) {
          BasicCalculator calc = new BasicCalculator();
          System.out.println(calc.calculate("1 + 1"));                      // 2
          System.out.println(calc.calculate(" 2-1 + 2 "));                  // 3
          System.out.println(calc.calculate("(1+(4+5+2)-3)+(6+8)"));        // 23
          System.out.println(calc.calculate("-(3+(2-1))"));                 // -4
          System.out.println(calc.calculate(" -2 "));                       // -2
          System.out.println(calc.calculate("((1))+((2)) - (3 + ( -1))"));  // 1
      }
  }

  ```
    - 当遇到左括号用栈存储括号之前的计算结果
    - 遇到右括号后得到括号内的计算结果，再将栈内的数弹出，也就是括号之前的结果弹出和括号内的计算结果相加