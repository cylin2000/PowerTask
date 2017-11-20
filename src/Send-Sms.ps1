function Send-Sms {
    <#
    .SYNOPSIS    
        Send SMS
    .DESCRIPTION 
        This task will send text message to mobile phone in China, you could request token from http://sms.webchinese.com.cn/
    .EXAMPLE     
        Send-Sms '13344445555' 'content' 'UID' 'TOKEN' '公司名'
    .NOTES       
        短信发送后返回值    说　明
                    -1  没有该用户账户
                    -2  接口密钥不正确 [查看密钥] 不是账户登陆密码
                    -21 MD5接口密钥加密不正确
                    -3  短信数量不足
                    -11 该用户被禁用
                    -14 短信内容出现非法字符
                    -4  手机号格式不正确
                    -41 手机号码为空
                    -42 短信内容为空
                    -51 短信签名格式不正确 接口签名格式为：【签名内容】
                    -6  IP限制
                    大于0 短信发送数量
    #>

    Param(
      [Parameter(Mandatory=$True,HelpMessage="Mobile")][string]$Mobile,
      [Parameter(Mandatory=$True,HelpMessage="Text")][string]$Text,
      [Parameter(Mandatory=$True,HelpMessage="Uid")][string]$Uid,
      [Parameter(Mandatory=$True,HelpMessage="Token")][string]$Token,
      [Parameter(Mandatory=$False,HelpMessage="Signature")][string]$Signature
    )
     
    $ApiUrl = "http://utf8.sms.webchinese.cn/?Uid={2}&Key={3}&smsMob={0}&smsText={1}"

    Add-Type -AssemblyName System.Web

    if ( $Signature -ne '' ) {
        $Text = "$Text 【$Signature】"
    }
    
    $encodedText = [System.Web.HttpUtility]::UrlEncode($text)
    $url = [string]::Format($ApiUrl,$mobile,$encodedText,$Uid,$Token)
    $wc = New-Object System.Net.WebClient
    $result = $wc.DownloadString($url)
    return $result

}
