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

+ 三树之和
    #image("Screenshot_20250823_170145.png")
    #image("Screenshot_20250823_170132.png")
  - new不能是抽象类，list要记得new arraylist或者别的 反正不能是list
  - Arrays.sort(nums);
  - 这道题的主要思路是
    - 首先排序，这样可以根据三个数的和确定移动方向，减少移动次数
    - 两个指针从开头遍历，假设为i,j，i,j不重合，所以j要初始化成比i大1;
    - 同时在末尾有个指针tail，和j一起移动，如果三数之和大了就tail往前，反之j往后
    - 具体代码实现就是，两层for循环
      - 重点一，遇到重复的跳过，因为答案数组要去重
      - 重点二，tail和j的移动
        - 去前两层循环i，j对应的数之和计算target
        - 比较target和tail对应的值的大小
        - 对于tail要往前移动的情况就while判断target和tail大小进行移动
        - 对于j要向后移的情况就不做处理等待第二层循环自己迭代
        - 因此重点三，tail指针的初始化要在第一层循环中，因为tail和j同时移动，若tail在第二层循环中，则每次移动j都要重复初始化tail计算，但因为我们排序的缘故，这些计算是多余且耗时的