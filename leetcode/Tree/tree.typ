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
