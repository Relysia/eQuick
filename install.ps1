$WorkSpace = Read-Host -Prompt "What is the name of your workspace you want to create?"
Write-Output "Creating new eQuick workspace: $WorkSpace ..."

$WORKDIR = (Get-Item .).FullName
$ProjectLocation = $WORKDIR -replace '\\', '/'

Set-Location ./data/scripts
New-Item "liveserver.ps1" -Type File
Set-Content "liveserver.ps1" "Set-Location $WORKDIR\data
npm run dev"

$ComObj = New-Object -ComObject WScript.Shell
$ShortCut = $ComObj.CreateShortcut("$Env:USERPROFILE\desktop\eQuick.lnk")
$ShortCut.TargetPath = "$WORKDIR\data\scripts\liveserver.ps1"
$ShortCut.Description = "Open eQuick in Chrome"
$ShortCut.WindowStyle = 1
$ShortCut.IconLocation = "$WORKDIR\data\public\favicon.ico"
$ShortCut.Save()

Set-Location ../
New-Item "intraLaunch.json" -Type File
Set-Content "intraLaunch.json" "{
  `"initial`": {
    `"title`": `"$WorkSpace`",
    `"projectLocation`": `"$ProjectLocation`"
  },
  `"nextjs`": []
}"