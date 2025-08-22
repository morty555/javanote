+ 移动零
  #image("Screenshot_20250821_215231.png")
  - 双指针
  ```java
  class Solution {
    public void moveZeroes(int[] nums) {
        int n = nums.length, left = 0, right = 0;
        while (right < n) {
            if (nums[right] != 0) {
                swap(nums, left, right);
                left++;
            }
            right++;
        }
    }

    public void swap(int[] nums, int left, int right) {
        int temp = nums[left];
        nums[left] = nums[right];
        nums[right] = temp;
    }
}


  ```
    - 其实就是从左往右，遇到0就把0和下一个非0数字交换，
  - 覆盖法
    ```java
    class Solution {
    public void moveZeroes(int[] nums) {
        int n = nums.length;
        // 指向当前已处理的非零元素的末尾
        int left = 0; 

        // 第一次遍历：将所有非零元素移到左侧
        for (int i = 0; i < n; i++) {
            if (nums[i] != 0) {
                nums[left] = nums[i];
                left++;
            }
        }

        // 第二次遍历：将剩余位置填充为 0
        for (int i = left; i < n; i++) {
            nums[i] = 0;
        }
    }
}
    ```
      - 先将非零数按遍历顺序写在左边，右边补0
+ 盛最多水的容器
  #image("Screenshot_20250822_224334.png")
  - 比较左右高度，小的移进
  - 每次记录下面积，取最大值