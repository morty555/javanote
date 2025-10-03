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
