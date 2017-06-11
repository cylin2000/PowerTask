# PowerTask

PowerTask是一个PowerShell写成的在线类库，通过一句话引入这个类库，就可以直接使用，方便快捷

## 引入类库
打开PowerShell命令行，输入以下命令  

``` powershell 
iex (new-object net.webclient).downloadstring('http://www.caiyunlin.com/dev/powertask/?t='+(Get-Random))
或者
iex (new-object net.webclient).downloadstring('https://raw.githubusercontent.com/cylin2000/powertask/master/PowerTask.ps1?t='+(Get-Random))
```

如需打开PowerShell就默认载入，可以创建 C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1 并将上一句PowerShell命令放入文件中，下次打开PowerShell就会自动加载

## 查看帮助

``` powerhsell
Get-Command -Module PowerTask
Get-Help Compress-Zip
```

## 调用功能
``` powershell
Compress-Zip c:\source c:\target.zip
```


