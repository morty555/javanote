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