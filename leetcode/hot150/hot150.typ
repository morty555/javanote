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

- 股票买卖时机
  ```java
  class Solution {
    public int maxProfit(int[] prices) {
        int preMin = Integer.MAX_VALUE;
        int ans = 0;
        for(int i=0;i<prices.length;i++){
            if(preMin>prices[i]){
                preMin = prices[i];
                continue;
            }
            ans += prices[i]-preMin;
            preMin = prices[i];
        }
        return ans;
    }
}  
  ```

- H指数
  #image("/assets/Screenshot_20251124_233641.png")
  - 排序 
  - 计数排序 
    ```java
            public class Solution {
            public int hIndex(int[] citations) {
                int n = citations.length, tot = 0;
                int[] counter = new int[n + 1];
                for (int i = 0; i < n; i++) {
                    if (citations[i] >= n) {
                        counter[n]++;
                    } else {
                        counter[citations[i]]++;
                    }
                }
                for (int i = n; i >= 0; i--) {
                    tot += counter[i];
                    if (tot >= i) {
                        return i;
                    }
                }
                return 0;
            }
        }


    ```
  - 二分 
    - 空间复杂度O1


- 接雨水 
  - 双指针
  ```java
  class Solution {
    public int trap(int[] height) {
        int ans = 0;
        int left = 0, right = height.length - 1;
        int leftMax = 0, rightMax = 0;
        while (left < right) {
            leftMax = Math.max(leftMax, height[left]);
            rightMax = Math.max(rightMax, height[right]);
            if (height[left] < height[right]) {
                ans += leftMax - height[left];
                ++left;
            } else {
                ans += rightMax - height[right];
                --right;
            }
        }
        return ans;
    }
}
 
  ```
  - 动态规划
    - 遍历得到每个索引的左最大和右最大，用两个数组存储
    - 对每个位置求左最大和右最大的最小值-当前索引位置的值
    - 最后遍历结果数组求和


- 最长公共前缀 
  #image("/assets/Screenshot_20251129_155208.png")
  - 列式对比
  ```java
    class Solution {
        public String longestCommonPrefix(String[] strs) {
            if(strs.length==1){
                return strs[0];
            }
            int n = strs[0].length();
            StringBuffer ans = new StringBuffer();
            ans.append("");
            for(int i=0;i<n;i++){
                char temp = strs[0].charAt(i);
                for(int j=1;j<strs.length;j++){
                    if(i<strs[j].length()&&strs[j].charAt(i)==temp){
                        if(j==strs.length-1){
                            ans.append(temp);
                        }
                        
                    }
                    else{
                            return ans.toString();
                        }
                }
            }
            return ans.toString();
        }
    } 
  ```


- 找出字符串中第一个匹配项的下标
  - 暴力
    ```java
    class Solution {
    public int strStr(String haystack, String needle) {
        int n = haystack.length();
        int m = needle.length();
        for(int i=0;i+m<=n;i++){
            boolean flag = true;
            for(int j=0;j<m;j++){
                
                if(haystack.charAt(i+j)!=needle.charAt(j)){
                    flag = false;
                    continue;
                }
            }
               if(flag){
                    return i;
                }
        }
        return -1;
    }
}
    ```
  - KMP



- 验证回文串
    ```java
    class Solution {
        public boolean isPalindrome(String s) {
            int n = s.length();
            int left = 0;
            int right = n-1;
            while(left<right){
                while(left<=n-1&&!Character.isLetterOrDigit(s.charAt(left))){
                    left++;
                }
                while(right>=0&&!Character.isLetterOrDigit(s.charAt(right))){
                    right--;
                }
                if(left<right){
                if(Character.toLowerCase(s.charAt(left))!=Character.toLowerCase(s.charAt(right))){
                    return false;
                }
                left++;
                right--;
                    }
            }
            return true;
        }
    }
    ```
    - 在每次判断的时候都while判断左右指针是否是数字或字母，若不是则移动指针
    - 若左右指针都是数字或字母则转小写进行比较
    - 注意，有可能在前面的while循环中，指针已经越界了，所以while中要判断越界，同时在比较之前要判断left和right是否越界


