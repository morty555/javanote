- Linux中如何建立防火墙策略？
  - 使用 firewalld
    ```
      # 启动 firewalld
    sudo systemctl start firewalld

    # 设置开机自启
    sudo systemctl enable firewalld

    # 查看状态
    sudo systemctl status firewalld

    ```
    - 基本概念
      - Zone 区域：防火墙规则的集合，可以根据网络环境（如家庭、工作等）选择不同的 zone。
        - public：公共网络，默认区域，适用于不受信任的网络。
        - internal：内部网络，适用于受信任的网络。
        - trust: 完全信任的网络，没有任何限制。
      - Service 服务：预定义的服务规则，如 HTTP、SSH 等。
      - Rich Rule（富规则）：更复杂的自定义规则。
    - 常用命令
      - 添加端口和服务
      ```
            # 临时添加（重启后失效）
      firewall-cmd --zone=public --add-port=8080/tcp

      # 永久添加（需 reload 才生效）
      firewall-cmd --zone=public --add-port=8080/tcp --permanent

      # 开放常见服务
      firewall-cmd --zone=public --add-service=http --permanent
      firewall-cmd --zone=public --add-service=ssh --permanent

      # 重新加载使永久规则生效
      firewall-cmd --reload
      ```
      - 删除端口
      ```
            firewall-cmd --zone=public --remove-port=8080/tcp --permanent
      firewall-cmd --reload

      ```
  - iptables
    -  开放端口
    ```
        # 开放 TCP 端口 80
    sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

    # 保存规则
    sudo service iptables save  # CentOS 6
    sudo iptables-save > /etc/iptables/rules.v4  # Debian/Ubuntu

    ```
    - 拒绝或允许部分ip
    ```
          # 拒绝某 IP
      sudo iptables -A INPUT -s 192.168.1.100 -j DROP

      # 只允许某 IP 访问 SSH
      sudo iptables -A INPUT -p tcp -s 192.168.1.100 --dport 22 -j ACCEPT
      sudo iptables -A INPUT -p tcp --dport 22 -j DROP
    ```
    -  删除规则
    ```
    sudo iptables -D INPUT 1    # 删除第1条规则

    ```
    - 查看现有规则
    ```
    sudo iptables -L -n -v

    ```


- 嵌套创建文件目录的命令是什么
  - mkdir -p 路径/到/目录
  - mkdir -p /home/user/project/src/main/java
  - 这条命令会依次创建：/home
                    /home/user
                    /home/user/project
                    /home/user/project/src
                    /home/user/project/src/main
                    /home/user/project/src/main/java

- cd ./和cd ../
  - cd . 和 cd ./ → 都是切换到当前目录,不会改变目录
  - cd .. 和 cd ../ → 都是切换到父目录
  - 末尾 / 多数情况是可选的，加上只是明确表示这是目录。

