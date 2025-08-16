+ 哈希
  - 两数之和
    #image("Screenshot_20250816_220007.png")
    - 枚举
    - 哈希
      - 由于我们要得到的是数组索引，而hashmap只有getkey,所以我们可以以nums[i]作为key找i
      - 将put操作放到比较后，这样可保证不选择重复元素，因为每次都是从后往前找，而此时的nums[i]还不在hashmap中
    ```java
      class Solution {
        public int[] twoSum(int[] nums, int target) {
            Map<Integer, Integer> hashtable = new HashMap<Integer, Integer>();
            for (int i = 0; i < nums.length; ++i) {
                if (hashtable.containsKey(target - nums[i])) {
                    return new int[]{hashtable.get(target - nums[i]), i};
                }
                hashtable.put(nums[i], i);
            }
            return new int[0];
        }
    }

    ```
  - 字母异位词分组
  