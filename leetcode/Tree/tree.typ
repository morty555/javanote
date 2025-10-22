- 中序遍历 
  - 递归
    - 注意空节点返回空数组
  - 迭代
    - 用栈存储节点，先遍历完左子树再到右子树
  - morris中序遍历
    ```java
    class Solution {
    public List<Integer> inorderTraversal(TreeNode root) {
        List<Integer> res = new ArrayList<Integer>();
        TreeNode predecessor = null;

        while (root != null) {
            if (root.left != null) {
                // predecessor 节点就是当前 root 节点向左走一步，然后一直向右走至无法走为止
                predecessor = root.left;
                while (predecessor.right != null && predecessor.right != root) {
                    predecessor = predecessor.right;
                }
                
                // 让 predecessor 的右指针指向 root，继续遍历左子树
                if (predecessor.right == null) {
                    predecessor.right = root;
                    root = root.left;
                }
                // 说明左子树已经访问完了，我们需要断开链接
                else {
                    res.add(root.val);
                    predecessor.right = null;
                    root = root.right;
                }
            }
            // 如果没有左孩子，则直接访问右孩子
            else {
                res.add(root.val);
                root = root.right;
            }
        }
        return res;
    }
}

    ```
    - 每次先将根节点的左子树的最右节点的next指向根节点自己
    - 作用是，当发现遍历到的节点指向根节点后，就知道该根节点的左子树遍历完了
    - 或者是当根节点的左节点为空，可以通过该节点的右节点回到根部，下次遍历pre时发现左子树的最右节点不为空，则意味着左子树已经遍历完并回到根节点自身了，可以输出自己并遍历右子树，于是去除pre.right,同时root指向右节点开始遍历右子树

- 二叉树的最大深度
  #image("Screenshot_20251015_191702.png")
  - 深度优先
    - 递归
    ```java
    class Solution {
    public int maxDepth(TreeNode root) {
        if (root == null) {
            return 0;
        } else {
            int leftHeight = maxDepth(root.left);
            int rightHeight = maxDepth(root.right);
            return Math.max(leftHeight, rightHeight) + 1;
        }
    }
}


    ```
  - 广度优先
    ```java
    class Solution {
    public int maxDepth(TreeNode root) {
        if (root == null) {
            return 0;
        }
        Queue<TreeNode> queue = new LinkedList<TreeNode>();
        queue.offer(root);
        int ans = 0;
        while (!queue.isEmpty()) {
            int size = queue.size();
            while (size > 0) {
                TreeNode node = queue.poll();
                if (node.left != null) {
                    queue.offer(node.left);
                }
                if (node.right != null) {
                    queue.offer(node.right);
                }
                size--;
            }
            ans++;
        }
        return ans;
    }
}

    ```
    - 从根节点开始，将所有节点放入链表
    - 只要链表不为空，就将链表内的节点拿出来，放入他们的子节点，每次经历一次这个流程就深度+1

- 翻转二叉树
  #image("Screenshot_20251015_192536.png")
  - 递归
    ```java
    class Solution {
    public TreeNode invertTree(TreeNode root) {
        if (root == null) {
            return null;
        }
        TreeNode left = invertTree(root.left);
        TreeNode right = invertTree(root.right);
        root.left = right;
        root.right = left;
        return root;
    }
}

    ```
    - 只要把根节点的两个子树交换即可
    - 因此直接递归到最深处，左右子树都为null交换没问题
    - 接着就就是从底到root不断change


- 对称二叉树
  #image("Screenshot_20251015_194348.png")
  - 递归
    ```java
    class Solution {
    public boolean isSymmetric(TreeNode root) {
        return check(root.left, root.right);
    }

    public boolean check(TreeNode p, TreeNode q) {
        if (p == null && q == null) {
            return true;
        }
        if (p == null || q == null) {
            return false;
        }
        return p.val == q.val && check(p.left, q.right) && check(p.right, q.left);
    }
}

    ```
