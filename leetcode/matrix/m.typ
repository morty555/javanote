- 矩阵置零
  #image("Screenshot_20250924_203947.png")
  - 标记数组
    - 我们可以用两个标记数组分别记录每一行和每一列是否有零出现。
    - 具体地，我们首先遍历该数组一次，如果某个元素为 0，那么就将该元素所在的行和列所对应标记数组的位置置为 true。最后我们再次遍历该数组，用标记数组更新原数组即可。
  - 使用两个标记变量
    - 可以用矩阵的第一行和第一列代替方法一中的两个标记数组，以达到 O(1) 的额外空间。但这样会导致原数组的第一行和第一列被修改，无法记录它们是否原本包含 0。因此我们需要额外使用两个标记变量分别记录第一行和第一列是否原本包含 0。
  - 在实际代码中，我们首先预处理出两个标记变量，接着使用其他行与列去处理第一行与第一列，然后反过来使用第一行与第一列去更新其他行与列，最后使用两个标记变量更新第一行与第一列即可。
  - 使用一个标记变量
    - 我们可以对方法二进一步优化，只使用一个标记变量记录第一列是否原本存在 0。这样，第一列的第一个元素即可以标记第一行是否出现 0。但为了防止每一列的第一个元素被提前更新，我们需要从最后一行开始，倒序地处理矩阵元素。
    ```java 
        class Solution {
        public void setZeroes(int[][] matrix) {
            int m = matrix.length, n = matrix[0].length;
            boolean flagCol0 = false;
            for (int i = 0; i < m; i++) {
                if (matrix[i][0] == 0) {
                    flagCol0 = true;
                }
                for (int j = 1; j < n; j++) {
                    if (matrix[i][j] == 0) {
                        matrix[i][0] = matrix[0][j] = 0;
                    }
                }
            }
            for (int i = m - 1; i >= 0; i--) {
                for (int j = 1; j < n; j++) {
                    if (matrix[i][0] == 0 || matrix[0][j] == 0) {
                        matrix[i][j] = 0;
                    }
                }
                if (flagCol0) {
                    matrix[i][0] = 0;
                }
            }
        }
    }

    ```
    - 其实三个方法思路都一样，只是对于空间的优化
    - 两个变量其实就是用行列记录被覆盖的数，但是其实我们转换顺序就可以不被覆盖，因此只需要一个变量记录一个列的更新，行的更新只需要逆序修改就可以避免第一行的值被覆盖修改（因为原来对应列是否有0是通过每列第一个元素的记录的，行也一样，如果从头开始遍历，第一行的所有元素会因为matrix[0][0]是0而都变为0,也就是每一列第一个元素都变成0,如果原来记录的是1,即该列没有0,那对应的信息就丢掉了，因此要从末尾开始）

- 螺旋矩阵
 #image("Screenshot_20250925_112527.png")
  - 模拟
    - 按正常思路顺时针遍历，取一个和矩阵等大的visit数组记录已经被访问过的位置，设置一个二维数组direction,方向按顺时针排序
    - 遍历时先从第一个向右顺序遍历，其实就是将当前位置索引+direction的索引达到移动效果
    - 遇到边界或者visited为true则转换方向
    ```java
            class Solution {
            public List<Integer> spiralOrder(int[][] matrix) {
                List<Integer> order = new ArrayList<Integer>();
                if (matrix == null || matrix.length == 0 || matrix[0].length == 0) {
                    return order;
                }
                int rows = matrix.length, columns = matrix[0].length;
                boolean[][] visited = new boolean[rows][columns];
                int total = rows * columns;
                int row = 0, column = 0;
                int[][] directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};
                int directionIndex = 0;
                for (int i = 0; i < total; i++) {
                    order.add(matrix[row][column]);
                    visited[row][column] = true;
                    int nextRow = row + directions[directionIndex][0], nextColumn = column + directions[directionIndex][1];
                    if (nextRow < 0 || nextRow >= rows || nextColumn < 0 || nextColumn >= columns || visited[nextRow][nextColumn]) {
                        directionIndex = (directionIndex + 1) % 4;
                    }
                    row += directions[directionIndex][0];
                    column += directions[directionIndex][1];
                }
                return order;
            }
        }
    ```
  - 外层遍历
    - 将数组看成一层层，每次只对最外层进行遍历，可以省去visited数组
    ```java
    class Solution {
    public List<Integer> spiralOrder(int[][] matrix) {
        List<Integer> result = new ArrayList<>();
        int n = matrix[0].length;
        int m = matrix.length;
        int left =0;
        int right = n-1;
        int top = 0;
        int bottom = m-1;
        while(left<=right&&top<=bottom){
            for(int i=left;i<=right;i++){
                result.add(matrix[top][i]);
            }
            for(int i = top+1;i<=bottom;i++){
                result.add(matrix[i][right]);
            }
            if(left<right&&top<bottom){
                for(int i=right-1;i>=left;i--){
                    result.add(matrix[bottom][i]);
                }
                for(int i=bottom-1;i>top;i--){
                    result.add(matrix[i][left]);
                }
                
            }
            left++;
            right--;
            top++;
            bottom--;

        }
        return result;
    
    }
} 
    ```