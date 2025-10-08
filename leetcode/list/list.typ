- 相交链表
  #image("Screenshot_20251003_153810.png")
  - 哈希表
  - 双指针
    ```java
    public class Solution {
    public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
        if (headA == null || headB == null) {
            return null;
        }
        ListNode pA = headA, pB = headB;
        while (pA != pB) {
            pA = pA == null ? headB : pA.next;
            pB = pB == null ? headA : pB.next;
        }
        return pA;
    }
}

    ```
    - 其实就是保证两个指针走过的路程相同，下面的c为公共部分，a,b为各自独有部分
      - 链表A长度为a+c
      - 链表B长度为b+c
      - 如果A,B有交点，那么a+c+b = b+c+a
      - 如果A,B无交点，那么a+b = b+a
    - 为什么while里的判断是 pA = pA == null ? headB : pA.next;而不能是 pA = pA.next == null ? headB : pA.next;
      - 如果是后者，若两个链表无交点，因为pa和pb都走不到null，所以会死循环
- 反转链表
  #image("Screenshot_20251003_155106.png")
  - 迭代
  ```java
  class Solution {
    public ListNode reverseList(ListNode head) {
         ListNode pre = null;
         ListNode curr = head;
         while(curr!=null){
            ListNode next = curr.next;
            curr.next = pre;
            pre = curr;
            curr = next;
         }
         return pre;
    }
}
  ```
    - 不断地将当前节点的next指向前一个节点，然后前一个节点和当前节点都向后移动一位
    - pre一开始为null，因为反转后原来的头节点会变成尾节点，尾节点的next为null
  - 递归
  ```java
  class Solution {
    public ListNode reverseList(ListNode head) {
         if(head==null||head.next==null){
            return head;
         }
         ListNode newhead = reverseList(head.next);
         head.next.next =  head;
         head.next=null;
         return newhead;
    }
}
  ```
    - newhead保存最后一个节点，因为到最后一个节点的next为null，所以newhead会一直返回最后一个节点
    - 要将head.next=null,防止链表成环，因为递归到最后一个节点时，head.next.next = head会让最后一个节点指向倒数第二个节点，若不设置head.next=null,倒数第二个节点的next还是指向最后一个节点，会成环
- 回文链表
  #image("Screenshot_20251003_163306.png")
  - 复制到数组
  - 递归
    - 递归到链表的最后一个节点，然后在回溯的过程中比较前后节点
  - 快慢指针 + 反转后半部分链表
    ```java
    class Solution {
    public boolean isPalindrome(ListNode head) {
        if (head == null) {
            return true;
        }

        // 找到前半部分链表的尾节点并反转后半部分链表
        ListNode firstHalfEnd = endOfFirstHalf(head);
        ListNode secondHalfStart = reverseList(firstHalfEnd.next);

        // 判断是否回文
        ListNode p1 = head;
        ListNode p2 = secondHalfStart;
        boolean result = true;
        while (result && p2 != null) {
            if (p1.val != p2.val) {
                result = false;
            }
            p1 = p1.next;
            p2 = p2.next;
        }

        // 还原链表并返回结果
        firstHalfEnd.next = reverseList(secondHalfStart);
        return result;
    }

    private ListNode reverseList(ListNode head) {
        ListNode prev = null;
        ListNode curr = head;
        while (curr != null) {
            ListNode nextTemp = curr.next;
            curr.next = prev;
            prev = curr;
            curr = nextTemp;
        }
        return prev;
    }

    private ListNode endOfFirstHalf(ListNode head) {
        ListNode fast = head;
        ListNode slow = head;
        while (fast.next != null && fast.next.next != null) {
            fast = fast.next.next;
            slow = slow.next;
        }
        return slow;
    }
}

    ```
    - 快慢指针找中间位置，反转后半部分链表，然后比较前半部分和后半部分
    - 在快慢指针的while循环中，要先判断fast.next是否为null，再判断fast.next.next是否为null，否则会空指针异常
    - 反转后半部分链表时，若链表长度为奇数，slow指向中间节点，反转后中间节点会变成后半部分链表的头节点
    - 判断是否回文时，只需要判断后半部分链表是否遍历完，因为后半部分链表长度小于等于前半部分链表长度
    - 如需要在结束时将链表反转回去，则需要保留第一次反转后的头节点
    - 注意head为null的情况
