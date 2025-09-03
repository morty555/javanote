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
  