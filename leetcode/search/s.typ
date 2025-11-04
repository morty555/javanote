- 查找插入位置
  #image("Screenshot_20251104_162215.png")
  ```java
  class Solution {
    public int searchInsert(int[] nums, int target) {
         int n = nums.length;
         int left = 0;
         int right = n-1;
         while(left<=right){
             int mid = ((right - left) >> 1) + left-1/2;
            if(target==nums[mid]){
                return mid;
            }
            else if(target>nums[mid]){
                left = mid+1;
            }
            else{
                right = mid-1;
            }
         }
         return left;
    }
 
}
  ```
  - 位运算比除法快
  - 二分查找舍去mid，也就是mid+1和mid-1,那么mid计算时无论加减或不用1/2都是正确的
  - 同时注意left<=right为终止条件，这样跳出条件时left就在插入的位置上
  - 如果是left< right为终止条件，边界条件不好处理


- 搜索二维数组
  #image("Screenshot_20251104_165515.png")
  - 两次二分
    - 先在列二分再在行二分
  - 一次二分查找
  ```java
  class Solution {
    public boolean searchMatrix(int[][] matrix, int target) {
        int n = matrix.length;
        int m = matrix[0].length;
        int left = 0;
        int right = n*m-1;
        while(left<=right){
            int mid = (left+right)/2;
            if(target>matrix[mid/m][mid%m]){
                left = mid+1;
            }
            else if(target <matrix[mid/m][mid%m]){
                right = mid-1;
            }
            else{
                return true;
            }
        }
        return false;
    }
}
  ```
  - 二维矩阵整体升序，可看作是一个n*m的一维数组


- 在排序数组中查找元素的第一个和最后一个位置
  #image("Screenshot_20251104_192929.png")
  ```java
  class Solution {
    public int[] searchRange(int[] nums, int target) {
        int leftIdx = binarySearch(nums, target, true);
        int rightIdx = binarySearch(nums, target, false) - 1;
        if (leftIdx <= rightIdx && rightIdx < nums.length && nums[leftIdx] == target && nums[rightIdx] == target) {
            return new int[]{leftIdx, rightIdx};
        } 
        return new int[]{-1, -1};
    }

    public int binarySearch(int[] nums, int target, boolean lower) {
        int left = 0, right = nums.length - 1, ans = nums.length;
        while (left <= right) {
            int mid = (left + right) / 2;
            if (nums[mid] > target || (lower && nums[mid] >= target)) {
                right = mid - 1;
                ans = mid;
            } else {
                left = mid + 1;
            }
        }
        return ans;
    }
}

  ```
  - 对于最右索引，查找到target< nums[mid]的结果，再减1就是结果
  - 对于最左索引，给一个lower标识，当target<=nums[mid]时，继续向左压缩查找，直到找到最左端


- 搜索旋转排序数组
  #image("Screenshot_20251104_213101.png")
  ```java
  class Solution {
    public int search(int[] nums, int target) {
        int n = nums.length;
        if(n==0){
            return -1;
        }
        if(n==1){
            return target==nums[0]?0:-1;
        }
        int left = 0;
        int right = n-1;
        while(left<=right){
            int mid = (left+right)/2;
            if(nums[mid]==target){
                return mid;
            }
            if(nums[mid]>=nums[0]){
                if(target<nums[mid]&&target>=nums[0]){
                    right=mid-1;
                }
                else{
                    left=mid+1;
                }
            }
            else{
                if(target>nums[mid]&&target<=nums[n-1]){
                    left = mid+1;
                }
                else {
                    right=mid-1;
                }
            }
        }
        return -1;
    }
}
  ```
  - mid选择位置后，一定有一边有顺序一边没顺序，分情况讨论即可
  - 注意边界条件
    - 若在最左端肯定是r左移
    - 若在最右端肯定是l右移
  - (nums[mid]>=nums[0]只能取等于 因为这样算一种情况 若不取在else端就是两种情况