- 迭代
  ```java
  class Solution {
    public boolean isSymmetric(TreeNode root) {
        return check(root, root);
    }

    public boolean check(TreeNode u, TreeNode v) {
        Queue<TreeNode> q = new LinkedList<TreeNode>();
        q.offer(u);
        q.offer(v);
        while (!q.isEmpty()) {
            u = q.poll();
            v = q.poll();
            if (u == null && v == null) {
                continue;
            }
            if ((u == null || v == null) || (u.val != v.val)) {
                return false;
            }

            q.offer(u.left);
            q.offer(v.right);

            q.offer(u.right);
            q.offer(v.left);
        }
        return true;
    }
}

  ```
  - 也是利用queue
  - 每次都把左右节点按对称顺序放入
  - 这样顺序取出的时候就可以直接匹配
  - 注意这里和递归不一样，递归两个为null的时候return true是因为递归需要每层下来都返回true直到root
  - 而迭代需要所有check结束到跳出while循环才意味着所有都一样，因此是continue

- 二叉树的直径
  #image("Screenshot_20251017_154657.png")
  ```java
  class Solution {
    int ans;
    public int diameterOfBinaryTree(TreeNode root) {
        ans = 1;
        depth(root);
        return ans - 1;
    }
    public int depth(TreeNode node) {
        if (node == null) {
            return 0; // 访问到空节点了，返回0
        }
        int L = depth(node.left); // 左儿子为根的子树的深度
        int R = depth(node.right); // 右儿子为根的子树的深度
        ans = Math.max(ans, L+R+1); // 计算d_node即L+R+1 并更新ans
        return Math.max(L, R) + 1; // 返回该节点为根的子树的深度
    }
}

  ```
  - 对每个节点都判断左子树+右子树的深度和
  - 用额外全局变量ans记录当前节点最大路径的节点数，也就是该节点左子树最大深度+右子树最大深度+1
  - depth的返回值记录以该节点为根的深度最大值，根据递归每层都计算出每个节点的深度最大值。

- 二叉树的层序遍历
  #image("Screenshot_20251018_102733.png")
  ```java
  class Solution {
    public List<List<Integer>> levelOrder(TreeNode root) {
        List<List<Integer>> ret = new ArrayList<List<Integer>>();
        if (root == null) {
            return ret;
        }

        Queue<TreeNode> queue = new LinkedList<TreeNode>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            List<Integer> level = new ArrayList<Integer>();
            int currentLevelSize = queue.size();
            for (int i = 1; i <= currentLevelSize; ++i) {
                TreeNode node = queue.poll();
                level.add(node.val);
                if (node.left != null) {
                    queue.offer(node.left);
                }
                if (node.right != null) {
                    queue.offer(node.right);
                }
            }
            ret.add(level);
        }
        
        return ret;
    }
}
    ```
    - 每次将一层的节点放入queue中
    - 读出来然后加入到level数组里
    - 每次for循环遍历完就将level数组加入res
    - 注意，不能将null放入queue,如果到最后一层为空，而把null添加到queue中的话，最后一层会生成空level导致错误
    - 一定要用queue,不能用list之类的，queue实现了poll和offer,可以实现先进先出，而list的remove和get要index
    - 也可以用用deque接收arrayDeque

- 将有序数组转换为二叉搜索树
  #image("Screenshot_20251018_104434.png")
  ```java 
  class Solution {
    public TreeNode sortedArrayToBST(int[] nums) {
        return helper(nums, 0, nums.length - 1);
    }

    public TreeNode helper(int[] nums, int left, int right) {
        if (left > right) {
            return null;
        }

        // 总是选择中间位置左边的数字作为根节点
        int mid = (left + right) / 2;

        TreeNode root = new TreeNode(nums[mid]);
        root.left = helper(nums, left, mid - 1);
        root.right = helper(nums, mid + 1, right);
        return root;
    }
}

  ```
  - 不一定要选mid左边的为root,mid右的也可以


