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
    