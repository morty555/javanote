- git想切换分支然后不想提交代码怎么解决   
  - git stash
    - 把改动临时存起来，切换完分支后再取出来。
    - 假设现在在dev修改代码
    - 这时你修改了几个文件，但还没提交
    - 然后你想切到 main 分支看点别的东西。但是 Git 不让切，因为你有未提交的修改
    - git stash会将代码区的修改保存到一个栈中，并恢复工作区到上次pull的状态
    - git stash pop
      - 切换回 dev 分支后，把之前存的改动取出来并删除stash记录
    - git stash apply
      - 切换回 dev 分支后，把之前存的改动取出来但不删除stash记录
  - 临时提交到本地但不推送
  - 如果想保留但在多个分支都可用 git switch other-branch --merge
    - 提是：改动的文件与目标分支没有冲突，否则 Git 会拒绝切换。

- 如何重命名一个已经在本地提交过的commit
  - 修改最近一次的 commit 信息
    ```
    git commit --amend -m "新的提交信息"
    ```
  - 修改某个较早的 commit 信息（非最近一次）
    ```
    git rebase -i HEAD~n

    ```
    - n 是从当前 HEAD 往上数的提交数量。
    - Git 会打开一个编辑界面，显示最近 n 个 commit。
    - 找到你想修改的 commit，将 pick 改为 reword
    - 保存并退出编辑器。
    - Git 会依次停在你标记为 reword 的 commit，让你修改提交信息。
    - 修改完成后保存即可。
    - 如果该 commit 已经推送到远程仓库，修改 commit 会改变 hash，需要强制推送

  - 如果 rebase 的时候冲突了，怎么办？
    - git status查看冲突
    - 手动解决冲突
    - git add <file1> <file2> ...标记冲突已解决
    - git rebase --continue继续 rebase  
    - git rebase --abort放弃 rebase（可选）