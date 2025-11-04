- 全排列
  - visited数组法
  ```java
  import java.util.*;

public class Permutations1 {
    public List<List<Integer>> permute(int[] nums) {
        List<List<Integer>> result = new ArrayList<>();
        boolean[] visited = new boolean[nums.length];
        backtrack(nums, new ArrayList<>(), visited, result);
        return result;
    }

    private void backtrack(int[] nums, List<Integer> path, boolean[] visited, List<List<Integer>> result) {
        if (path.size() == nums.length) {
            result.add(new ArrayList<>(path));  // 终止条件
            return;
        }

        for (int i = 0; i < nums.length; i++) {
            if (visited[i]) continue;           // 已经选择过的元素跳过
            path.add(nums[i]);
            visited[i] = true;                  // 标记已访问
            backtrack(nums, path, visited, result);
            path.remove(path.size() - 1);       // 回溯
            visited[i] = false;                 // 撤销标记
        }
    }

    public static void main(String[] args) {
        Permutations1 p = new Permutations1();
        int[] nums = {1, 2, 3};
        List<List<Integer>> res = p.permute(nums);
        System.out.println(res);
    }
}

  ```
  - 原地交换法
  #image("Screenshot_20251101_132657.png")
  ```java
  class Solution {
    public List<List<Integer>> permute(int[] nums) {
        List<List<Integer>> res = new ArrayList<List<Integer>>();

        List<Integer> output = new ArrayList<Integer>();
        for (int num : nums) {
            output.add(num);
        }

        int n = nums.length;
        backtrack(n, output, res, 0);
        return res;
    }

    public void backtrack(int n, List<Integer> output, List<List<Integer>> res, int first) {
        // 所有数都填完了
        if (first == n) {
            res.add(new ArrayList<Integer>(output));
        }
        for (int i = first; i < n; i++) {
            // 动态维护数组
            Collections.swap(output, first, i);
            // 继续递归填下一个数
            backtrack(n, output, res, first + 1);
            // 撤销操作
            Collections.swap(output, first, i);
        }
    }
}
 
  ```
  - 回溯逻辑可以看作是固定first前面的数，然后对后面的数进行全排列
  - 注意当first到达n时要把当前排列加入结果集，要用new ArrayList<>(output)来拷贝当前排列，因为如果直接放入output，后续的交换操作会改变它


- 子集
  - 迭代
  ```java
  class Solution {
    List<Integer> t = new ArrayList<Integer>();
    List<List<Integer>> ans = new ArrayList<List<Integer>>();

    public List<List<Integer>> subsets(int[] nums) {
        int n = nums.length;
        for (int mask = 0; mask < (1 << n); ++mask) {
            t.clear();
            for (int i = 0; i < n; ++i) {
                if ((mask & (1 << i)) != 0) {
                    t.add(nums[i]);
                }
            }
            ans.add(new ArrayList<Integer>(t));
        }
        return ans;
    }
}


  ```
  - 因为子集个数是2的n次方，因此外层遍历2的n次方次数
  - 遍历的过程中，索引mask的变化情况刚好是n位二进制数增加的过程，而二进制数的集合刚好是所有子集
  - 因此我们只需要在每一次外层遍历的同时，在内部遍历n次，判断外层索引的每一位是否为1,为1说明该位置的数被选择，加入到temp数组，内层遍历完后加入到ans
  - 记得每次外层遍历都要先清除temp防止污染，并且结果数组要新new一个arraylist,否则后续修改影响结果

  - dfs+递归
    ```java
    class Solution {
    List<Integer> t = new ArrayList<Integer>();
    List<List<Integer>> ans = new ArrayList<List<Integer>>();

    public List<List<Integer>> subsets(int[] nums) {
        dfs(0, nums);
        return ans;
    }

    public void dfs(int cur, int[] nums) {
        if (cur == nums.length) {
            ans.add(new ArrayList<Integer>(t));
            return;
        }
        t.add(nums[cur]);
        dfs(cur + 1, nums);
        t.remove(t.size() - 1);
        dfs(cur + 1, nums);
    }
}

    ```
    - 深度优先搜索nums中的每一个数，对每一个选择或不选
    - 在dfs函数中，先对所有数都选择，每个数选择完后再加入不选择的答案


