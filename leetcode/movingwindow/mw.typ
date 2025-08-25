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