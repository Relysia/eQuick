$ProjectName = Read-Host -Prompt "What is the name of your Next.js project you want to create?"
Write-Output "Creating Next.js project: $ProjectName ..."
Function createNextProject () {
  New-Item -Path "./$ProjectName" -ItemType Directory
  Set-Location $ProjectName
  npx create-next-app@latest .
} 

createNextProject

$GithubRepoName = Read-Host -Prompt "What is the name of your GitHub repo you want to create?"
Write-Output "Creating GitHub repo: $GithubRepoName ..."
Function createGithubRepo () {
  git init
  git add .
  git commit -m "Initial commit"
  gh repo create $GithubRepoName --public --source=. --remote=upstream
  git remote add origin git@github.com:Relysia/$GithubRepoName
  git push --set-upstream origin main
} 

createGithubRepo

Set-Location ../
Set-Location data/scripts
New-Item -Path "./$ProjectName" -ItemType Directory
Set-Location $ProjectName

Do { 
  $RandomStartName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomStartName))
New-Item "$RandomStartName.ps1" -Type File
Set-Content "$RandomStartName.ps1" "Set-Location $ProjectName
code .
Write-Output 'Please copy the url to your browser!'
npm run dev"

Do { 
  $RandomCommitName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomCommitName))
New-Item "$RandomCommitName.ps1" -Type File
Set-Content "$RandomCommitName.ps1" "Set-Location $ProjectName
git add .
`$CommitMessage = Read-Host -Prompt `"$ProjectName Commit Message`" 
git commit -m `"`$CommitMessage`"
Write-Output 'Your changes has been committed to $GithubRepoName repo!'
Start-Sleep 3"

Do { 
  $RandomPushName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomPushName))
New-Item "$RandomPushName.ps1" -Type File
Set-Content "$RandomPushName.ps1" "Set-Location $ProjectName
git push
Write-Output 'Your changes has been pushed to $GithubRepoName repo!'
Start-Sleep 3"

Do { 
  $RandomDeleteName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomDeleteName))
New-Item "$RandomDeleteName.ps1" -Type File
Set-Content "$RandomDeleteName.ps1" "Add-Type -AssemblyName PresentationFramework
`$caption = 'Delete Project'
`$message = 'This will delete your project locally and also your git repo. Are you sure you want to continue?'
`$continue = [System.Windows.MessageBox]::Show(`$message, `$caption, 'YesNo');
if (`$continue -eq 'Yes') {
  Write-Output 'Deleting project...'
  gh repo delete $GithubRepoName --confirm
  Remove-Item -LiteralPath `"$ProjectName`" -Force -Recurse
  `$object = `"$ProjectName`"
  `$jsonfile = './data/intraLaunch.json'
  `$json = Get-Content `$jsonfile -Raw | ConvertFrom-Json
  `$json.nextjs = `$json.nextjs | Select-Object * | Where-Object { `$_.name -ne `$object }
  `$json | ConvertTo-Json | Out-File -Encoding ASCII `$jsonfile
  Set-Location ./data/scripts
  Remove-Item -LiteralPath `"$ProjectName`" -Force -Recurse
  Write-Output 'Your project has been deleted!'
  Start-Sleep 3
}
else {
  Write-Output 'Terminating process...'
  Start-Sleep 1
}"




$Current = (Get-Item .).FullName
$GitLocation = $Current -replace '\\', '/'

$jsonfile = '../../intraLaunch.json'
$json = Get-Content $jsonfile | Out-String | ConvertFrom-Json

$newblock = @"
  {
    "name": "$ProjectName",
    "start": "$GitLocation/$RandomStartName.ps1",
    "commit": "$GitLocation/$RandomCommitName.ps1",
    "push": "$GitLocation/$RandomPushName.ps1",
    "delete": "$GitLocation/$RandomDeleteName.ps1"
  }
"@

$json.nextjs += (ConvertFrom-Json -InputObject $newblock)
$json | ConvertTo-Json | Set-Content $jsonfile

Write-Output 'Your project has been created!'
Start-Sleep 2