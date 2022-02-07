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
  $RandomCommitName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomCommitName))
New-Item "$RandomCommitName.ps1" -Type File
Set-Content "$RandomCommitName.ps1" "cd $ProjectName
git add .
`$CommitMessage = Read-Host -Prompt `"$ProjectName Commit Message`" 
git commit -m `"`$CommitMessage`""

Do { 
  $RandomPushName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomPushName))
New-Item "$RandomPushName.ps1" -Type File
Set-Content "$RandomPushName.ps1" "cd $ProjectName
git push"

$Current = (Get-Item .).FullName
$GitLocation = $Current -replace '\\', '/'

$jsonfile = '../intraLaunch.json'
$json = Get-Content $jsonfile | Out-String | ConvertFrom-Json

$newblock = @"
  {
    "name": "$ProjectName",
    "commit": "$GitLocation/$RandomCommitName.ps1",
    "push": "$GitLocation/$RandomPushName.ps1"
  }
"@

$json.nextjs += (ConvertFrom-Json -InputObject $newblock)
$json | ConvertTo-Json | Set-Content $jsonfile