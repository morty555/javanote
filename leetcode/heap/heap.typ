- 数组中的第K个最大元素
  #image("Screenshot_20251108_115031.png")
  - 快排
  ```java
  class Solution {
    int quickselect(int[] nums, int l, int r, int k) {
        if (l == r) return nums[k];
        int x = nums[l], i = l - 1, j = r + 1;
        while (i < j) {
            do i++; while (nums[i] < x);
            do j--; while (nums[j] > x);
            if (i < j){
                int tmp = nums[i];
                nums[i] = nums[j];
                nums[j] = tmp;
            }
        }
        if (k <= j) return quickselect(nums, l, j, k);
        else return quickselect(nums, j + 1, r, k);
    }
    public int findKthLargest(int[] _nums, int k) {
        int n = _nums.length;
        return quickselect(_nums, 0, n - 1, n - k);
    }
}

  ```
    - 快速排序每次能确定用于比较的元素的位置（x）
    - 那只要每次分治快排不断让x的索引逼近k即可

  - 堆排序
  ```java
  class Solution {
    public int findKthLargest(int[] nums, int k) {
        int heapSize = nums.length;
        buildMaxHeap(nums, heapSize);
        for (int i = nums.length - 1; i >= nums.length - k + 1; --i) {
            swap(nums, 0, i);
            --heapSize;
            maxHeapify(nums, 0, heapSize);
        }
        return nums[0];
    }

    public void buildMaxHeap(int[] a, int heapSize) {
        for (int i = heapSize / 2 - 1; i >= 0; --i) {
            maxHeapify(a, i, heapSize);
        } 
    }

    public void maxHeapify(int[] a, int i, int heapSize) {
        int l = i * 2 + 1, r = i * 2 + 2, largest = i;
        if (l < heapSize && a[l] > a[largest]) {
            largest = l;
        } 
        if (r < heapSize && a[r] > a[largest]) {
            largest = r;
        }
        if (largest != i) {
            swap(a, i, largest);
            maxHeapify(a, largest, heapSize);
        }
    }

    public void swap(int[] a, int i, int j) {
        int temp = a[i];
        a[i] = a[j];
        a[j] = temp;
    }
}

  ```
    - 建堆 
      - 从最后一个非叶子节点开始，以数组的初始叶子节点为底向上建堆
        - 从最后一个开始可以避免重复堆化中间层，效率高
      - 建堆思路，也就是比较当前节点和孩子节点的大小，选择最大的替换作为根节点，然后对替换的孩子节点的子树下沉判断堆化
    - 对建好的堆，将堆顶换到最后，然后将堆的大小减少，也就是对除了最大值以外的堆重新堆化，重复k-1次，这样第k大的节点就移到堆顶了，此时数组末尾应该是前k大节点，不是顺序



- 前 K 个高频元素
  #image("Screenshot_20251110_001126.png")
  - 堆
  ```java
  class Solution {
    public int[] topKFrequent(int[] nums, int k) {
        Map<Integer, Integer> occurrences = new HashMap<Integer, Integer>();
        for (int num : nums) {
            occurrences.put(num, occurrences.getOrDefault(num, 0) + 1);
        }

        // int[] 的第一个元素代表数组的值，第二个元素代表了该值出现的次数
        PriorityQueue<int[]> queue = new PriorityQueue<int[]>(new Comparator<int[]>() {
            public int compare(int[] m, int[] n) {
                return m[1] - n[1];
            }
        });
        for (Map.Entry<Integer, Integer> entry : occurrences.entrySet()) {
            int num = entry.getKey(), count = entry.getValue();
            if (queue.size() == k) {
                if (queue.peek()[1] < count) {
                    queue.poll();
                    queue.offer(new int[]{num, count});
                }
            } else {
                queue.offer(new int[]{num, count});
            }
        }
        int[] ret = new int[k];
        for (int i = 0; i < k; ++i) {
            ret[i] = queue.poll()[0];
        }
        return ret;
    }
}

  ```
    - 用优先队列存储数组，每个数组有两个元素，一个是数，一个是数出现的频率，并实现一个比较器
    - 用哈希表先存储数组中出现的数和次数
    - 遍历哈希表，前k个数及其频率直接放到优先队列中，第k+1个开始，每次判断优先队列顶端的数的频率和当前数的频率大小关系，并进行替换
    - 最后遍历优先队列放入结果数组输出结果
    - 最后的遍历记得要用k不能用queue,size（），因为poll后size会变化