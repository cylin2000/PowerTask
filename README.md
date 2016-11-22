# PowerTask

PowerTask是一个PowerShell写成的在线类库，你可以通过一句话引入这个类库

## 目标

* 用户打开PowerShell命令行，输入一行命令即可使用PowerTask提供的其他功能
* PowerTask的功能都以函数方式提供
* 函数方式提供返回值
* 可以让用户安装pt install c:\folder 指定目录，如果没指定，就安装到home目录

```
pt install sqlserver # 就具体安装某个软件，如 pt install vim
pt uninstall sqlserver 就是卸载
```
