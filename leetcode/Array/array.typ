= 普通数组
  - #image("Screenshot_20250908_114830.png")
  - 动态规划
    ```java
    class Solution {
    public int maxSubArray(int[] nums) {
        int pre = 0;
        int maxans =  nums[0];
        for(int num:nums){
             pre = Math.max(pre+num,num);
             maxans = Math.max(pre,maxans);
        }
        return maxans;
    }
}
    ```
    - 从数组索引0处开始遍历，每次记录前n项最大和与nums[n]的大小比较，再用maxnum记录最大值
  - 分治
    ```java
 class Solution {
    public class Status {
        public int lSum, rSum, mSum, iSum;

        public Status(int lSum, int rSum, int mSum, int iSum) {
            this.lSum = lSum;
            this.rSum = rSum;
            this.mSum = mSum;
            this.iSum = iSum;
        }
    }

    public int maxSubArray(int[] nums) {
        return getInfo(nums, 0, nums.length - 1).mSum;
    }

    public Status getInfo(int[] a, int l, int r) {
        if (l == r) {
            return new Status(a[l], a[l], a[l], a[l]);
        }
        int m = (l + r) >> 1;
        Status lSub = getInfo(a, l, m);
        Status rSub = getInfo(a, m + 1, r);
        return pushUp(lSub, rSub);
    }

    public Status pushUp(Status l, Status r) {
        int iSum = l.iSum + r.iSum;
        int lSum = Math.max(l.lSum, l.iSum + r.lSum);
        int rSum = Math.max(r.rSum, r.iSum + l.rSum);
        int mSum = Math.max(Math.max(l.mSum, r.mSum), l.rSum + r.lSum);
        return new Status(lSum, rSum, mSum, iSum);
    }
}
    }
}


    ```
    - 每次将数组分成两半
    - 每次计算左右数组的左最大和和右最大和
    - 最后计算总最大和时，计算左最大和，右最大和和中间最大和的最大值
- 合并区间
  #image("Screenshot_20250910_193153.png")
  - 排序
    - 对每个二维数组的左端点进行排序
    - 遍历排序后的二维数组
    - 如果当前区间的左端点小于等于上一个区间的右端点，则进行合并，合并需要判断上一个区间的右端点和当前区间的右端点谁大
    - 否则将当前区间加入结果数组
    ```java
    class Solution {
    public int[][] merge(int[][] intervals) {
        if(intervals.length==0){
            return new int[0][2];
        }
           Arrays.sort(intervals, new Comparator<int[]>() {
            public int compare(int[] interval1, int[] interval2) {
                return interval1[0] - interval2[0];
            }
        });
        List<int[]> arraylist = new ArrayList<>();
        for(int i = 0;i<intervals.length;i++){
            int L = intervals[i][0];
            int R = intervals[i][1];
            if(arraylist.size()==0||arraylist.get(arraylist.size()-1)[1]<L){
                 arraylist.add(new int[]{L,R});
            }
            else{
                arraylist.get(arraylist.size()-1)[1]=Math.max(R,arraylist.get(arraylist.size()-1)[1]);
            }
        }
        return arraylist.toArray(new int[arraylist.size()][]);
    }
}
    ```
    - 重点
      - 排序用
      ```java
        Arrays.sort(intervals, new Comparator<int[]>() {
            public int compare(int[] interval1, int[] interval2) {
                return interval1[0] - interval2[0];
            }
        });
      ```
      - 如果用
        ```java
            Arrays.sort(intervals,Comparator.comparingInt(a -> a[0]));
        ```
        - 效率会慢很多
      - arraylist的长度要用size（）
      - 二维数组用arraylist来存储，把list自身索引看成一维，每个元素是一个一维数组
      - 上一个区间的数组可以直接放在结果中，然后用arraylist.get（size-1）来获取，再和当前区间比较，再看是更新当前区间右端点还是插入新区间
      - arraylist加入新元素
      ```java
      arraylist.add(new int[]{L,R});
      ```
      - 将元素为一维数组的list转成二维数组
      ```java
      return arraylist.toArray(new int[arraylist.size()][2]);

      ```
