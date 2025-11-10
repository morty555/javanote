- 有效的括号
  #image("Screenshot_20251106_104522.png")
  ```java
  class Solution {
    public boolean isValid(String s) {
        Deque<Character> stack = new LinkedList<>();
        int n = s.length();
         if (n % 2 == 1) {
            return false;
        }
        for(int i=0;i<n;i++){
            char a = s.charAt(i);
            if(a=='('||a=='{'||a=='['){
                stack.push(a);
            }else{
                if(stack.isEmpty()){
                    return false;
                }
                char b = stack.poll();
                if((b=='('&&a==')')||(b=='{'&&a=='}')||(b=='['&&a==']')){
                    
                }
                else{
                    return false;
                }
            }
        }
        if(!stack.isEmpty()){
            return false;
        }
        return true;
    }
}
  ```
  - 主要是栈的相关使用，要用Deque,LinkedList,和push,poll或pop，只能用push不能用offer,offer是插入到队尾，push是栈顶
  - 主要要一一对应，因为有三种括号


- 最小栈
  #image("Screenshot_20251106_111051.png")
  ```java
  class MinStack {
    Deque<Integer> xStack;
    Deque<Integer> minStack;

    public MinStack() {
        xStack = new LinkedList<Integer>();
        minStack = new LinkedList<Integer>();
        minStack.push(Integer.MAX_VALUE);
    }
    
    public void push(int x) {
        xStack.push(x);
        minStack.push(Math.min(minStack.peek(), x));
    }
    
    public void pop() {
        xStack.pop();
        minStack.pop();
    }
    
    public int top() {
        return xStack.peek();
    }
    
    public int getMin() {
        return minStack.peek();
    }
}

  ```
  - 辅助栈
  - 每次PUSH的时候，也push元素到最小栈，push到最小栈的元素是最小栈头部的最小值和push的元素的最小值
  - 这样就记录了每一次push的当前最小元素，即使stack的元素被pop掉了也有记录


- 字符串解码
  - 栈操作
  ```java
  class Solution {
    int ptr;

    public String decodeString(String s) {
        LinkedList<String> stk = new LinkedList<String>();
        ptr = 0;

        while (ptr < s.length()) {
            char cur = s.charAt(ptr);
            if (Character.isDigit(cur)) {
                // 获取一个数字并进栈
                String digits = getDigits(s);
                stk.addLast(digits);
            } else if (Character.isLetter(cur) || cur == '[') {
                // 获取一个字母并进栈
                stk.addLast(String.valueOf(s.charAt(ptr++))); 
            } else {
                ++ptr;
                LinkedList<String> sub = new LinkedList<String>();
                while (!"[".equals(stk.peekLast())) {
                    sub.addLast(stk.removeLast());
                }
                Collections.reverse(sub);
                // 左括号出栈
                stk.removeLast();
                // 此时栈顶为当前 sub 对应的字符串应该出现的次数
                int repTime = Integer.parseInt(stk.removeLast());
                StringBuffer t = new StringBuffer();
                String o = getString(sub);
                // 构造字符串
                while (repTime-- > 0) {
                    t.append(o);
                }
                // 将构造好的字符串入栈
                stk.addLast(t.toString());
            }
        }

        return getString(stk);
    }

    public String getDigits(String s) {
        StringBuffer ret = new StringBuffer();
        while (Character.isDigit(s.charAt(ptr))) {
            ret.append(s.charAt(ptr++));
        }
        return ret.toString();
    }

    public String getString(LinkedList<String> v) {
        StringBuffer ret = new StringBuffer();
        for (String s : v) {
            ret.append(s);
        }
        return ret.toString();
    }
}

  ```
    - ptr记录当前遍历string的索引
    - 遍历string,判断每次遍历到的是数字，字母（左括号），还是右括号
    - 如果是数字，则先不入栈，从当前数字位置向后遍历，获得完整的数字再入栈
    - 如果是字母（左括号），直接入栈
    - 遇到右括号后，右括号不入栈，开始将之前的元素出栈，之前的元素如果是字母的，就一直出栈存储在另外一个栈上，此时栈的顺序和string顺序是相反的
    - 遇到左括号后，将左括号出栈，现在栈顶一定是数字
    - 将暂存字母的栈翻转得到原来顺序，然后拼接成一个string,根据现在栈顶的数字while遍历构造新的字符串放入栈
    - 循环以上流程直到ptr遍历到string末尾
    - 将主栈转成string输出


  - 递归法