- 判断子序列
  #image("/assets/Screenshot_20251201_114804.png")
  ```java
  class Solution {
    public boolean isSubsequence(String s, String t) {
        int n = s.length();
        int m =t.length();
        boolean[][] matrix = new boolean[n+1][m+1];
        for(int j=0;j<=m;j++){
            matrix[0][j] = true; // 空字符串是任何字符串的子序列
        }
        for(int i=1;i<=n;i++){
            for(int j=1;j<=m;j++){
                if(s.charAt(i-1)==t.charAt(j-1)){
                    matrix[i][j]=matrix[i-1][j-1];
                }
                else{
                    matrix[i][j]=matrix[i][j-1];
                }
            }
        }
        return matrix[n][m];
    }
}
  ```
  - 由于题目规定了s比j小，所以只需要判断s是否是t的子序列
  - 定义一个二维数组matrix，matrix[i][j]表示s的前i个字符是否是t的前j个字符的子序列
  - 初始化matrix[0][j]为true，因为空字符串是任何字符串的子序列
  - 遍历s和t的每个字符，若相等则matrix[i][j]=matrix[i-1][j-1]，否则matrix[i][j]=matrix[i][j-1]，也就是说新增的t的字符不影响子序列的判断，新增的t的字符的boolean结果由前一个t的字符决定
  - 最后返回matrix[n][m]即可

- 长度最小的子数组     
  #image("/assets/Screenshot_20251201_165300.png")
  - 滑动窗口
    ```java
    class Solution {
    public int minSubArrayLen(int target, int[] nums) {
        int start = 0;
        int end = 0;
        int n = nums.length;
        int sum = 0;
        int ans = Integer.MAX_VALUE;
        while(end<n){
            sum+=nums[end];
            while(sum>=target){
                ans = Math.min(ans,end-start+1);
                sum -= nums[start];
                start++;
            }
            end++;
        }
        return ans==Integer.MAX_VALUE?0:ans;
    }
}
    ```
    - 子数组，意味着不能排序
    - 使用滑动窗口，end指针不断向右移动，直到子数组和大于等于target
    - 然后移动start指针，直到子数组和小于target。（这里的意义是，因为end移动找到子数组和大于等于target是有可能使用了超过它所需要的最小个数的）
    - 每次移动start指针时，更新最小长度，直到子数组和小于target然后继续移动end指针
    - 最后返回最小长度即可


- 有效的数独
  #image("/assets/Screenshot_20251201_170759.png")
  ```java
  class Solution {
    public boolean isValidSudoku(char[][] board) {
        int[][] row = new int[9][9];
        int[][] line = new int[9][9];
        int[][][] q = new int[3][3][9];
        for(int i=0;i<9;i++){
            for(int j=0;j<9;j++){
                if(board[i][j]!='.'){
                    int temp = board[i][j]-'0'-1;
                    row[i][temp]+=1;
                    line[j][temp]+=1;
                    q[i/3][j/3][temp]+=1;
                    if(row[i][temp]>1||line[j][temp]>1||q[i/3][j/3][temp]>1){
                    return false;
                }
                }
               
            }
        } 
        return true;
    }
}
  ```
  - 使用三个数组分别记录行、列、九宫格中数字出现的次数
  - 遍历数独，遇到数字就更新对应的行、列、九宫格的数字出现次数
  - 如果某个数字出现次数大于1则返回false
  - 遍历结束后返回true即可

- 同构字符串
  #image("/assets/Screenshot_20251210_155443.png")
  ```java
  class Solution {
    public boolean isIsomorphic(String s, String t) {
        Map<Character, Character> s2t = new HashMap<Character, Character>();
        Map<Character, Character> t2s = new HashMap<Character, Character>();
        int len = s.length();
        for (int i = 0; i < len; ++i) {
            char x = s.charAt(i), y = t.charAt(i);
            if ((s2t.containsKey(x) && s2t.get(x) != y) || (t2s.containsKey(y) && t2s.get(y) != x)) {
                return false;
            }
            s2t.put(x, y);
            t2s.put(y, x);
        }
        return true;
    }
}
  ```
  - 因为同构，因此可以让s的每一位对应t的每一位
  - 使用两个哈希表分别记录s到t和t到s的映射
  - 遍历s和t的每一位，若s到t的映射已经存在且不等于当前t的字符，或者t到s的映射已经存在且不等于当前s的字符，则返回false
  - 否则更新映射关系
  - 遍历结束后返回true即可