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
    