- 环形链表
  #image("Screenshot_20251003_165113.png")
  - 哈希表
  - 快慢指针
    ```java
    public class Solution {
    public boolean hasCycle(ListNode head) {
        if (head == null || head.next == null) {
            return false;
        }
        ListNode slow = head;
        ListNode fast = head.next;
        while (slow != fast) {
            if (fast == null || fast.next == null) {
                return false;
            }
            slow = slow.next;
            fast = fast.next.next;
        }
        return true;
    }
}

    ```
    - 快慢指针的思想就是，如果链表有环，那么快指针一定会追上慢指针
    - 初始化slow和fast不要初始在同一个位置，会跳过while循环
    - 对head和head.next要判断，针对空链表和只有一个节点的链表
    - 在while循环中，要先判断fast和fast.next是否为null，否则会空指针异常
- 环形链表2
  #image("Screenshot_20251004_230132.png")
  - 相比于环形链表，需要找到环的交点处
  ```java
  public class Solution {
    public ListNode detectCycle(ListNode head) {
        if (head == null) {
            return null;
        }
        ListNode slow = head, fast = head;
        while (fast != null) {
            slow = slow.next;
            if (fast.next != null) {
                fast = fast.next.next;
            } else {
                return null;
            }
            if (fast == slow) {
                ListNode ptr = head;
                while (ptr != slow) {
                    ptr = ptr.next;
                    slow = slow.next;
                }
                return ptr;
            }
        }
        return null;
    }
}

  ```
  - 找到的思路和环形链表相似，利用快慢指针找到，但是这里同时从head开始，因为后续查找环交点需要快慢指针的路径关系
  - 因为同起点，快指针是慢指针路径的两倍
  #image("Screenshot_20251004_230343.png")
  - 我们假设慢指针走了a+b的路径长，那么因为环形存在，快指针一定也走了a+b+n个环长也就是 a+n(b+c)+b=a+(n+1)b+nc。
  - 又因为两倍关系 有 a+(n+1)b+nc=2(a+b)⟹a=c+(n−1)(b+c)
  - 因此我们可以知道头节点到环节点的距离，就是快慢指针交汇处到环节点再走n-1个环长
  - 也就是说，在快慢指针交汇处，我们用一个节点引用头节点的话，这个节点到环交点的时候，慢节点就也刚好到环节点，因此根据慢指针是否与该指针对应节点相同找到环交点

- 合并有序数组
  #image("Screenshot_20251005_211109.png")
  - 递归
    ```java
    class Solution {
        public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
            if (l1 == null) {
                return l2;
            } else if (l2 == null) {
                return l1;
            } else if (l1.val < l2.val) {
                l1.next = mergeTwoLists(l1.next, l2);
                return l1;
            } else {
                l2.next = mergeTwoLists(l1, l2.next);
                return l2;
            }
        }
    }

    ```
    - 每次只找一个最小节点，然后将两个链表剩下的递归
  - 迭代
    ```java
    class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        ListNode prehead = new ListNode(-1);

        ListNode prev = prehead;
        while (l1 != null && l2 != null) {
            if (l1.val <= l2.val) {
                prev.next = l1;
                l1 = l1.next;
            } else {
                prev.next = l2;
                l2 = l2.next;
            }
            prev = prev.next;
        }

        // 合并后 l1 和 l2 最多只有一个还未被合并完，我们直接将链表末尾指向未合并完的链表即可
        prev.next = l1 == null ? l2 : l1;

        return prehead.next;
    }
}
    ```
    - 创建一个前驱节点方便第一次遍历的时候插入和后续头节点查找
    - 每次只比较两个链表的第一个元素，谁小就插入到prev的后面，直到一个链表处理完，再把剩余链表接到prev后
    
