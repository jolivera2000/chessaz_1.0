cls

$nugetPath = "$env:LOCALAPPDATA\NuGet\NuGet.exe"

if (!(Get-Command NuGet -ErrorAction SilentlyContinue) -and !(Test-Path $nugetPath)){
	(New-Object System.Net.WebClient).DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe", $nugetPath)
}

if (Test-Path $nugetPath){
	Set-Alias NuGet (Resolve-Path $nugetPath)
}

NuGet restore

. '.\functions.ps1'

$invokeBuild = (Get-ChildItem('C:\Users\Dulce\.nuget\packages\Invoke-Build\*\tools\Invoke-Build.ps1')).FullName | Sort-Object $_ | Select -Last 1
& $invokeBuild $args Tasks.ps1