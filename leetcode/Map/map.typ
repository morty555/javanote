- 岛屿数量
  #image("Screenshot_20251024_110741.png")
  - 深度优先搜索
  ```java
    class Solution {
      void dfs(char[][] grid, int r, int c) {
          int nr = grid.length;
          int nc = grid[0].length;

          if (r < 0 || c < 0 || r >= nr || c >= nc || grid[r][c] == '0') {
              return;
          }

          grid[r][c] = '0';
          dfs(grid, r - 1, c);
          dfs(grid, r + 1, c);
          dfs(grid, r, c - 1);
          dfs(grid, r, c + 1);
      }

      public int numIslands(char[][] grid) {
          if (grid == null || grid.length == 0) {
              return 0;
          }

          int nr = grid.length;
          int nc = grid[0].length;
          int num_islands = 0;
          for (int r = 0; r < nr; ++r) {
              for (int c = 0; c < nc; ++c) {
                  if (grid[r][c] == '1') {
                      ++num_islands;
                      dfs(grid, r, c);
                  }
              }
          }

          return num_islands;
      }
  }

  ```
  - 对二维矩阵每一个值遍历
    - 若遇到grid[i][j]=='1‘，也就是遇到了岛屿，就将岛屿数量++，然后从该岛屿位置开始深度优先搜索
  - 深度优先搜索的规则是，对该位置的上下左右四个位置进行扩散遍历，将遍历到grid[i][j]=’1‘的位置都赋值为0
  - 也就是说，对遇到的第一个岛屿，找到和这个岛屿相连的所有岛屿，并将他们都赋值为0（水），是为了在原图的基础上记录已经访问过的岛屿
  - 当整个图遍历完返回总岛屿数量
  - 要注意dfs时的边界条件，需要判断i,j不超过矩阵索引的同时，还需要判断grid[i][j]不等于0,因为遇到水不算岛屿，而且由于我们将原图岛屿标注为水的原因，如果不判断则会栈溢出死循环

- 广度优先搜索
  - 主要思路和深度优先搜索一样
  - 当找到grid[i][j]==‘1’时，也是四个方向先搜索，不同的是用一个栈队列存储岛屿
  - 这样搜索时是先搜索完最近的节点，也就是广度搜索，而递归方法是沿着一个方向查找到底
  ```java
  class Solution {
    public int numIslands(char[][] grid) {
        if (grid == null || grid.length == 0) {
            return 0;
        }

        int nr = grid.length;
        int nc = grid[0].length;
        int num_islands = 0;

        for (int r = 0; r < nr; ++r) {
            for (int c = 0; c < nc; ++c) {
                if (grid[r][c] == '1') {
                    ++num_islands;
                    grid[r][c] = '0';
                    Queue<Integer> neighbors = new LinkedList<>();
                    neighbors.add(r * nc + c);
                    while (!neighbors.isEmpty()) {
                        int id = neighbors.remove();
                        int row = id / nc;
                        int col = id % nc;
                        if (row - 1 >= 0 && grid[row-1][col] == '1') {
                            neighbors.add((row-1) * nc + col);
                            grid[row-1][col] = '0';
                        }
                        if (row + 1 < nr && grid[row+1][col] == '1') {
                            neighbors.add((row+1) * nc + col);
                            grid[row+1][col] = '0';
                        }
                        if (col - 1 >= 0 && grid[row][col-1] == '1') {
                            neighbors.add(row * nc + col-1);
                            grid[row][col-1] = '0';
                        }
                        if (col + 1 < nc && grid[row][col+1] == '1') {
                            neighbors.add(row * nc + col+1);
                            grid[row][col+1] = '0';
                        }
                    }
                }
            }
        }

        return num_islands;
    }
}

  ```
  - 注意，用队列存储位置时，将二维数组的索引转换成int，取出时再计算行和列
  - 注意计算行和列是对列进行取模和除法


