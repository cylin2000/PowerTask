function Get-DoubanMovieRate {
    <#
    .SYNOPSIS    
        查询电影的豆瓣评分
    .DESCRIPTION 
        This task will extract files from a single zip package
    .EXAMPLE     
        Get-DoubanMovieRate '盗梦空间'
    #>

    param(
        [Parameter(Mandatory=$True)][String] $name
    )
    
    $wc = New-Object System.Net.WebClient
    $wc.Encoding = [System.Text.Encoding]::UTF8
    $jsonString = $wc.DownloadString("http://api.douban.com/v2/movie/search?q=$name")
    $movie = $jsonString | ConvertFrom-Json
    return $movie.subjects[0].rating.average
}