- 验证二叉搜索树
  #image("Screenshot_20251020_094713.png")
  - 递归
    ```java
    class Solution {
    public boolean isValidBST(TreeNode root) {
        return isValidBST(root, Long.MIN_VALUE, Long.MAX_VALUE);
    }

    public boolean isValidBST(TreeNode node, long lower, long upper) {
        if (node == null) {
            return true;
        }
        if (node.val <= lower || node.val >= upper) {
            return false;
        }
        return isValidBST(node.left, lower, node.val) && isValidBST(node.right, node.val, upper);
    }
}

    ```
    - 一开始初始最小值和最大值为min和max都为极限值
    - 设计函数，传入节点，该节点要小于的值和该节点要大于的值
    - 如果传入的是当前节点的左节点，要小于的值修改为root.val,要大于的值不变，右节点类似
    - 这样节点只需要和他的root比较就可以


  - 中序遍历
    ```java
    class Solution {
    public boolean isValidBST(TreeNode root) {
        Deque<TreeNode> stack = new LinkedList<TreeNode>();
        double inorder = -Double.MAX_VALUE;

        while (!stack.isEmpty() || root != null) {
            while (root != null) {
                stack.push(root);
                root = root.left;
            }
            root = stack.pop();
              // 如果中序遍历得到的节点的值小于等于前一个 inorder，说明不是二叉搜索树
            if (root.val <= inorder) {
                return false;
            }
            inorder = root.val;
            root = root.right;
        }
        return true;
    }
}
 
    ```
    - 二叉搜索树的中序遍历一定是顺序的
    - 利用inorder存储上一个节点的值
    - 中序遍历的每个节点都和上一个inorder比较即可


-  二叉搜索树中第 K 小的元素
   #image("Screenshot_20251020_100545.png")
   - 中序遍历 
     ```java
     class Solution {
    public int kthSmallest(TreeNode root, int k) {
        Deque<TreeNode> stack = new ArrayDeque<TreeNode>();
        while (root != null || !stack.isEmpty()) {
            while (root != null) {
                stack.push(root);
                root = root.left;
            }
            root = stack.pop();
            --k;
            if (k == 0) {
                break;
            }
            root = root.right;
        }
        return root.val;
    }
}

     ```
     - 利用二叉搜素树中序遍历顺序的性质，中序遍历的同时k--，即可找到第k小的元素
    
    - 也是利用二叉搜索树中序遍历顺序的性质，记录每个节点的子树节点数，利用hashmap O（1）存储  
      - 然后从根节点开始判断左子树的子树节点数
        - 如果小于k-1说明不在左子树
        - 如果等于k说明是当前节点
        - 否则就在右子树
    - 通过不断遍历直到找到第k小元素
    


    - AVL树，比二叉搜索树更平衡，搜索效率更高


