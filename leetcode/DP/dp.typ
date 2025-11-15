- 爬楼梯
  #image("Screenshot_20251111_093022.png")
  - 动态规划
  ```java
  class Solution {
    public int climbStairs(int n) {
        int p = 0, q = 0, r = 1;
        for (int i = 1; i <= n; ++i) {
            p = q; 
            q = r; 
            r = p + q;
        }
        return r;
    }
}
  ```
    - 因为到达当前楼梯的次数等于当前楼梯前一个楼梯的次数走一步和第二个楼梯走两步
    - 也就是当前楼梯次数等于前两个楼梯次数之和

  - 矩阵快速幂
    ```java
    public class Solution {
    public int climbStairs(int n) {
        int[][] q = {{1, 1}, {1, 0}};
        int[][] res = pow(q, n);
        return res[0][0];
    }

    public int[][] pow(int[][] a, int n) {
        int[][] ret = {{1, 0}, {0, 1}};
        while (n > 0) {
            if ((n & 1) == 1) {
                ret = multiply(ret, a);
            }
            n >>= 1;
            a = multiply(a, a);
        }
        return ret;
    }

    public int[][] multiply(int[][] a, int[][] b) {
        int[][] c = new int[2][2];
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 2; j++) {
                c[i][j] = a[i][0] * b[0][j] + a[i][1] * b[1][j];
            }
        }
        return c;
    }
}

    ```
    - a的12次方可以看作是a的八次方\*a的四次方
    - 如何得到a的n次方？
      - 由于我们要爬到n层楼梯，可以将n化作二进制
      - 那么n就会在某些位上为1,某些位上为0
      - 因为n就是我们需要的次数也就是幂
      - 因此我们只需要找到n转换为二进制后所有为1的位数相乘即可
      - 如a的12次方在4和8的位置为1,那么在将二进制右移的过程中，在0,2的位置都为0,直接略过，同时将a相乘分别得到a平方和a的四次方
      - 下一次遍历到4的位置发现为一就可以直接相乘，同时更新a的幂，也就是每次右移都更新a的幂为当前最右


- 杨辉三角
  ```java
  class Solution {
    public List<List<Integer>> generate(int numRows) {
        List<List<Integer>> ret = new ArrayList<List<Integer>>();
        for (int i = 0; i < numRows; ++i) {
            List<Integer> row = new ArrayList<Integer>();
            for (int j = 0; j <= i; ++j) {
                if (j == 0 || j == i) {
                    row.add(1);
                } else {
                    row.add(ret.get(i - 1).get(j - 1) + ret.get(i - 1).get(j));
                }
            }
            ret.add(row);
        }
        return ret;
    }
}


  ```

- 打家劫舍
  #image("Screenshot_20251111_110737.png")
  ```java
  class Solution {
    public int rob(int[] nums) {
        if (nums == null || nums.length == 0) {
            return 0;
        }
        int length = nums.length;
        if (length == 1) {
            return nums[0];
        }
        int first = nums[0], second = Math.max(nums[0], nums[1]);
        for (int i = 2; i < length; i++) {
            int temp = second;
            second = Math.max(first + nums[i], second);
            first = temp;
        }
        return second;
    }
}
 
  ```
  - 每次记录索引位置的最大值
  - 可以用变量替代数组
  - 每次将first和second向前移


- 完全平方数
  - 动态规划
  ```java
  class Solution {
    public int numSquares(int n) {
        int[] f = new int[n + 1];
        for (int i = 1; i <= n; i++) {
            int minn = Integer.MAX_VALUE;
            for (int j = 1; j * j <= i; j++) {
                minn = Math.min(minn, f[i - j * j]);
            }
            f[i] = minn + 1;
        }
        return f[n];
    }
}
 
  ```
    - 用n+1长度的数组记录从1到n每个数可以被最少的完全平方数构成的次数
    - minn每次计算当前索引最小值都要重新计算，而不是全局最小值

- 零钱兑换
  ```java
  public class Solution {
    public int coinChange(int[] coins, int amount) {
        int max = amount + 1;
        int[] dp = new int[amount + 1];
        Arrays.fill(dp, max);
        dp[0] = 0;
        for (int i = 1; i <= amount; i++) {
            for (int j = 0; j < coins.length; j++) {
                if (coins[j] <= i) {
                    dp[i] = Math.min(dp[i], dp[i - coins[j]] + 1);
                }
            }
        }
        return dp[amount] > amount ? -1 : dp[amount];
    }
}
  
  ```
    - 一样用amount+1长度数组，索引对应amount大小
    - 对每个索引也就是每个金额找到最小硬币数


- 单词拆分
  #image("Screenshot_20251111_192901.png")
  ```java
  public class Solution {
    public boolean wordBreak(String s, List<String> wordDict) {
        Set<String> wordDictSet = new HashSet(wordDict);
        boolean[] dp = new boolean[s.length() + 1];
        dp[0] = true;
        for (int i = 1; i <= s.length(); i++) {
            for (int j = 0; j < i; j++) {
                if (dp[j] && wordDictSet.contains(s.substring(j, i))) {
                    dp[i] = true;
                    break;
                }
            }
        }
        return dp[s.length()];
    }
}

  ```
    - 用字符串长度+1的boolean数组来记录字符串可以被wordict组成的最远距离，也就是若dp[i]为true说明从0到i这个substring可以由wordict组成
    - 用hashset存储wordict,一是为了过滤重复元素，二是可以利用hashset的contains函数快速遍历找到子串


