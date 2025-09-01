+ 无重复字符的最长子串
  - #image("Screenshot_20250825_230940.png")
  - 用滑动窗口的解法，一层for循环以i为窗口左端点，int right为窗口右端点
  - 用哈希表记录窗口中有的字母，如果i右移就在哈希表中删去i-1对应的数据
  - right从-1开始，因为记录到哈希表中要从right+1开始，要记录到索引0
  - 如果right和i对应的数据不一样就right++，同时把数放进哈希表
  - 不用担心左端点超过右端点，当i和right+1重合，也就意味着哈希表中所有数据都被删除了只剩下right+1，当i继续前进right也会继续前进
  - 字符串的求长度是函数，耗时，最好int n提到循环外
  - 集合的初始化泛型要用包装类
  - res初始化为0,因为s可能为空
  - 也可以不用right+1,直接用right,并且初始化的时候用0,但是这样就要在计算res的时候用right-i；因为right从0开始意味着每次循环判断的都是right本身是否符合滑动窗口的单一元素，但是进入了while循环right就会++，如果下一个right进入不了循环，那res得到的right就会是滑动窗口外的下一个元素，但我们计算滑动窗口长度要的是窗口最后一个值到第一个值的距离。因此计算res的时候要减去一。
  ```java
  class Solution {
    public int lengthOfLongestSubstring(String s) {
        Set<Character> hashset = new HashSet<>();
         int n = s.length();
        int res=0;
        int right = -1;
        for(int i = 0;i<n;i++){
            if(i!=0){
                hashset.remove(s.charAt(i - 1));
            }
            while(right+1<n&&!hashset.contains(s.charAt(right+1))){
                hashset.add(s.charAt(right+1 ));
                right++;
            }
            res = Math.max(res,right-i+1);
        }
        return res;
    }
}
  ```
+ 找到字符串中所有字母异位词
  - 基础滑动窗口
  ```java 
  class Solution {
    public List<Integer> findAnagrams(String s, String p) {
       int slength = s.length();
       int plength = p.length();

       if(slength<plength){
        return new ArrayList<Integer>();
       }
       int[] scount = new int[26];
       int[] pcount = new int[26];
       List<Integer> ans = new ArrayList<>();
       for(int i = 0;i<plength;i++){
          ++scount[s.charAt(i)-'a'];
          ++pcount[p.charAt(i)-'a'];
       }
       if(Arrays.equals(scount,pcount)){
          ans.add(0);
       }
       for(int i = 0;i<slength-plength;i++){
          --scount[s.charAt(i)-'a'];
          ++scount[s.charAt(i+plength)-'a'];
          if(Arrays.equals(scount,pcount)){
            ans.add(i+1);
          }
          
       }
           return ans;
    }
}
  ``` 
    - 用数组记录窗口内字母出现频率
    - 数组索引与字母对应
    - 比较频率数组是否相同来比较窗口内异位词是否相同
    - 窗口指针在字符串移动，把左指针对应的值从频率数组移去，把右指针移入
  - 优化滑动窗口
    - 用differ记录两个字符串中不一样单词的频率
    - 可优化一个频率数组的空间
          ```java
      class Solution {
    public List<Integer> findAnagrams(String s, String p) {
        int sLen = s.length(), pLen = p.length();

        if (sLen < pLen) {
            return new ArrayList<Integer>();
        }

        List<Integer> ans = new ArrayList<Integer>();
        int[] count = new int[26];
        for (int i = 0; i < pLen; ++i) {
            ++count[s.charAt(i) - 'a'];
            --count[p.charAt(i) - 'a'];
        }

        int differ = 0;
        for (int j = 0; j < 26; ++j) {
            if (count[j] != 0) {
                ++differ;
            }
        }

        if (differ == 0) {
            ans.add(0);
        }

        for (int i = 0; i < sLen - pLen; ++i) {
            if (count[s.charAt(i) - 'a'] == 1) {  // 窗口中字母 s[i] 的数量与字符串 p 中的数量从不同变得相同
                --differ;
            } else if (count[s.charAt(i) - 'a'] == 0) {  // 窗口中字母 s[i] 的数量与字符串 p 中的数量从相同变得不同
                ++differ;
            }
            --count[s.charAt(i) - 'a'];

            if (count[s.charAt(i + pLen) - 'a'] == -1) {  // 窗口中字母 s[i+pLen] 的数量与字符串 p 中的数量从不同变得相同
                --differ;
            } else if (count[s.charAt(i + pLen) - 'a'] == 0) {  // 窗口中字母 s[i+pLen] 的数量与字符串 p 中的数量从相同变得不同
                ++differ;
            }
            ++count[s.charAt(i + pLen) - 'a'];
            
            if (differ == 0) {
                ans.add(i + 1);
            }
        }

        return ans;
    }
}
      ```
      - 这里的differ指的是字母频率不同的个数，当窗口移动的时候，根据移出的左边界和移入的右边界分别判断differ加减，如果differ为0则为异位词