- 并查集
  ```java
  class Solution {
    class UnionFind {
        int count;
        int[] parent;
        int[] rank;

        public UnionFind(char[][] grid) {
            count = 0;
            int m = grid.length;
            int n = grid[0].length;
            parent = new int[m * n];
            rank = new int[m * n];
            for (int i = 0; i < m; ++i) {
                for (int j = 0; j < n; ++j) {
                    if (grid[i][j] == '1') {
                        parent[i * n + j] = i * n + j;
                        ++count;
                    }
                    rank[i * n + j] = 0;
                }
            }
        }

        public int find(int i) {
            if (parent[i] != i) parent[i] = find(parent[i]);
            return parent[i];
        }

        public void union(int x, int y) {
            int rootx = find(x);
            int rooty = find(y);
            if (rootx != rooty) {
                if (rank[rootx] > rank[rooty]) {
                    parent[rooty] = rootx;
                } else if (rank[rootx] < rank[rooty]) {
                    parent[rootx] = rooty;
                } else {
                    parent[rooty] = rootx;
                    rank[rootx] += 1;
                }
                --count;
            }
        }

        public int getCount() {
            return count;
        }
    }

    public int numIslands(char[][] grid) {
        if (grid == null || grid.length == 0) {
            return 0;
        }

        int nr = grid.length;
        int nc = grid[0].length;
        int num_islands = 0;
        UnionFind uf = new UnionFind(grid);
        for (int r = 0; r < nr; ++r) {
            for (int c = 0; c < nc; ++c) {
                if (grid[r][c] == '1') {
                    grid[r][c] = '0';
                    if (r - 1 >= 0 && grid[r-1][c] == '1') {
                        uf.union(r * nc + c, (r-1) * nc + c);
                    }
                    if (r + 1 < nr && grid[r+1][c] == '1') {
                        uf.union(r * nc + c, (r+1) * nc + c);
                    }
                    if (c - 1 >= 0 && grid[r][c-1] == '1') {
                        uf.union(r * nc + c, r * nc + c - 1);
                    }
                    if (c + 1 < nc && grid[r][c+1] == '1') {
                        uf.union(r * nc + c, r * nc + c + 1);
                    }
                }
            }
        }

        return uf.getCount();
    }
}

  ```
  - 先初始化并查集，将所有陆地都看作是一个独立的岛屿，并初始化count为岛屿数量，初始化rank等级相同为0,也就是树的高度为0
  - 在for遍历中找到岛屿时，将当前岛屿置为0,将其四个方向的岛屿都union合并（其实可以只判断右和下，因为并查集的扩展只对当前节点的周围节点进行，FOR循环顺序遍历的情况下，向左和向上是多余操作）
  - 合并的逻辑是
    - 查找两个岛屿的根是否相同，在find函数中要递归调用find，直到找到find[i]=i,也就是找到根，因为只有根的parent才指向自己
      - 若不同，说明两个岛屿属于不同集合，意味着还没有合并，于是判断他们的rank,rank高的作为根，若rank相同，则随意选择一个作为根，并提升根的rank
    - 合并完成后将count--，即两个岛屿合并成一个


- 腐烂的橘子 
  #image("Screenshot_20251027_114114.png")
  - 多源广度优先搜索
  ```java
  class Solution {
    int[] dr = new int[]{-1, 0, 1, 0};
    int[] dc = new int[]{0, -1, 0, 1};

    public int orangesRotting(int[][] grid) {
        int R = grid.length, C = grid[0].length;
        Queue<Integer> queue = new ArrayDeque<Integer>();
        Map<Integer, Integer> depth = new HashMap<Integer, Integer>();
        for (int r = 0; r < R; ++r) {
            for (int c = 0; c < C; ++c) {
                if (grid[r][c] == 2) {
                    int code = r * C + c;
                    queue.add(code);
                    depth.put(code, 0);
                }
            }
        }
        int ans = 0;
        while (!queue.isEmpty()) {
            int code = queue.remove();
            int r = code / C, c = code % C;
            for (int k = 0; k < 4; ++k) {
                int nr = r + dr[k];
                int nc = c + dc[k];
                if (0 <= nr && nr < R && 0 <= nc && nc < C && grid[nr][nc] == 1) {
                    grid[nr][nc] = 2;
                    int ncode = nr * C + nc;
                    queue.add(ncode);
                    depth.put(ncode, depth.get(code) + 1);
                    ans = depth.get(ncode);
                }
            }
        }
        for (int[] row: grid) {
            for (int v: row) {
                if (v == 1) {
                    return -1;
                }
            }
        }
        return ans;
    }
}

  ```
  - 首先将所有腐烂的橘子入队列，作为多源广度优先搜索的起点，并将他们的深度初始化为0
  - 然后开始广度优先搜索，每次从队列中取出一个腐烂橘子，检查它的四个方向
    - 若发现有新鲜橘子，则将其腐烂，入队列，并将其深度设为当前橘子父节点深度+1
    - 每次更新答案为当前新腐烂橘子的深度
  - 最后遍历整个矩阵，若还有新鲜橘子，说明无法全部腐烂，返回-1
  - 否则返回答案

  - 注意，除数和取模都是对line
  - 对橘子四个方向遍历记得用新的局部变量，不能在原变量上修改，会污染原pos
  - 更新深度时是更新为父节点深度+1