- 每日温度
  #image("Screenshot_20251107_103930.png")
  - 单调栈
  ```java
  class Solution {
    public int[] dailyTemperatures(int[] temperatures) {
        int length = temperatures.length;
        int[] ans = new int[length];
        Deque<Integer> stack = new LinkedList<Integer>();
        for (int i = 0; i < length; i++) {
            int temperature = temperatures[i];
            while (!stack.isEmpty() && temperature > temperatures[stack.peek()]) {
                int prevIndex = stack.pop();
                ans[prevIndex] = i - prevIndex;
            }
            stack.push(i);
        }
        return ans;
    }
}
  ```
  - 定义结果数组，和索引栈
  - 遍历温度数组，有两种可能
    - 当前温度比栈顶温度大
      - 将栈顶索引抛出
      - 将该索引对应的结果数组位置值赋为i-index,即当前位置减去索引位置，也就是第几日后获得更大温度
    - 当前温度比栈顶温度小
      - 直接入栈
      - 等待下一个比该温度大的值将该索引取出并比较赋值给结果数组

- 柱状图中最大的矩形
  #image("Screenshot_20251107_123846.png")
  ```java
  class Solution {
    public int largestRectangleArea(int[] heights) {
        int n = heights.length;
        int[] left = new int[n];
        int[] right = new int[n];
        int max = Integer.MIN_VALUE;
        Deque<Integer> stack = new ArrayDeque<>();
        for(int i=0;i<n;i++){
            while(!stack.isEmpty()&&heights[i]<=heights[stack.peek()]){
                 stack.pop(); 
            }
            left[i]=!stack.isEmpty()?stack.peek() :(-1);
            stack.push(i);
        }
        stack.clear();
        for(int i=n-1;i>=0;i--){
            while(!stack.isEmpty()&&heights[i]<=heights[stack.peek()]){
                stack.pop();
            }
            right[i]=!stack.isEmpty()?stack.peek():(n);
            stack.push(i);
        }
        for(int i=0;i<n;i++){
            max = Math.max(max,(right[i]-left[i]-1)*heights[i]);
        }
        return max;
    }
}
  ```
    - 分别从左往右和从右往左遍历一次，得到heights数组每个索引处的左右边界（即比自己大的高度能延伸到哪）
        - 只要看当前栈的高度大小和数组所在数的大小相比
        - 若无法延伸，即当前位置大于栈顶高度，就不用将上一个元素出栈，因为该元素就为当前位置的边界了
        - 若可以延伸，就移除栈顶，因为栈顶位置不是当前节点的边界，一直到无法延伸为止
    - 最后遍历一遍计算max即可
    - 注意左右边界计算中间要clear栈，因为可能会有残留

  - 一次遍历方法
  ```java
  class Solution {
    public int largestRectangleArea(int[] heights) {
        int n = heights.length;
        int[] left = new int[n];
        int[] right = new int[n];
        Arrays.fill(right,n);
        int max = Integer.MIN_VALUE;
        Deque<Integer> stack = new ArrayDeque<>();
        for(int i=0;i<n;i++){
            while(!stack.isEmpty()&&heights[i]<=heights[stack.peek()]){
                 right[stack.peek()]= i;
                 stack.pop();
            }
            left[i]=!stack.isEmpty()?stack.peek() :(-1);
            stack.push(i);
        }
      
        for(int i=0;i<n;i++){
            max = Math.max(max,(right[i]-left[i]-1)*heights[i]);
        }
        return max;
    }
}
  ```   