- 二叉树的右视图
  #image("Screenshot_20251021_100819.png")
  - 深度遍历 
    ```java
    class Solution {
    public List<Integer> rightSideView(TreeNode root) {
        Map<Integer, Integer> rightmostValueAtDepth = new HashMap<Integer, Integer>();
        int max_depth = -1;

        Deque<TreeNode> nodeStack = new LinkedList<TreeNode>();
        Deque<Integer> depthStack = new LinkedList<Integer>();
        nodeStack.push(root);
        depthStack.push(0);

        while (!nodeStack.isEmpty()) {
            TreeNode node = nodeStack.pop();
            int depth = depthStack.pop();

            if (node != null) {
            	// 维护二叉树的最大深度
                max_depth = Math.max(max_depth, depth);

                // 如果不存在对应深度的节点我们才插入
                if (!rightmostValueAtDepth.containsKey(depth)) {
                    rightmostValueAtDepth.put(depth, node.val);
                }

                nodeStack.push(node.left);
                nodeStack.push(node.right);
                depthStack.push(depth + 1);
                depthStack.push(depth + 1);
            }
        }

        List<Integer> rightView = new ArrayList<Integer>();
        for (int depth = 0; depth <= max_depth; depth++) {
            rightView.add(rightmostValueAtDepth.get(depth));
        }

        return rightView;
    }
}

    ```
    - 用一个栈维护深度，一个栈维护节点
    - 每次取出两个栈顶节点后，维护最大深度，同时判断从深度栈顶取出的深度在哈希表中是否有key,如果有说明该node已经不是最右侧的了
    - 如果没有说明该深度是第一次put,是最右侧的
    - 更新栈元素时，先push左节点，再push右节点，这样从栈中取出来的一定是优先右子树的元素
    - 最后用维护的最大深度，遍历哈希表将元素放入结果链表返回

  - 广度遍历 
    - 用队列，先进先出，先放左节点，这样右节点是最后被拿到的
  - Queue是只能一端进一端出
  - Deque是双端队列，两端都可进可出，Deque也常用作栈

- 二叉树展开为链表
  #image("Screenshot_20251022_095721.png")
  - 前序遍历
    - 先将链表前序遍历的结果放到list
    - 再for循环接到root的右节点

  - 前序遍历和展开同步进行
    - 上一个方法需要分开执行
    - 这个方法我们遍历和展开同时进行
    ```java
    class Solution {
    public void flatten(TreeNode root) {
        if (root == null) {
            return;
        }
        Deque<TreeNode> stack = new LinkedList<TreeNode>();
        stack.push(root);
        TreeNode prev = null;
        while (!stack.isEmpty()) {
            TreeNode curr = stack.pop();
            if (prev != null) {
                prev.left = null;
                prev.right = curr;
            }
            TreeNode left = curr.left, right = curr.right;
            if (right != null) {
                stack.push(right);
            }
            if (left != null) {
                stack.push(left);
            }
            prev = curr;
        }
    }
}

    ```
    - 用栈存储节点，先遍历完左子树再到右子树
    - 每次用pre记录上一个节点，这样前序遍历到下一个节点的时候可以直接拿上一个节点的left=null,right=当前节点来更新二叉树为链表
    - 不用担心right更改后指针丢失的问题，因为已经用栈存储了右子树的根节点

  - 方法三：寻找前驱节点
    - 注意到前序遍历访问各节点的顺序是根节点、左子树、右子树。如果一个节点的左子节点为空，则该节点不需要进行展开操作。如果一个节点的左子节点不为空，则该节点的左子树中的最后一个节点被访问之后，该节点的右子节点被访问。该节点的左子树中最后一个被访问的节点是左子树中的最右边的节点，也是该节点的前驱节点。因此，问题转化成寻找当前节点的前驱节点。
    - 其实思路就是，因为前序遍历每次都是按照根->左->右的顺序，那左子树遍历完就到右子树，即左子树遍历到最右节点就到右子树，因此我们只要把每个节点r的左子树的最右节点移动到r右子树之前，再把r的右指针指向r的左孩子，左指针指向空即可