- 轮转数组
  #image("Screenshot_20250910_205741.png")
  - 环状替代
    - 计算数组中有几个环count，环中元素等于数组长度n/count
    - for循环遍历这count个环
    - 对于每个环，进行环状替代，原理就是，每个环都会回到起点，每个环从起点开始，将当前位置的值推到下一个位置，直到回到起点，因为轮转数组其实就是把每个位置的数向前移动k个
    ```java
    class Solution {
    public void rotate(int[] nums, int k) {
        int n = nums.length;
        k = k % n;
        int count = gcd(k, n);
        for (int start = 0; start < count; ++start) {
            int current = start;
            int prev = nums[start];
            do {
                int next = (current + k) % n;
                int temp = nums[next];
                nums[next] = prev;
                prev = temp;
                current = next;
            } while (start != current);
        }
    }

    public int gcd(int x, int y) {
        return y > 0 ? gcd(y, x % y) : x;
    }
}

    ```
    - 重点
      - 注意先对k取模处理
      - gcd的写法
      - 对于每个环，是将数一个个从起点往后推直到回到起点，而不是交换
  - 反转数组
    - 先将整个数组反转
    - 再将前k个元素反转
    - 最后将后n-k个元素反转
    ```java
    class Solution {
    public void rotate(int[] nums, int k) {
        int n = nums.length;
        k = k % n;
        reverse(nums, 0, n - 1);
        reverse(nums, 0, k - 1);
        reverse(nums, k, n - 1);
    }

    public void reverse(int[] nums, int start, int end) {
        while (start < end) {
            int temp = nums[start];
            nums[start] = nums[end];
            nums[end] = temp;
            start++;
            end--;
        }
    }

}
```

    - 重点
      - 反转数组的写法
      - 注意k取模
- 除自身外数组的乘积
#image("Screenshot_20250917_153114.png")
  - 左右数组乘积
    - 只用一个结果数组存储
    - 两次遍历
      - 第一次遍历计算每个位置的左数组的乘积，存储到结果数组
      - 第二次遍历在结果数组的基础上，从尾部遍历乘上右数组的乘积
      ```java
      class Solution {
    public int[] productExceptSelf(int[] nums) {
        int length = nums.length;
        int[] ans = new int[length];
        ans[0]=1;
        for(int i =1;i<length;i++){
           ans[i]=ans[i-1]*nums[i-1];
        }
        int R = 1;
        for(int i = length-1;i>=0;i--){
            ans[i]=ans[i]*R;
            R = R*nums[i];
        }
        return ans;
    }
} 
      ```
- 缺失的第一个正数
#image("Screenshot_20250921_222536.png")
  - 哈希
    - 不是用哈希表实现，而是利用哈希的思想
    - 将数组的索引作为哈希的值，将数组对应索引的值作为哈希的输入
    - 利用的思想是，数组长度为n的情况下，最大正数要么小于n,要么为n+1
    - 因此可以将数组索引作为哈希表，遍历数组，若满足条件则标记数组
      - 标记数组的方式是，利用索引处对应的值对应到索引-1,如nums[i]=2,则标记i为1的位置，这样我们可以保留原来数组的数的值，值为x则对应索引x-1
      - 我们这里采用标记负数的形式，因为标记负数可以用abs取得原值，不改变原来数组的数的情况
      - 因此，我们只要找到nums[z]>0的位置，该位置对应的索引z+1就是原数组缺失的第一个正数，因为前z个索引被标记为负数，即原数组1到z的数都存在
    - 若遍历完整个数组都没有正数，说明原数组前n个数都存在，那么缺失的就是n+1
    ```java
            class Solution {
            public int firstMissingPositive(int[] nums) {
                int n = nums.length;
                for (int i = 0; i < n; ++i) {
                    if (nums[i] <= 0) {
                        nums[i] = n + 1;
                    }
                }
                for (int i = 0; i < n; ++i) {
                    int num = Math.abs(nums[i]);
                    if (num <= n) {
                        nums[num - 1] = -Math.abs(nums[num - 1]);
                    }
                }
                for (int i = 0; i < n; ++i) {
                    if (nums[i] > 0) {
                        return i + 1;
                    }
                }
                return n + 1;
            }
        }


    ```
    - 置换法
      - 和上述思路类似，置换法将索引对应的值放到值对应的索引处。如nums[i]=x,就交换nums[x-1]和nums[i]的值，通过while循环不断置换，直到当前nums[i]为不满足情况的数，尽可能保证nums[i]的值为i+1，前提是原数组i+1存在；
      - 置换后，遍历置换后的数组，若nums[i]!=i+1,则i+1就是缺失的正数
      - 重点就在while的理解上，一定要处理完当前位置上所有置换来的数直到不满足条件为止，置换出去的数一定在该在的位置上，至于当前位置不满足条件是没关系的，因为遍历到后面的位置时，如果已经是最终状态nums[i]=i+1就跳过循环，如果不是最终状态即可开始置换，于是之前虽然不满足条件的位置也会被置换走，前提是数组有该位置对应的数