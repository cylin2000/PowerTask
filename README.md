# PowerTask

PowerTask是一个PowerShell写成的在线类库，你可以通过一句话引入这个类库

## 目标

* 用户打开PowerShell命令行，输入一行命令即可使用PowerTask提供的功能
* PowerTask的功能都以函数方式提供，函数提供返回值

## 示例

``` powershell
Download-File -Path http://www.xxx.com/1.zip -TargetPath c:\test.zip

Zip-File -SourcePath C:\test_folder -FileName C:\test.zip

Extract-File -FileName c:\test.zip -TargetPath c:\target_folder
```
