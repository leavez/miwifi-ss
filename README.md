# What
小米路由器安装 shadowsocks 插件的脚本

与原仓库的区别: 

- 为小米路由器 1/2 添加了 SSR 的支持
- 添加了更新 gwflist 的脚本，并且支持添加自定义 rule

# Usage

1. 为路由器开启 SSH （请自行搜索，官方支持）。

2. SSH 到路由器中执行:

```shell
cd /tmp && rm -rf *.sh && curl https://raw.githubusercontent.com/leavez/miwifi-ss/master/miwifi.sh -o miwifi.sh && chmod +x miwifi.sh && sh ./miwifi.sh && rm -rf *.sh
```

3. 执行脚本以更新 gwflist。 （可以编辑该目录下的 my_domains.txt, 添加自定义 rule）

```shell
/userdisk/data/.shadowsocksR/update_gfw_list_tool/update_rules.sh
```