- 电话号码的字母组合
  #image("Screenshot_20251102_103434.png")
  ```java
  class Solution {
    public List<String> letterCombinations(String digits) {
        List<String> combinations = new ArrayList<String>();
        if (digits.length() == 0) {
            return combinations;
        }
        Map<Character, String> phoneMap = new HashMap<Character, String>() {{
            put('2', "abc");
            put('3', "def");
            put('4', "ghi");
            put('5', "jkl");
            put('6', "mno");
            put('7', "pqrs");
            put('8', "tuv");
            put('9', "wxyz");
        }};
        backtrack(combinations, phoneMap, digits, 0, new StringBuffer());
        return combinations;
    }

    public void backtrack(List<String> combinations, Map<Character, String> phoneMap, String digits, int index, StringBuffer combination) {
        if (index == digits.length()) {
            combinations.add(combination.toString());
        } else {
            char digit = digits.charAt(index);
            String letters = phoneMap.get(digit);
            int lettersCount = letters.length();
            for (int i = 0; i < lettersCount; i++) {
                combination.append(letters.charAt(i));
                backtrack(combinations, phoneMap, digits, index + 1, combination);
                combination.deleteCharAt(index);
            }
        }
    }
}

  ```
  - 用哈希表存储所有的组合
  - 递归调用backtrack函数，在函数中，取出digits中的每一个元素，在哈希表中拿出该元素对应的字母
  - 对字母组进行遍历，每次取出其中一个字母，然后递归调用digits下一个元素
  - 直到combination中的元素等于digits长度返回结果
  - 然后回溯，删除index位置的元素
  - 下一次循环时就会取出另一个字母
  - 用stringbuffer因为是动态string
  - tostring可以new一个新的string


- 组合总和
  #image("Screenshot_20251102_110918.png")
  ```java  
  class Solution {
    public List<List<Integer>> combinationSum(int[] candidates, int target) {
        List<List<Integer>> ans = new ArrayList<List<Integer>>();
        List<Integer> combine = new ArrayList<Integer>();
        dfs(candidates, target, ans, combine, 0);
        return ans;
    }

    public void dfs(int[] candidates, int target, List<List<Integer>> ans, List<Integer> combine, int idx) {
        if (idx == candidates.length) {
            return;
        }
        if (target == 0) {
            ans.add(new ArrayList<Integer>(combine));
            return;
        }
        // 直接跳过
        dfs(candidates, target, ans, combine, idx + 1);
        // 选择当前数
        if (target - candidates[idx] >= 0) {
            combine.add(candidates[idx]);
            dfs(candidates, target - candidates[idx], ans, combine, idx);
            combine.remove(combine.size() - 1);
        }
    }
}

  ```
  - backtrack函数默认只选择index及其右边的元素
  - 递归时可以选择和不选择当前元素
  - 选择当前元素又分小于target和大于target
  - 小于就用target减去该元素的值，用新target递归，若大于则直接跳过（if过滤）
  - 如果选择当前元素，下次递归的时候带上的是当前的index,因为一个元素可以选择多次


- 括号生成
  #image("Screenshot_20251103_114324.png")
  - 回溯
  ```java
  class Solution {
    public List<String> generateParenthesis(int n) {
        List<String> ans = new ArrayList<String>();
        backtrack(ans, new StringBuilder(), 0, 0, n);
        return ans;
    }

    public void backtrack(List<String> ans, StringBuilder cur, int open, int close, int max) {
        if (cur.length() == max * 2) {
            ans.add(cur.toString());
            return;
        }
        if (open < max) {
            cur.append('(');
            backtrack(ans, cur, open + 1, close, max);
            cur.deleteCharAt(cur.length() - 1);
        }
        if (close < open) {
            cur.append(')');
            backtrack(ans, cur, open, close + 1, max);
            cur.deleteCharAt(cur.length() - 1);
        }
    }
}
  ```
  - 先填充所有的左括号，右括号根据是否小于左括号数来填充
  - 然后从左括号回溯，比如删除掉最后一个左括号后，又会对右括号进行递归，左括号一直向右移动


- 单词搜索
  #image("Screenshot_20251103_125908.png")
  ```java
  class Solution {
    public boolean exist(char[][] board, String word) {
        int n = board.length;
        int m = board[0].length;
        //visted数组
        boolean[][] visted = new boolean[n][m];
        //四个方向
        int[][] pos = {{0,1},{0,-1},{-1,0},{1,0}};
        boolean flag = false; 
        //回溯函数
        for(int i=0;i<n;i++){
            for(int j=0;j<m;j++){
              flag = backtrack(pos,visted,board,word,i,j,0);
              if(flag){
                return true;
              }
            }
        }
        return false;
        
    }
    public boolean backtrack(int[][] pos,boolean[][]visted,char[][] board,String word,int i,int j,int k){
         if(word.charAt(k)!=board[i][j]){
            return false;
         }
         else if(k==word.length()-1){
            return true;
         }
         boolean flag = false;
         visted[i][j] = true;
         for(int[] dir : pos){
            int newi = dir[0]+i;
            int newj = dir[1]+j;
            if (newi >= 0 && newi < board.length && newj >= 0 && newj < board[0].length) {
            if(!visted[newi][newj]){
                  flag = backtrack(pos,visted,board,word,newi,newj,k+1);
            }
            if(flag==true){
                return true;
            }
            }
         }
         visted[i][j]=false;
       return false;
    }
}
  ```
  - for循环遍历二维数组中每一个数
  - 对每个数扩展四个方向，注意边界，如果方向上的数没有被visit过就递归
  - 如果能够遍历k次且没有false说明存在
  - 每次回溯清除visited数组状态