- 两数相加
  #image("Screenshot_20251006_151846.png")
  ```java
  class Solution {
    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        ListNode head = null, tail = null;
        int carry = 0;
        while (l1 != null || l2 != null) {
            int n1 = l1 != null ? l1.val : 0;
            int n2 = l2 != null ? l2.val : 0;
            int sum = n1 + n2 + carry;
            if (head == null) {
                head = tail = new ListNode(sum % 10);
            } else {
                tail.next = new ListNode(sum % 10);
                tail = tail.next;
            }
            carry = sum / 10;
            if (l1 != null) {
                l1 = l1.next;
            }
            if (l2 != null) {
                l2 = l2.next;
            }
        }
        if (carry > 0) {
            tail.next = new ListNode(carry);
        }
        return head;
    }
}


  ```
  - 建立一个新链表存储结果数据
  - 先预设头尾节点为null,
  - 若头节点为空则初始化头尾节点，若不为空则尾节点后移
  - 尾节点后移的数据由n1+n2+carry得到
  - 注意sum%10
  - 注意每次相加完要将l1,l2后移
  - 因为长短不一，所以前面赋值操作用三目运算符，若为空则取0,不为空则取val
  - 注意最后一位相加若产生进位，需要 tail.next = new ListNode(carry);而且注意这个要在while外面，因为在最后才会产生这个问题，若放在里面会有常数空间的进位节点浪费

- 删除链表的倒数第 N 个结点
  #image("Screenshot_20251006_160831.png")
  - 顺序遍历
  - 栈
  - 双指针遍历
  ```java 
class Solution {
    public ListNode removeNthFromEnd(ListNode head, int n) {
        ListNode dummy = new ListNode(0, head);
        ListNode first = head;
        ListNode second = dummy;
        for (int i = 0; i < n; ++i) {
            first = first.next;
        }
        while (first != null) {
            first = first.next;
            second = second.next;
        }
        second.next = second.next.next;
        ListNode ans = dummy.next;
        return ans;
    }
}


  ```
  - 哑节点的必要性：如果head被删除，没有哑节点就无法返回删除head后的节点
  - 慢指针为什么要在哑节点而不是head：若慢指针在head,当快指针遍历到末尾时慢指针到倒数第n个节点，但是我们要删除它，无法返回到上一个节点改变指针指向
  - 为什么不能在while循环里遍历到n+1：这个快指针先移动是为了保证快慢指针相距距离为n,这样当快指针到末尾的时候慢指针就是倒数第n个节点，但是如果链表长度和n相同，如果遍历到n+1会发生空指针问题

- 两两交换链表中的节点
  #image("Screenshot_20251006_233758.png")
  - 递归
    - 从最后开始交换
    - 若最后一组节点只有一个则不变，因此需要判断当前节点或者当前节点的下一个为空就返回当前节点
      - 如果为偶数，则到最后当前节点为null,返回null,上一组节点也就是链表的末尾指向null
      - 若为奇数，当前节点的下一个节点为null,则返回当前节点，链表前面的节点两两交换，最后一组指向最后一个节点即当前节点
    - 然后在swap函数后进行交换逻辑
    ```java
    class Solution {
    public ListNode swapPairs(ListNode head) {
          if(head==null||head.next==null){
            return head;
          }
          ListNode nextnode = head.next;
          head.next = swapPairs(nextnode.next);
          nextnode.next = head;
          return nextnode;
    }
} 
    ```
  - 迭代
    ```java
    class Solution {
    public ListNode swapPairs(ListNode head) {
        ListNode dummyHead = new ListNode(0);
        dummyHead.next = head;
        ListNode temp = dummyHead;
        while (temp.next != null && temp.next.next != null) {
            ListNode node1 = temp.next;
            ListNode node2 = temp.next.next;
            temp.next = node2;
            node1.next = node2.next;
            node2.next = node1;
            temp = node1;
        }
        return dummyHead.next;
    }
}

    ```
    - 新建一个哑节点作为链表的前驱节点方便找到头节点，因为head已经被移动
    - 用temp来循环，temp为要反转的两个节点组的前一个节点，while条件为这两个节点都不为空，因为若一个是空，则意味着该节点组只有一个节点，也就是最后一个节点组，不用替换，两个节点都不为空则要替换
    - 替换过程记得要更新temp到该节点组的最后一个节点，也就是下一个节点组的前一个节点


