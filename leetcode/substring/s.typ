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
  - 那k就在当前i所在位置的前缀和pre-（pre-k）;
  
  