- 分割回文串
  #image("Screenshot_20251103_193707.png")
  ```java
  class Solution {
    boolean[][] f;
    List<List<String>> ret = new ArrayList<List<String>>();
    List<String> ans = new ArrayList<String>();
    int n;

    public List<List<String>> partition(String s) {
        n = s.length();
        f = new boolean[n][n];
        for (int i = 0; i < n; ++i) {
            Arrays.fill(f[i], true);
        }

        for (int i = n - 1; i >= 0; --i) {
            for (int j = i + 1; j < n; ++j) {
                f[i][j] = (s.charAt(i) == s.charAt(j)) && f[i + 1][j - 1];
            }
        }

        dfs(s, 0);
        return ret;
    }

    public void dfs(String s, int i) {
        if (i == n) {
            ret.add(new ArrayList<String>(ans));
            return;
        }
        for (int j = i; j < n; ++j) {
            if (f[i][j]) {
                ans.add(s.substring(i, j + 1));
                dfs(s, j + 1);
                ans.remove(ans.size() - 1);
            }
        }
    }
}


  ```
  - 生成一个二维数组，用来表示i到j是否为回文串
  - 先将该二维数组全部元素置为true
  - 然后从后向前遍历数组区间，若该区间为回文串则不修改，若不为则修改为false  
    - 判断依据： f[i][j] = (s.charAt(i) == s.charAt(j)) && f[i + 1][j - 1];
    - 也就是若i到j这个区间为回文串，那么s[i]一定等于s[j]，并且f[i+1][j-1]也肯定是回文串
  - 然后从头到尾递归s字符串的所有组合
  - 满足条件的加入答案数组


- N皇后问题
  #image("Screenshot_20251104_112345.png")
  ```java
  class Solution {
    public List<List<String>> solveNQueens(int n) {
        List<List<String>> solutions = new ArrayList<List<String>>();
        int[] queens = new int[n];
        Arrays.fill(queens, -1);
        Set<Integer> columns = new HashSet<Integer>();
        Set<Integer> diagonals1 = new HashSet<Integer>();
        Set<Integer> diagonals2 = new HashSet<Integer>();
        backtrack(solutions, queens, n, 0, columns, diagonals1, diagonals2);
        return solutions;
    }

    public void backtrack(List<List<String>> solutions, int[] queens, int n, int row, Set<Integer> columns, Set<Integer> diagonals1, Set<Integer> diagonals2) {
        if (row == n) {
            List<String> board = generateBoard(queens, n);
            solutions.add(board);
        } else {
            for (int i = 0; i < n; i++) {
                if (columns.contains(i)) {
                    continue;
                }
                int diagonal1 = row - i;
                if (diagonals1.contains(diagonal1)) {
                    continue;
                }
                int diagonal2 = row + i;
                if (diagonals2.contains(diagonal2)) {
                    continue;
                }
                queens[row] = i;
                columns.add(i);
                diagonals1.add(diagonal1);
                diagonals2.add(diagonal2);
                backtrack(solutions, queens, n, row + 1, columns, diagonals1, diagonals2);
                queens[row] = -1;
                columns.remove(i);
                diagonals1.remove(diagonal1);
                diagonals2.remove(diagonal2);
            }
        }
    }

    public List<String> generateBoard(int[] queens, int n) {
        List<String> board = new ArrayList<String>();
        for (int i = 0; i < n; i++) {
            char[] row = new char[n];
            Arrays.fill(row, '.');
            row[queens[i]] = 'Q';
            board.add(new String(row));
        }
        return board;
    }
}



  ```
  - 用一个queens数组存储每行（索引代表）的数组索引对应值位置为Q
  - 用三个set判断是否重复
  - 每行for循环遍历每个元素和对应列元素，主对角线，副对角线元素是否重复，重复则continue
  - 若当前行找到都不重复的元素位置，记录在三个set和queens中，遍历下一行
  - 若能到达第n行，说明所有行都能放置queen,就从queens数组生成一个答案
  - 回溯去除set数组和queens数组
  - 生成答案先用char[]，因为可以按索引插入，最后再转为List