- 从前序与中序遍历序列构造二叉树
  #image("Screenshot_20251022_123226.png")
  - 方法一：递归
    ```java
    class Solution {
    private Map<Integer, Integer> indexMap;

    public TreeNode myBuildTree(int[] preorder, int[] inorder, int preorder_left, int preorder_right, int inorder_left, int inorder_right) {
        if (preorder_left > preorder_right) {
            return null;
        }

        // 前序遍历中的第一个节点就是根节点
        int preorder_root = preorder_left;
        // 在中序遍历中定位根节点
        int inorder_root = indexMap.get(preorder[preorder_root]);
        
        // 先把根节点建立出来
        TreeNode root = new TreeNode(preorder[preorder_root]);
        // 得到左子树中的节点数目
        int size_left_subtree = inorder_root - inorder_left;
        // 递归地构造左子树，并连接到根节点
        // 先序遍历中「从 左边界+1 开始的 size_left_subtree」个元素就对应了中序遍历中「从 左边界 开始到 根节点定位-1」的元素
        root.left = myBuildTree(preorder, inorder, preorder_left + 1, preorder_left + size_left_subtree, inorder_left, inorder_root - 1);
        // 递归地构造右子树，并连接到根节点
        // 先序遍历中「从 左边界+1+左子树节点数目 开始到 右边界」的元素就对应了中序遍历中「从 根节点定位+1 到 右边界」的元素
        root.right = myBuildTree(preorder, inorder, preorder_left + size_left_subtree + 1, preorder_right, inorder_root + 1, inorder_right);
        return root;
    }

    public TreeNode buildTree(int[] preorder, int[] inorder) {
        int n = preorder.length;
        // 构造哈希映射，帮助我们快速定位根节点
        indexMap = new HashMap<Integer, Integer>();
        for (int i = 0; i < n; i++) {
            indexMap.put(inorder[i], i);
        }
        return myBuildTree(preorder, inorder, 0, n - 1, 0, n - 1);
    }
}

    ```
    - hashmap存储中序遍历数组节点，value是key,节点是index
    - 前序遍历第一个节点是root,可以在hashmap中找到root对应的索引
    - 计算左子树节点个数
    - 先建立root节点
    - 通过root节点递归，root.left代入前序遍历左半边的范围，即从左边界到左边界+左子树节点个数，中序遍历则是从根节点index向左拓展到左边界
    - root.right类似 前序遍历代入左边界+左子树个数+1到前序遍历右边界，中序遍历代入rootindex+1到中序遍历右边界

  - 迭代




- 路径总和 III
  #image("Screenshot_20251022_153911.png")
  - 深度优先搜索
    ```java
    class Solution {
    public int pathSum(TreeNode root, long targetSum) {
        if (root == null) {
            return 0;
        }

        int ret = rootSum(root, targetSum);
        ret += pathSum(root.left, targetSum);
        ret += pathSum(root.right, targetSum);
        return ret;
    }

    public int rootSum(TreeNode root, long targetSum) {
        int ret = 0;

        if (root == null) {
            return 0;
        }
        int val = root.val;
        if (val == targetSum) {
            ret++;
        } 

        ret += rootSum(root.left, targetSum - val);
        ret += rootSum(root.right, targetSum - val);
        return ret;
    }
}

    ```
    - 遍历每个节点，判断以节点为root向下遍历是否存在相加为targetSum的节点组

  - 前序遍历 + 回溯 + 前缀和
    ```java
    class Solution {
    public int pathSum(TreeNode root, int targetSum) {
        Map<Long, Integer> prefix = new HashMap<Long, Integer>();
        prefix.put(0L, 1);
        return dfs(root, prefix, 0, targetSum);
    }

    public int dfs(TreeNode root, Map<Long, Integer> prefix, long curr, int targetSum) {
        if (root == null) {
            return 0;
        }

        int ret = 0;
        curr += root.val;

        ret = prefix.getOrDefault(curr - targetSum, 0);
        prefix.put(curr, prefix.getOrDefault(curr, 0) + 1);
        ret += dfs(root.left, prefix, curr, targetSum);
        ret += dfs(root.right, prefix, curr, targetSum);
        prefix.put(curr, prefix.getOrDefault(curr, 0) - 1);

        return ret;
    }
}

    ```
    - 用hashmap记录一条链路上出现前缀和的次数
    - 前序遍历，确保遍历所得到的前缀和处在一条链路上
    - 每次判断所遍历节点前缀和（包括该节点）-targetSum在之前是否出现过（hashmap中以curr-targetNum为key的值），若有则添加到ret
    - 若当前节点左右子树都已经遍历完，回溯，去除该节点在hashmap中的前缀和，避免污染其他路径的前缀和数据

- 