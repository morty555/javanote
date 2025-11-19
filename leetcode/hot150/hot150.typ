- 合并两个有序数组
  #image("Screenshot_20251118_121033.png")
  ```java
  class Solution {
    public void merge(int[] nums1, int m, int[] nums2, int n) {
        int i = m-1;
        int j = n-1;
        int l = m+n-1;
        int cur = 0;
        while(l>=0){
            if(i==-1){
               cur = nums2[j];
               j--;
            }
            else if(j==-1){
                cur = nums1[i];
                i--;
            }
            else if(nums1[i]>nums2[j]){
                cur = nums1[i];
                i--;
            }
            else{
                cur = nums2[j];
                j--;
            }
            nums1[l]=cur;
            l--;
        }
    }
}
  ```
    - 如果从最小开始遍历，会影响nums1的布局，就需要额外空间
    - 但是nums1最大是0无影响，所以可以从最大开始遍历，不需要额外数组空间
    

- 移除元素
  - 双指针碰撞
  ```java     
 class Solution {
    public int removeElement(int[] nums, int val) {
        int n = nums.length;
        //右指针
        int k = n-1;
        for(int i=0;i<=k;i++){
            //如果左指针的值等于val就交换到最后，同时右指针--，因为已经找到一个等于val的元素
            while(nums[i]==val&&k>=i){
                nums[i]=nums[k];
                k--;
            }
        }
        //最后k的位置就是不等于val的数的末尾
        return k+1;
    }
}
}
  ```

- 删除有序数组中的重复项
  - 快慢指针法
  ```java
  class Solution {
    public int removeDuplicates(int[] nums) {
        int n = nums.length;
        if (n == 0) {
            return 0;
        }
        int fast = 1, slow = 1;
        while (fast < n) {
            if (nums[fast] != nums[fast - 1]) {
                nums[slow] = nums[fast];
                ++slow;
            }
            ++fast;
        }
        return slow;
    }
} 
  ```


- 轮转数组
  - 三次交换法
  ```java
  class Solution {
    public void rotate(int[] nums, int k) {
        int n = nums.length;
        k = k % n;
        reverse(nums, 0, n - 1);
        reverse(nums, 0, k - 1);
        reverse(nums, k, n - 1);
    }

    private void reverse(int[] nums, int l, int r) {
        while (l < r) {
            int t = nums[l];
            nums[l] = nums[r];
            nums[r] = t;
            l++;
            r--;
        }
    }
}  
  ```


- 删除有序数组中的重复项 II
  #image("Screenshot_20251119_115825.png")
  ```java
  class Solution {
    public int removeDuplicates(int[] nums) {
        int n = nums.length;
        if(n<2){
            return n;
        }
        int fast = 2;
        int slow = 2;
        while(fast<n){
            if(nums[slow-2]!=nums[fast]){
                nums[slow] = nums[fast];
                slow++;
            }
            fast++;
        }
        return slow;
    }
}
  ```
    - 因为可以保存两个相同的元素
    - 所以前两个不用管
    - 每次快慢指针比较slow-2和fast是否相等
    - 为什么是slow-2？
      - 因为允许两个相同的元素存在，那么如果slow-2和slow-1相同，slow位置肯定需要赋值新元素
      - 即使slow-2和slow-1不相同，那slow也可以和slow-1相同，所以也只需要判断slow-2
      - fast在和slow-2相同的时候只要一直前移找到不相同的第一个数就可以赋值了
      - 由于可以允许两次，slow赋值之后，slow-2的值和slow本身不相同，因此即使fast的下一个值和slow相同，也可以赋值，这就满足了两次相同元素的要求


- 多数元素
  #image("Screenshot_20251119_121147.png")
  - 哈希表
  ```java
   class Solution {
    private Map<Integer, Integer> countNums(int[] nums) {
        Map<Integer, Integer> counts = new HashMap<Integer, Integer>();
        for (int num : nums) {
            if (!counts.containsKey(num)) {
                counts.put(num, 1);
            } else {
                counts.put(num, counts.get(num) + 1);
            }
        }
        return counts;
    }

    public int majorityElement(int[] nums) {
        Map<Integer, Integer> counts = countNums(nums);

        Map.Entry<Integer, Integer> majorityEntry = null;
        for (Map.Entry<Integer, Integer> entry : counts.entrySet()) {
            if (majorityEntry == null || entry.getValue() > majorityEntry.getValue()) {
                majorityEntry = entry;
            }
        }

        return majorityEntry.getKey();
    }
}

  ```
  - 排序 
  ```java
  class Solution {
    public int majorityElement(int[] nums) {
        Arrays.sort(nums);
        return nums[nums.length / 2];
    }
}

  ```
  - 随机化
  - 分治
  - Boyer-Moore 投票算法
  ```java
  class Solution {
    public int majorityElement(int[] nums) {
        int count = 0;
        Integer candidate = null;

        for (int num : nums) {
            if (count == 0) {
                candidate = num;
            }
            count += (num == candidate) ? 1 : -1;
        }

        return candidate;
    }
}
  ```