- 课程表
  #image("Screenshot_20251031_104250.png")
  - 邻接表+深度优先搜索检测环
    ```java
    class Solution {
    List<List<Integer>> edges;
    int[] visited;
    boolean valid = true;

    public boolean canFinish(int numCourses, int[][] prerequisites) {
        edges = new ArrayList<List<Integer>>();
        for (int i = 0; i < numCourses; ++i) {
            edges.add(new ArrayList<Integer>());
        }
        visited = new int[numCourses];
        for (int[] info : prerequisites) {
            edges.get(info[1]).add(info[0]);
        }
        for (int i = 0; i < numCourses && valid; ++i) {
            if (visited[i] == 0) {
                dfs(i);
            }
        }
        return valid;
    }

    public void dfs(int u) {
        visited[u] = 1;
        for (int v: edges.get(u)) {
            if (visited[v] == 0) {
                dfs(v);
                if (!valid) {
                    return;
                }
            } else if (visited[v] == 1) {
                valid = false;
                return;
            }
        }
        visited[u] = 2;
    }
}

    ```
    - 全局初始化邻接表edges和访问数组visited，valid表示是否能完成课程
    - 使用Arraylist来存储是因为课程数目不定，使用list更灵活并且Arraylist支持索引查询，动态扩展
    - 遍历prerequisites，将先修课程和后续课程的关系存储在邻接表中，info[1]是先修课程，info[0]是后续课程
    - 然后遍历所有课程，若该课程未被访问过，则从该课程开始深度优先搜索
    - 在深度优先搜索中，先将当前课程标记为访问中（1），然后遍历该课程的所有后续课程
      - 若后续课程未被访问过，则递归深度优先搜索该后续课程
      - 若后续课程正在访问中（1），说明存在环，无法完成课程，标记valid为false并返回
    - 当所有后续课程都访问完后，将当前课程标记为访问完成（2）
    - 最后返回valid
    - Arraylist的访问是通过get(index)方法实现的

  - 广度优先搜索+入度表
  ```java 
  class Solution {
    List<List<Integer>> edges;
    int[] indeg;

    public boolean canFinish(int numCourses, int[][] prerequisites) {
        edges = new ArrayList<List<Integer>>();
        for (int i = 0; i < numCourses; ++i) {
            edges.add(new ArrayList<Integer>());
        }
        indeg = new int[numCourses];
        for (int[] info : prerequisites) {
            edges.get(info[1]).add(info[0]);
            ++indeg[info[0]];
        }

        Queue<Integer> queue = new LinkedList<Integer>();
        for (int i = 0; i < numCourses; ++i) {
            if (indeg[i] == 0) {
                queue.offer(i);
            }
        }

        int visited = 0;
        while (!queue.isEmpty()) {
            ++visited;
            int u = queue.poll();
            for (int v: edges.get(u)) {
                --indeg[v];
                if (indeg[v] == 0) {
                    queue.offer(v);
                }
            }
        }

        return visited == numCourses;
    }
}

  ```
  - 全局初始化邻接表edges和入度表indeg
  - 遍历prerequisites，将先修课程和后续课程的关系存储在邻接表中，并更新后续课程的入度
  - 然后初始化队列，将所有入度为0的课程入队
  - 然后开始广度优先搜索
    - 每次从队列中取出一个课程，访问次数加1
    - 然后遍历该课程的所有后续课程，将后续课程的入度减1
    - 若后续课程的入度变为0，则将其入队         
  - 最后判断访问次数是否等于课程总数，若相等则说明可以完成所有课程，返回true，否则返回false
  - 若入度表中找不到入度为0的课程，说明存在环，无法完成课程，返回false




- 前缀树
  #image("Screenshot_20251101_125955.png")
  ```java
    class Trie {
        private Trie[] children;
        private boolean isEnd;

        public Trie() {
            children = new Trie[26];
            isEnd = false;
        }
        
        public void insert(String word) {
            Trie node = this;
            for (int i = 0; i < word.length(); i++) {
                char ch = word.charAt(i);
                int index = ch - 'a';
                if (node.children[index] == null) {
                    node.children[index] = new Trie();
                }
                node = node.children[index];
            }
            node.isEnd = true;
        }
        
        public boolean search(String word) {
            Trie node = searchPrefix(word);
            return node != null && node.isEnd;
        }
        
        public boolean startsWith(String prefix) {
            return searchPrefix(prefix) != null;
        }

        private Trie searchPrefix(String prefix) {
            Trie node = this;
            for (int i = 0; i < prefix.length(); i++) {
                char ch = prefix.charAt(i);
                int index = ch - 'a';
                if (node.children[index] == null) {
                    return null;
                }
                node = node.children[index];
            }
            return node;
        }
    }


    ```
    - 前缀树的结构如下
    #image("Screenshot_20251101_130036.png")
    - 每个节点包含一个长度为26的子节点数组children，表示26个字母的子节点，以及一个布尔值isEnd，表示是否是一个单词的结尾
    - insert方法用于插入一个单词
      - 从根节点开始，遍历单词的每个字符
      - 计算字符对应的索引，若子节点数组中该索引位置为空，则创建一个新的Trie节点，若不为空则直接索引移动到子节点
      - 然后将当前节点移动到子节点
      - 遍历完单词后，将最后一个节点的isEnd标记为true
    - search方法用于搜索一个单词
      - 调用searchPrefix方法查找单词的最后一个节点
      - 若节点不为空且isEnd为true，则说明单词存在，返回true，否则返回false
    - startsWith方法用于检查是否存在以给定前缀开头的单词
      - 调用searchPrefix方法查找前缀的最后一个节点
      - 若节点不为空，则说明存在以该前缀开头的单词，返回true，否则返回false
    - searchPrefix方法用于查找给定前缀的最后一个节点
      - 从根节点开始，遍历前缀的每个字符
      - 计算字符对应的索引，若子节点数组中该索引位置为空，则返回null
      - 然后将当前节点移动到子节点
      - 遍历完前缀后，返回最后一个节点
    - Trie node = this 就是从根节点开始遍历，根节点为this，没有数据