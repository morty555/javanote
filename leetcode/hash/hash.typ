+ 哈希
  - 两数之和
    #image("Screenshot_20250816_220007.png")
    - 枚举
    - 哈希
      - 由于我们要得到的是数组索引，而hashmap只有getkey,所以我们可以以nums[i]作为key找i
      - 将put操作放到比较后，这样可保证不选择重复元素，因为每次都是从后往前找，而此时的nums[i]还不在hashmap中
    ```java
      class Solution {
        public int[] twoSum(int[] nums, int target) {
            Map<Integer, Integer> hashtable = new HashMap<Integer, Integer>();
            for (int i = 0; i < nums.length; ++i) {
                if (hashtable.containsKey(target - nums[i])) {
                    return new int[]{hashtable.get(target - nums[i]), i};
                }
                hashtable.put(nums[i], i);
            }
            return new int[0];
        }
    }

    ```
  - 字母异位词分组
    #image("Screenshot_20250819_225958.png")
    - 排序
      - 异位词排序后得到string一样
      - 先用char数组接收，因为arrays有sort的api
      - 再转回string作为key存到哈希表
      - 然后返回哈希表的values
      - 时间复杂度：每个字符串都要sort，这里复杂度为klogk,k为字符串长度，一共有n个字符串，所以复杂度为nklogk
      - 空间复杂度：哈希表存储nk
      ```java 
            class Solution {
          public List<List<String>> groupAnagrams(String[] strs) {
              Map<String, List<String>> map = new HashMap<String, List<String>>();
              for (String str : strs) {
                  char[] array = str.toCharArray();
                  Arrays.sort(array);
                  String key = new String(array);
                  List<String> list = map.getOrDefault(key, new ArrayList<String>());
                  list.add(str);
                  map.put(key, list);
              }
              return new ArrayList<List<String>>(map.values());
          }
      }

    ```
    - 计数
      - 由于互为字母异位词的两个字符串包含的字母相同，因此两个字符串中的相同字母出现的次数一定是相同的，故可以将每个字母出现的次数使用字符串表示，作为哈希表的键。
      - 由于字符串只包含小写字母，因此对于每个字符串，可以使用长度为 26 的数组记录每个字母出现的次数。
    ```java
        class Solution {
        public List<List<String>> groupAnagrams(String[] strs) {
            Map<String, List<String>> map = new HashMap<String, List<String>>();
            for (String str : strs) {
                int[] counts = new int[26];
                int length = str.length();
                for (int i = 0; i < length; i++) {
                    counts[str.charAt(i) - 'a']++;
                }
                // 将每个出现次数大于 0 的字母和出现次数按顺序拼接成字符串，作为哈希表的键
                StringBuffer sb = new StringBuffer();
                for (int i = 0; i < 26; i++) {
                    if (counts[i] != 0) {
                        sb.append((char) ('a' + i));
                        sb.append(counts[i]);
                    }
                }
                String key = sb.toString();
                List<String> list = map.getOrDefault(key, new ArrayList<String>());
                list.add(str);
                map.put(key, list);
            }
            return new ArrayList<List<String>>(map.values());
        }
    }

    ```
    - 增强for循环要求对象是
      + 数组（如 char[]、int[] 等）
      + 实现了 Iterable 接口的集合（如 List<Character>、Set<String> 等）
      - 而 String 只实现了 CharSequence，没有实现 Iterable。
    - Java 没有 Char 类型（首字母大写），应该是小写 char。
    - strs.charAt(i) 是单个字符，strs 是 String[]，strs[i] 是一个 String，strs[i].charAt(j) 才能获取单个字符。不是数组或集合想用增强 for 循环遍历字符串的每个字符，正确写法是：
    ```java
    for (char c : strs[i].toCharArray()) {
    // c 就是当前字符
     }
    ```
    - 数组用 .length，集合用 .size()，string用length（）
    - 对于26字母数组，记得在索引处对str.charAt（i）加减a以符合数组索引
    - stringbuffer可变长度，可用apeend，线程安全，可换stringbuilder提升性能
    - new对象不能是抽象类，List 是接口（interface），不能直接 new List<>()，在 Java 中，List 是抽象类型，不能实例化，你必须实例化它的 实现类，比如 ArrayList 或 LinkedList。
  - 最长连续序列
    #image("Screenshot_20250820_214045.png")
    - 将数组里的数字放到hashset中
    - 第二次遍历时遍历hashset而不是原数组，hashset可以去重减少复杂度，遍历每一个元素去找x+1,x+2等等，记录times
    - 外层维护一个ans节点，比较每个元素的times和ans取max
    - 但是这里依然有重复的情况，因为要遍历每个元素，但是明显可知，如1,2,3,4，5这个序列，2及其以后的数是不用在遍历的了
    - 因此可以判断hashset中是否存在x-1来减少遍历次数，因此数组中的每个数只会进入内层循环一次
    ```java 
    class Solution {
    public int longestConsecutive(int[] nums) {
        Set<Integer> hashset = new HashSet<>();
        for(int num:nums){
            hashset.add(num);
        }
        int ans =0;
        for(int num:hashset){
            if(!hashset.contains(num-1)){
                int currentNum = num;
                int times = 1;
                while(hashset.contains(currentNum+1)){
                    currentNum = currentNum+1;
                    times = times +1;
                }
               ans = Math.max(ans,times);
            }
            
        }
        return ans;
    }
}
    ```