- K 个一组翻转链表
  #image("Screenshot_20251007_112641.png")
  ```java
  class Solution {
    public ListNode reverseKGroup(ListNode head, int k) {
        ListNode hair = new ListNode(0);
        hair.next = head;
        ListNode pre = hair;

        while (head != null) {
            ListNode tail = pre;
            // 查看剩余部分长度是否大于等于 k
            for (int i = 0; i < k; ++i) {
                tail = tail.next;
                if (tail == null) {
                    return hair.next;
                }
            }
            ListNode nex = tail.next;
            ListNode[] reverse = myReverse(head, tail);
            head = reverse[0];
            tail = reverse[1];
            // 把子链表重新接回原链表
            pre.next = head;
            tail.next = nex;
            pre = tail;
            head = tail.next;
        }

        return hair.next;
    }

    public ListNode[] myReverse(ListNode head, ListNode tail) {
        ListNode prev = tail.next;
        ListNode p = head;
        while (prev != tail) {
            ListNode nex = p.next;
            p.next = prev;
            prev = p;
            p = nex;
        }
        return new ListNode[]{tail, head};
    }
}

  ```
  - 定义哑节点方便找到头节点，因为头节点head要旋转
  - 将tail每次放置在每组的最后一个，这样刚好在下一组的前一个节点，这样向后遍历k个就知道后面是否有k个元素的一组，若遍历到节点为空则返回头节点，因为已经是最后一组并且最后一组不满k个不用旋转
  - 将head和tail作为参数传入旋转函数
  - 因为旋转记录不了前置节点，因此要在旋转函数外也就是主函数记录前置节点，前置节点一开始在哑节点，往后每次都在每组的尾节点也就是下一组的前一个节点
  - 在函数内，要记录后置节点，因为旋转需要改变后置节点位置
  - 然后开始旋转，旋转逻辑是，每次把当前节点指向后置节点，要记得更新函数内后置节点和当前节点
  - 举例 head->1->2->3->tail  此时记录后置节点tail,当前节点1,因为要把1插到tail的前面
  - 第一次旋转
    - 1->tail
    - 2->3->tail
    - 此时记录后置节点1,当前节点2,因为要把2插到1的前面
  - 第二次旋转
    - 2->1->tail
    - 3->tail
  - 第三次旋转
    - 3->2->1->tail
  - 因为我们无法直接得到当前节点，所以要在每次旋转前记录下curr.next为下一次的当前节点，在旋转后赋值给curr
  - 旋转后，再将主函数记录下的前置节点的next接到新的head上
  - 然后同步更新指针新的位置
  - 直到head==null到达链表最后或者最后一组不满k个返回头节点

- 随机链表的复制
  #image("Screenshot_20251008_200121.png")
  - 回溯+哈希表
    ```java
    class Solution {
    Map<Node, Node> cachedNode = new HashMap<Node, Node>();

    public Node copyRandomList(Node head) {
        if (head == null) {
            return null;
        }
        if (!cachedNode.containsKey(head)) {
            Node headNew = new Node(head.val);
            cachedNode.put(head, headNew);
            headNew.next = copyRandomList(head.next);
            headNew.random = copyRandomList(head.random);
        }
        return cachedNode.get(head);
    }
}

    ```
    - 全局哈希表存储已经new的节点，防止循环依赖
    - 每次先判断哈希表中是否已经存在原链表节点的复制节点，若不存在则new一个，若存在则直接从哈希表返回
    - new完节点后要放入哈希表，同时更新next和random,但是因为可能next和random还没更新，这里用回溯的思想，先找head.next是否存在拷贝节点，若存在则直接返回，不存在则创建

  - 迭代 + 节点拆分
    ```java
    class Solution {
    public Node copyRandomList(Node head) {
        if (head == null) {
            return null;
        }
        for (Node node = head; node != null; node = node.next.next) {
            Node nodeNew = new Node(node.val);
            nodeNew.next = node.next;
            node.next = nodeNew;
        }
        for (Node node = head; node != null; node = node.next.next) {
            Node nodeNew = node.next;
            nodeNew.random = (node.random != null) ? node.random.next : null;
        }
        Node headNew = head.next;
        for (Node node = head; node != null; node = node.next) {
            Node nodeNew = node.next;
            node.next = node.next.next;
            nodeNew.next = (nodeNew.next != null) ? nodeNew.next.next : null;
        }
        return headNew;
    }
}

    ```
    - 法二其实是省去哈希表
    - 将原链表顺序拷贝，并让原节点指向新节点，例如对于链表 A→B→C，我们可以将其拆分为 A→A′→B→B′→C→C′。
    - 这样在找newnode的random时，就可以直接找原node的random.next
    - 找newnode的next时，就直接找newnode.next.next
    - 这个方法关键是第一步的节点拆分，使得所有拷贝节点都被初始化完成并且间接记录了原节点的值



