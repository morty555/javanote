- 买卖股票的最佳时机
  ```java
  public class Solution {
    public int maxProfit(int prices[]) {
        int minprice = Integer.MAX_VALUE;
        int maxprofit = 0;
        for (int i = 0; i < prices.length; i++) {
            if (prices[i] < minprice) {
                minprice = prices[i];
            } else if (prices[i] - minprice > maxprofit) {
                maxprofit = prices[i] - minprice;
            }
        }
        return maxprofit;
    }
}

  ```
    - 遍历数组
    - 每次更新最小值，然后max从每个数开始更新，即每次更新当前数与目前最小值的最大差

    #image("Screenshot_20251110_141940.png")
- 跳跃游戏
  #image("Screenshot_20251110_142002.png")
  ```java
  public class Solution {
    public boolean canJump(int[] nums) {
        int n = nums.length;
        int rightmost = 0;
        for (int i = 0; i < n; ++i) {
            if (i <= rightmost) {
                rightmost = Math.max(rightmost, i + nums[i]);
                if (rightmost >= n - 1) {
                    return true;
                }
            }
        }
        return false;
    }
}

  ```
   - 也是每个数都遍历一遍
   - 用rightmost记录当前能够到达的最远距离
   - 遍历到的i与rightmost比较，如果i小于rightmost说明当前地方无法到达
   - 如果大于说明可以到达该位置就可以更新



- 跳跃游戏 II
  #image("Screenshot_20251110_143748.png")
  ```java
  class Solution {
    public int jump(int[] nums) {
        int length = nums.length;
        int end = 0;
        int maxPosition = 0; 
        int steps = 0;
        for (int i = 0; i < length - 1; i++) {
            maxPosition = Math.max(maxPosition, i + nums[i]); 
            if (i == end) {
                end = maxPosition;
                steps++;
            }
        }
        return steps;
    }
}

  ```
    - 每次遍历更新maxposition，也就是当前步数和当前位置能到达的最远位置
    - 遍历每个数，每次当i也就是遍历到当前数的索引到达目前步数能到达的最远处end时，需要step++，同时更新end为当前步数和当前位置能到达的最远处也就是maxposition


- 划分字母区间
  #image("Screenshot_20251110_160344.png")
  ```java
  class Solution {
    public List<Integer> partitionLabels(String s) {
        int[] last = new int[26];
        int length = s.length();
        for (int i = 0; i < length; i++) {
            last[s.charAt(i) - 'a'] = i;
        }
        List<Integer> partition = new ArrayList<Integer>();
        int start = 0, end = 0;
        for (int i = 0; i < length; i++) {
            end = Math.max(end, last[s.charAt(i) - 'a']);
            if (i == end) {
                partition.add(end - start + 1);
                start = end + 1;
            }
        }
        return partition;
    }
}

  ```
  - 遍历数组的每一个数，存储每个字母的最后一个下标
  - 遍历数组的每一个数，更新当前区域内字母到达的最远距离
  - 当i达到end,说明该区域内没有重复的数，且该区域外的数没有与当前区域重复的数，将当前区域内的数量加入结果数组
  - 返回数组
  
   