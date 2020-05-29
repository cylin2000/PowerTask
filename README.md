# PowerTask

PowerTask是一个PowerShell写成的在线类库，通过一句话引入这个类库，就可以直接使用，方便快捷

## 引入类库
打开PowerShell命令行，输入以下命令  

``` powershell 
iex (new-object net.webclient).downloadstring('http://www.soft263.com/dev/PowerTask/PowerTask.ps1')
```

如需打开PowerShell就默认载入，可以创建 C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1 并将上一句PowerShell命令放入文件中，下次打开PowerShell就会自动加载，如果你没有创建过此文件，可以使用下面脚本直接生成。
``` powershell
Set-Content C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1 "iex (new-object net.webclient).downloadstring('http://www.soft263.com/dev/PowerTask/PowerTask.ps1')"
```

## 查看帮助

``` powerhsell
Get-Command -Module PowerTask
Get-Help Compress-Zip
```

## 调用功能
``` powershell
Compress-Zip c:\source c:\target.zip
```