- 最长递增子序列
  #image("Screenshot_20251111_194446.png")
  ```java
  class Solution {
    public int lengthOfLIS(int[] nums) {
        if (nums.length == 0) {
            return 0;
        }
        int[] dp = new int[nums.length];
        dp[0] = 1;
        int maxans = 1;
        for (int i = 1; i < nums.length; i++) {
            dp[i] = 1;
            for (int j = 0; j < i; j++) {
                if (nums[i] > nums[j]) {
                    dp[i] = Math.max(dp[i], dp[j] + 1);
                }
            }
            maxans = Math.max(maxans, dp[i]);
        }
        return maxans;
    }
}

  ```
    - 将每个索引处最大递增子序列长度保留，也就是dp数组
    - 遍历nums,每次有nums[i]大于nums[j]时就判断dp[i]的值是否需要更新
    - 对每个i位置遍历完j后更新答案maxans

- 乘积最大子数组
  #image("Screenshot_20251112_193527.png")
  ```java
  class Solution {
    public int maxProduct(int[] nums) {
        int n = nums.length;
        int max = nums[0];
        int min = nums[0];
        int ans = nums[0];
        for(int i=1;i<n;i++){
            int mx = max;
            int mn = min;
            max = Math.max(mn*nums[i],Math.max(nums[i],mx*nums[i]));
            min = Math.min(mx*nums[i],Math.min(nums[i],mn*nums[i]));
            ans = Math.max(max,ans);
        }
        return ans;
    }
}
  ```
    - 同时维护最大值和最小值，每次比较最大值\*当前位置和最小值\*当前位置与当前位置三个数大小，更新最大最小值


- 分割等和子集
  #image("Screenshot_20251112_201459.png")
  - 二维数组dp解法 
  ```java
  class Solution {
    public boolean canPartition(int[] nums) {
        int n = nums.length;
        if (n < 2) {
            return false;
        }
        int sum = 0, maxNum = 0;
        for (int num : nums) {
            sum += num;
            maxNum = Math.max(maxNum, num);
        }
        if (sum % 2 != 0) {
            return false;
        }
        int target = sum / 2;
        if (maxNum > target) {
            return false;
        }
        boolean[][] dp = new boolean[n][target + 1];
        for (int i = 0; i < n; i++) {
            dp[i][0] = true;
        }
        dp[0][nums[0]] = true;
        for (int i = 1; i < n; i++) {
            int num = nums[i];
            for (int j = 1; j <= target; j++) {
                if (j >= num) {
                    dp[i][j] = dp[i - 1][j] | dp[i - 1][j - num];
                } else {
                    dp[i][j] = dp[i - 1][j];
                }
            }
        }
        return dp[n - 1][target];
    }
}

  ```
    - 用一个行为n列为target的二维数组来动态规划
    - 行索引代表前n个元素选取，列索引代表目标值，若dp[i][j]为true,说明前i个元素集合中可以找到元素之和为j的一组元素
    - 每次更新当前dp[i][j]时需要判断nums[i]和j的大小比值来看是否选取当前元素
  - 一维数组优化
    ```java
    class Solution {
    public boolean canPartition(int[] nums) {
        int n = nums.length;
        if (n < 2) {
            return false;
        }
        int sum = 0, maxNum = 0;
        for (int num : nums) {
            sum += num;
            maxNum = Math.max(maxNum, num);
        }
        if (sum % 2 != 0) {
            return false;
        }
        int target = sum / 2;
        if (maxNum > target) {
            return false;
        }
        boolean[] dp = new boolean[target + 1];
        dp[0] = true;
        for (int i = 0; i < n; i++) {
            int num = nums[i];
            for (int j = target; j >= num; --j) {
                dp[j] |= dp[j - num];
            }
        }
        return dp[target];
    }
}

    ``` 
      - 因为二维数组每次只由上一行元素来更新
      - 因此可以只用一行数组来更新
      - 但是要从后往前，因为前面的元素要保留上一行的状态，如果从前往后状态就先被更新了
      - 为什么这里不赋值dp[num[0]]=true
        - 其实是可以赋值的，当时赋值后说明第一行已经处理完了，那么for循环的i要从1开始遍历



- 不同路径
  #image("Screenshot_20251115_105040.png")
  ```java
  class Solution {
    public int uniquePaths(int m, int n) {
        int[][] f = new int[m][n];
        for (int i = 0; i < m; ++i) {
            f[i][0] = 1;
        }
        for (int j = 0; j < n; ++j) {
            f[0][j] = 1;
        }
        for (int i = 1; i < m; ++i) {
            for (int j = 1; j < n; ++j) {
                f[i][j] = f[i - 1][j] + f[i][j - 1];
            }
        }
        return f[m - 1][n - 1];
    }
}

  ```
  - 滚动数组法
    ```java
    class Solution {
    public int uniquePaths(int m, int n) {
        int[] f = new int[n];
        for (int i = 0; i < n; ++i) {
            f[i] = 1;
        }
        for (int i = 1; i < m; ++i) {
            for (int j = 1; j < n; ++j) {
                f[j] += f[j - 1];
            }
        }
        return f[n - 1];
    }
}


    ```
        - 把f[0]看作是上一行的第一个元素，其他元素看作是当前行的元素

    - 组合数学
    ```java
    class Solution {
    public int uniquePaths(int m, int n) {
        long ans = 1;
        for (int x = n, y = 1; y < m; ++x, ++y) {
            ans = ans * x / y;
        }
        return (int) ans;
    }
} 
    ```
      - 从左上角到右下角的过程中，我们需要移动 m+n−2 次，其中有 m−1 次向下移动，n−1 次向右移动。因此路径的总数，就等于从 m+n−2 次移动中选择 m−1 次向下移动的方案数