-  排序链表
  - 自顶向下归并排序
    ```java
    class Solution {
        public ListNode sortList(ListNode head) {
            return sortList(head, null);
        }

        public ListNode sortList(ListNode head, ListNode tail) {
            if (head == null) {
                return head;
            }
            if (head.next == tail) {
                head.next = null;
                return head;
            }
            ListNode slow = head, fast = head;
            while (fast != tail) {
                slow = slow.next;
                fast = fast.next;
                if (fast != tail) {
                    fast = fast.next;
                }
            }
            ListNode mid = slow;
            ListNode list1 = sortList(head, mid);
            ListNode list2 = sortList(mid, tail);
            ListNode sorted = merge(list1, list2);
            return sorted;
        }

        public ListNode merge(ListNode head1, ListNode head2) {
            ListNode dummyHead = new ListNode(0);
            ListNode temp = dummyHead, temp1 = head1, temp2 = head2;
            while (temp1 != null && temp2 != null) {
                if (temp1.val <= temp2.val) {
                    temp.next = temp1;
                    temp1 = temp1.next;
                } else {
                    temp.next = temp2;
                    temp2 = temp2.next;
                }
                temp = temp.next;
            }
            if (temp1 != null) {
                temp.next = temp1;
            } else if (temp2 != null) {
                temp.next = temp2;
            }
            return dummyHead.next;
        }
    }

    ```
    - 利用归并排序的思想，每次对半分治
    - 利用快慢指针找到中间位置
    - 判断头节点next是否是尾节点，处理只有两个节点一组的情况，直接返回头节点并让head.next=null,目的是断开两节点关系，分治成最后一个单独节点
    - 然后将分治的两个list合并
    - 合并的思路是，设置哑节点，设置前置索引在哑节点，每次比较list1和list2的val的大小，小的就接在哑节点后面，然后将前置索引和小的节点的索引向后移，直到遍历完一个链表，剩下的链表直接接在前置索引的next就好
    - 返回哑节点的next

  - 自底向上排序
    ```java
    class Solution {
    public ListNode sortList(ListNode head) {
        if (head == null) {
            return head;
        }
        int length = 0;
        ListNode node = head;
        while (node != null) {
            length++;
            node = node.next;
        }
        ListNode dummyHead = new ListNode(0, head);
        for (int subLength = 1; subLength < length; subLength <<= 1) {
            ListNode prev = dummyHead, curr = dummyHead.next;
            while (curr != null) {
                ListNode head1 = curr;
                for (int i = 1; i < subLength && curr.next != null; i++) {
                    curr = curr.next;
                }
                ListNode head2 = curr.next;
                curr.next = null;
                curr = head2;
                for (int i = 1; i < subLength && curr != null && curr.next != null; i++) {
                    curr = curr.next;
                }
                ListNode next = null;
                if (curr != null) {
                    next = curr.next;
                    curr.next = null;
                }
                ListNode merged = merge(head1, head2);
                prev.next = merged;
                while (prev.next != null) {
                    prev = prev.next;
                }
                curr = next;
            }
        }
        return dummyHead.next;
    }

    public ListNode merge(ListNode head1, ListNode head2) {
        ListNode dummyHead = new ListNode(0);
        ListNode temp = dummyHead, temp1 = head1, temp2 = head2;
        while (temp1 != null && temp2 != null) {
            if (temp1.val <= temp2.val) {
                temp.next = temp1;
                temp1 = temp1.next;
            } else {
                temp.next = temp2;
                temp2 = temp2.next;
            }
            temp = temp.next;
        }
        if (temp1 != null) {
            temp.next = temp1;
        } else if (temp2 != null) {
            temp.next = temp2;
        }
        return dummyHead.next;
    }
}

    ```

    - 直接将原链表拆分成小段排序
    - 需要计算总长度来拆分小段
    - 哑节点
    - for循环遍历链表，每次按小段排序，小段范围从1上升到sublength也就是小段的最大长度为止
    - 在for循环里，对每两个小段进行一次sort,记录一个curr节点，不断往后移动，每次移动一个小段长度就记录一个头，并且断开小段与小段之间的联系
    - 每两段merge一次，返回merge后的链表的头节点，插入到pre后
    - 也就是每两组链表排序后合并成一个链表后接到pre后
    - 记住while循环，因为一条链表中，当小段长度小的时候，一条链表会有很多个小段，但是我们每次只处理两个小段的merge,因此要whlie判断curr是否到达tail