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


- 寻找旋转排序数组中的最小值
  #image("Screenshot_20251105_111712.png")
  ```java
  class Solution {
    public int findMin(int[] nums) {
        int n  = nums.length;
        int left = 0;
        int right = n-1;
        while(left<right){
            int mid = (left+right)/2;
            if(nums[mid]<=nums[right]){
                right = mid;
            }
            else{
                left = mid+1;
            }
        }
        return nums[left];
    }
}

  ```
  ```java
  class Solution {
    public int findMin(int[] nums) {
        int n  = nums.length;
        int left = 0;
        int right = n-1;
        while(left<=right){
            int mid = (left+right)/2;
            if(nums[mid]<nums[right]){
                right = mid;
            }
            else{
                left = mid+1;
            }
        }
        return nums[left-1];
    }
}
  ```
  - 这道题的临界条件和之前的二分查找不一样
  - 若取right=mid-1,那么当mid刚好是最小值的时候会直接跳过答案，因此只能是right=mid；
  - while的终止条件看情况left=right，因为如果if条件是nums[mid]<=nums[right]，left=right会陷入死循环，right一直在mid不会跳出while
  - 如果if条件是nums[mid]< nums[right]，那当left和right交汇在mid时，left会往前一格，返回答案就要是nums[left-1];


- 寻找两个正序数组的中位数
  ```java
  class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        int length1 = nums1.length, length2 = nums2.length;
        int totalLength = length1 + length2;
        if (totalLength % 2 == 1) {
            int midIndex = totalLength / 2;
            double median = getKthElement(nums1, nums2, midIndex + 1);
            return median;
        } else {
            int midIndex1 = totalLength / 2 - 1, midIndex2 = totalLength / 2;
            double median = (getKthElement(nums1, nums2, midIndex1 + 1) + getKthElement(nums1, nums2, midIndex2 + 1)) / 2.0;
            return median;
        }
    }

    public int getKthElement(int[] nums1, int[] nums2, int k) {
        /* 主要思路：要找到第 k (k>1) 小的元素，那么就取 pivot1 = nums1[k/2-1] 和 pivot2 = nums2[k/2-1] 进行比较
         * 这里的 "/" 表示整除
         * nums1 中小于等于 pivot1 的元素有 nums1[0 .. k/2-2] 共计 k/2-1 个
         * nums2 中小于等于 pivot2 的元素有 nums2[0 .. k/2-2] 共计 k/2-1 个
         * 取 pivot = min(pivot1, pivot2)，两个数组中小于等于 pivot 的元素共计不会超过 (k/2-1) + (k/2-1) <= k-2 个
         * 这样 pivot 本身最大也只能是第 k-1 小的元素
         * 如果 pivot = pivot1，那么 nums1[0 .. k/2-1] 都不可能是第 k 小的元素。把这些元素全部 "删除"，剩下的作为新的 nums1 数组
         * 如果 pivot = pivot2，那么 nums2[0 .. k/2-1] 都不可能是第 k 小的元素。把这些元素全部 "删除"，剩下的作为新的 nums2 数组
         * 由于我们 "删除" 了一些元素（这些元素都比第 k 小的元素要小），因此需要修改 k 的值，减去删除的数的个数
         */

        int length1 = nums1.length, length2 = nums2.length;
        int index1 = 0, index2 = 0;
        int kthElement = 0;

        while (true) {
            // 边界情况
            if (index1 == length1) {
                return nums2[index2 + k - 1];
            }
            if (index2 == length2) {
                return nums1[index1 + k - 1];
            }
            if (k == 1) {
                return Math.min(nums1[index1], nums2[index2]);
            }
            
            // 正常情况
            int half = k / 2;
            int newIndex1 = Math.min(index1 + half, length1) - 1;
            int newIndex2 = Math.min(index2 + half, length2) - 1;
            int pivot1 = nums1[newIndex1], pivot2 = nums2[newIndex2];
            if (pivot1 <= pivot2) {
                k -= (newIndex1 - index1 + 1);
                index1 = newIndex1 + 1;
            } else {
                k -= (newIndex2 - index2 + 1);
                index2 = newIndex2 + 1;
            }
        }
    }
}


  ```
  - 两个数组的中位数有可能是两数的平均和，可能是一个数，因此要在一开始if判断
  - 那问题就变成了在两个数组中找第k大的数，如果是平均和就是找两个第k和第k+1大的数求平均和
  - 找第k个数逻辑
    - 每次排查k/2个数
    - 对两个数组的索引为k/2位置进行对比，将小的那一方前k/2个数全部删去（在算法中直接移动index就好），因为他们不可能是结果
    - 更新k为排除元素后的k,即k = k-（newindex-index+1）
    - 注意每次计算newindex时要和length做对比，因为可能越界
    - 如果一个数组已经取完，那么结果肯定在另外一个数组上，鉴于之前已经排查的元素，只要在剩下数组的index上再前进剩下k个位置即可。
    - 因为k代表的是第k个元素，因此换算成数组索引需要-1