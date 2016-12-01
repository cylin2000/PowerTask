# PowerTask

PowerTask是一个PowerShell写成的在线类库，通过一句话引入这个类库，就可以直接使用，方便快捷

## 引入类库
打开PowerShell命令行，输入以下命令  

``` powershell 
iex (new-object net.webclient).downloadstring('https://raw.githubusercontent.com/cylin2000/powertask/master/PowerTask.ps1')
```

# 查看帮助

``` powerhsell
Get-Command -Module PowerTask
Get-Help Compress-Zip
```

# 调用函数
``` powershell
Compress-Zip c:\source c:\target.zip
```


