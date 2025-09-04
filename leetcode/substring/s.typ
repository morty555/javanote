+ 和为 K 的子数组
#image("Screenshot_20250902_100930.png")


  - 双for循环枚举
  ```java
  public class Solution {
    public int subarraySum(int[] nums, int k) {
        int count = 0;
        for (int start = 0; start < nums.length; ++start) {
            int sum = 0;
            for (int end = start; end >= 0; --end) {
                sum += nums[end];
                if (sum == k) {
                    count++;
                }
            }
        }
        return count;
    }
}
  ```
   - 前缀和+哈希表优化
    - ```java
    class Solution {
    public int subarraySum(int[] nums, int k) {
        int count = 0;
        int pre = 0;
        Map<Integer,Integer> map = new HashMap<>();
        map.put(0,1);
        for(int i = 0;i<nums.length;i++){
            pre = pre + nums[i];
            if(map.containsKey(pre-k)){
                count = count + map.get(pre-k);
            }
            map.put(pre,map.getOrDefault(pre,0)+1);

        }
        return count;
    }


}
```

  - 注意map的初始化和相关函数
  - 主要是将找k转换成找pre-k 因为pre-k是另外一个数的前缀和
  - 那k就在当前i所在位置的前缀和p
  
- 滑动窗口最大值
  - #image("Screenshot_20250903_195932.png")
  - 优先队列
    - 新建优先队列
    - 先将前k个数以及索引放入优先队列，放索引是为了后续比较是否超过窗口范围
    - 再对后n-k个数遍历放入
    - 每次判断最大值所在索引是否超过窗口范围，超过则poll,注意，不是每次移动窗口都要poll,而是每次只peek最大值的索引，while判断最大值是否超过窗口范围，所以可能一个都没poll,可能一次poll几个
    - 再将去除超过范围后的优先队列的最大值放入ans
    ```java
    class Solution {
    public int[] maxSlidingWindow(int[] nums, int k) {
        int n = nums.length;
        PriorityQueue<int[]> pq = new PriorityQueue<int[]>(new Comparator<int[]>() {
            public int compare(int[] pair1, int[] pair2) {
                return pair1[0] != pair2[0] ? pair2[0] - pair1[0] : pair2[1] - pair1[1];
            }
        });
        for (int i = 0; i < k; ++i) {
            pq.offer(new int[]{nums[i], i});
        }
        int[] ans = new int[n - k + 1];
        ans[0] = pq.peek()[0];
        for (int i = k; i < n; ++i) {
            pq.offer(new int[]{nums[i], i});
            while (pq.peek()[1] <= i - k) {
                pq.poll();
            }
            ans[i - k + 1] = pq.peek()[0];
        }
        return ans;
    }
}

    ```
    - 单调队列



- 最小覆盖子串
  #image("Screenshot_20250904_103909.png")
  ```java
  class Solution {
    Map<Character, Integer> ori = new HashMap<Character, Integer>();
    Map<Character, Integer> cnt = new HashMap<Character, Integer>();

    public String minWindow(String s, String t) {
        int tLen = t.length();
        for (int i = 0; i < tLen; i++) {
            char c = t.charAt(i);
            ori.put(c, ori.getOrDefault(c, 0) + 1);
        }
        int l = 0, r = -1;
        int len = Integer.MAX_VALUE, ansL = -1, ansR = -1;
        int sLen = s.length();
        while (r < sLen) {
            ++r;
            if (r < sLen && ori.containsKey(s.charAt(r))) {
                cnt.put(s.charAt(r), cnt.getOrDefault(s.charAt(r), 0) + 1);
            }
            while (check() && l <= r) {
                if (r - l + 1 < len) {
                    len = r - l + 1;
                    ansL = l;
                    ansR = l + len;
                }
                if (ori.containsKey(s.charAt(l))) {
                    cnt.put(s.charAt(l), cnt.getOrDefault(s.charAt(l), 0) - 1);
                }
                ++l;
            }
        }
        return ansL == -1 ? "" : s.substring(ansL, ansR);
    }

    public boolean check() {
        Iterator iter = ori.entrySet().iterator(); 
        while (iter.hasNext()) { 
            Map.Entry entry = (Map.Entry) iter.next(); 
            Character key = (Character) entry.getKey(); 
            Integer val = (Integer) entry.getValue(); 
            if (cnt.getOrDefault(key, 0) < val) {
                return false;
            }
        } 
        return true;
    }
}

  ```
  - check函数有问题
  - 双哈希表记录目标串和滑动窗口内的字符和频率
  - 先初始化目标串的哈希表
  - 然后从子串最左端开始，移动窗口右端，直到找到符合目标串的子串（判断条件就是看子串哈希表每个字符的频率是否大于等于目标串的频率）
  - 然后while循环将窗口左端向右移动，判断子串哈希表的频率是否大于滑动窗口的频率，直到子串频率大于滑动窗口停止，此时子串最短
  