- 手撕sql，表结构：name,course,score 代表学生，课程名，成绩。需要查询出两门课程大雨80分的学生。
  ```
  SELECT
    name
FROM
    student
WHERE
    score > 80
GROUP BY
    name
HAVING
    COUNT(*) >= 2;

  ```
  - 先过滤出 score > 80 的记录
  - 按 name 分组
  - 统计每个 name 满足条件的课程数 >= 2