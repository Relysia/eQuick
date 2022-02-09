Do {
  $ProjectName = Read-Host -Prompt "Enter the name of your Next.js project (it will also be used in GitHub and Docker)"
  Write-Host "Project Name: $ProjectName"
  $Confirmation = Read-Host -Prompt "Is this correct (y/n)?"
}
while ($Confirmation -ne "y")

Do {
  $SSHAddress = Read-Host -Prompt "Enter your SSH Server Address"
  Write-Host "SSH Server Address: $SSHAddress"
  $Confirmation = Read-Host -Prompt "Is this correct (y/n)?"
}
while ($Confirmation -ne "y")

$SSHPassword = Read-Host -Prompt "Enter your SSH Server Password" -AsSecureString
Do {
  $SSHPassword2 = Read-Host -Prompt "Re-enter your SSH Server Password" -AsSecureString
  $SSH1PWD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SSHPassword))
  $SSH2PWD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SSHPassword2))
  if ($SSH1PWD -ne $SSH2PWD) {
    Write-Host "Password didn't matched!"
  }
}
while ($SSH1PWD -ne $SSH2PWD)
Write-Host "Password matched!"

Do {
  $Port = Read-Host -Prompt "Enter the port where you want to deploy your app (e.g. 8080)"
  Write-Host "Server Port: $Port"
  $Confirmation = Read-Host -Prompt "Is this correct (y/n)?"
}
while ($Confirmation -ne "y")

Do {
  $GitUsername = Read-Host -Prompt "Enter your GitHub username"
  Write-Host "GitHub Username: $GitUsername"
  $Confirmation = Read-Host -Prompt "Is this correct (y/n)?"
}
while ($Confirmation -ne "y")

Do {
  $DockerUsername = Read-Host -Prompt "Enter your DockerHub username"
  Write-Host "DockerHub Username: $DockerUsername"
  $Confirmation = Read-Host -Prompt "Is this correct (y/n)?"
}
while ($Confirmation -ne "y")

Do {
  $DockerPassword = Read-Host -Prompt "Enter your DockerHub password" -AsSecureString
  $DockerPassword2 = Read-Host -Prompt "Re-enter your DockerHub password" -AsSecureString
  $DCKR1PWD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DockerPassword))
  $DCKR2PWD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DockerPassword2))
  if ($DCKR1PWD -ne $DCKR2PWD) {
    Write-Host "Password didn't matched!"
  }
}
while ($DCKR1PWD -ne $DCKR2PWD)
Write-Host "Passwords matched"

Write-Output "Creating Next.js project: $ProjectName ..."

Function createNextProject () {
  New-Item -Path "./$ProjectName" -ItemType Directory
  Set-Location $ProjectName
  npx create-next-app@latest .
  $jsonfile = './package.json'
  $json = Get-Content $jsonfile | Out-String | ConvertFrom-Json
  $json.scripts.dev = "next dev -p $Port"
  $json.scripts.start = "next start -p $Port"
  $json | ConvertTo-Json | Set-Content $jsonfile
} 

createNextProject

New-Item "Dockerfile" -Type File
Set-Content "Dockerfile" "FROM arm64v8/node:current-alpine AS base
WORKDIR /base
COPY package*.json ./
RUN npm install
COPY . .

FROM base AS build
LABEL com.centurylinklabs.watchtower.enable=`"true`"
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV=production
WORKDIR /build
COPY --from=base /base ./
RUN npm run build

FROM arm64v8/node:current-alpine AS production
LABEL com.centurylinklabs.watchtower.enable=`"true`"
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /build/package*.json ./
COPY --from=build /build/.next ./.next
COPY --from=build /build/public ./public
RUN npm install next

EXPOSE $Port
CMD npm run start"

Write-Output "Creating GitHub repo: $ProjectName ..."
Function createGithubRepo () {
  git init
  git add .
  git commit -m "Initial commit"
  gh repo create $ProjectName --public --source=. --remote=upstream
  git remote add origin git@github.com:$DockerUsername/$ProjectName
  git push --set-upstream origin main
} 

createGithubRepo


Set-Location ../
Set-Location data/scripts
New-Item -Path "./$ProjectName" -ItemType Directory
Set-Location $ProjectName

# Encrypt Passwords
$EncryptedSSH = ConvertFrom-SecureString -SecureString $SSHPassword -Key (1..16)
$EncryptedSSH | Set-Content encssh.txt
$EncryptedDCKR = ConvertFrom-SecureString -SecureString $DockerPassword -Key (1..16)
$EncryptedDCKR | Set-Content encdckr.txt

# Script files
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
  $RandomPushName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomPushName))
New-Item "$RandomPushName.ps1" -Type File
Set-Content "$RandomPushName.ps1" "Set-Location $ProjectName
git add .
`$CommitMessage = Read-Host -Prompt `"$ProjectName Commit Message`" 
git commit -m `"`$CommitMessage`"
Write-Output 'Your changes has been committed to $ProjectName repo!'
git push
Write-Output 'Your changes has been pushed to $ProjectName repo!'
Start-Sleep 3"

Do { 
  $RandomDeleteScript = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomDeleteScript))
New-Item "$RandomDeleteScript.ps1" -Type File
Set-Content "$RandomDeleteScript.ps1" "docker stop $ProjectName
docker rmi -f `$(docker images | grep '$GitUsername/$ProjectName')"

Do { 
  $RandomDeleteName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomDeleteName))
New-Item "$RandomDeleteName.ps1" -Type File
Set-Content "$RandomDeleteName.ps1" "Add-Type -AssemblyName PresentationFramework
`$caption = 'Delete Project'
`$message = 'This will delete your whole project (includes: local files, git repo, docker repo). Are you sure you want to continue?'
`$continue = [System.Windows.MessageBox]::Show(`$message, `$caption, 'YesNo');
if (`$continue -eq 'Yes') {
  Write-Output 'Removing GitHub Repository...'
  gh repo delete $ProjectName --confirm
  Write-Output 'Removing Next.js Folder...'
  Remove-Item -LiteralPath `"$ProjectName`" -Force -Recurse
  Write-Output 'Removing Project from Config File...'
  `$object = `"$ProjectName`"
  `$jsonfile = './data/intraLaunch.json'
  `$json = Get-Content `$jsonfile -Raw | ConvertFrom-Json
  `$json.nextjs = `$json.nextjs | Select-Object * | Where-Object { `$_.name -ne `$object }
  `$json | ConvertTo-Json | Out-File -Encoding ASCII `$jsonfile
  Write-Output 'Stop Remote Docker Server and Removing Docker image from Server...'
  Set-Location ./data/scripts/$ProjectName
  `$SecurePassword = Get-Content ./encssh.txt | ConvertTo-SecureString -Key (1..16)
  `$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$SecurePassword)
  `$SSHPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(`$BSTR)
  `$SecurePassword2 = Get-Content ./encdckr.txt | ConvertTo-SecureString -Key (1..16)
  `$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$SecurePassword2)
  `$DockerPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(`$BSTR)
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(`$BSTR)
  plink -no-antispoof $SSHAddress -pw `$SSHPassword -m ./$RandomDeleteScript.ps1
  Write-Output 'Removing Script Folder...'
  Set-Location ../
  Remove-Item -LiteralPath `"$ProjectName`" -Force -Recurse
  Write-Output 'Removing DockerHub Repository...'
  `$params = @{username = '$DockerUsername'; password = '`$DockerPassword' }
  `$response = Invoke-RestMethod -Uri https://hub.docker.com/v2/users/login/ -Method POST -Body `$params
  `$token = `$response.token;
  `$orgName = `"$DockerUsername`"
  `$repoName = `"$ProjectName`"
  `$Uri = `$(`"https://hub.docker.com/v2/repositories/`$orgName/`$repoName/`")
  Invoke-WebRequest -Method Delete -Uri `$Uri -Headers @{Authorization = `"JWT `" + `$token; Accept = 'application/json' }
  Write-Output 'Your project has been deleted!'
  Start-Sleep 3
}
else {
  Write-Output 'Terminating process...'
  Start-Sleep 1
}"

Do { 
  $RandomCommandName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomCommandName))
New-Item "$RandomCommandName.ps1" -Type File
Set-Content "$RandomCommandName.ps1" "sudo docker run --rm \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower --run-once --label-enable"

Do { 
  $RandomDeployName = [System.IO.Path]::GetRandomFileName()    
} 
Until(!(Test-Path $RandomDeployName))
New-Item "$RandomDeployName.ps1" -Type File
Set-Content "$RandomDeployName.ps1" "Set-Location $ProjectName
docker build . -t $ProjectName
docker tag $ProjectName $DockerUsername/$ProjectName
docker push $DockerUsername/$ProjectName
Set-Location ../data/scripts/$ProjectName
`$SecurePassword = Get-Content ./encssh.txt | ConvertTo-SecureString -Key (1..16)
`$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$SecurePassword)
`$SSHPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(`$BSTR)
plink -no-antispoof $SSHAddress -pw `$SSHPassword -m ./$RandomCommandName.ps1"

$Current = (Get-Item .).FullName
$GitLocation = $Current -replace '\\', '/'

$jsonfile = '../../intraLaunch.json'
$json = Get-Content $jsonfile | Out-String | ConvertFrom-Json

$newblock = @"
  {
    "name": "$ProjectName",
    "start": "$GitLocation/$RandomStartName.ps1",
    "push": "$GitLocation/$RandomPushName.ps1",
    "delete": "$GitLocation/$RandomDeleteName.ps1",
    "deploy": "$GitLocation/$RandomDeployName.ps1"
  }
"@

$json.nextjs += (ConvertFrom-Json -InputObject $newblock)
$json | ConvertTo-Json | Set-Content $jsonfile

New-Item "firstdeploy.ps1" -Type File
Set-Content "firstdeploy.ps1" "sudo docker run --name $ProjectName -dp $Port`:$Port $DockerUsername/$ProjectName
rm `$PSCommandPath"

Set-Location ../../../$ProjectName
docker build . -t $ProjectName
docker tag $ProjectName $DockerUsername/$ProjectName
docker push $DockerUsername/$ProjectName
Set-Location ../data/scripts/$ProjectName
$SecurePassword = Get-Content ./encssh.txt | ConvertTo-SecureString -Key (1..16)
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$SSHPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
plink -no-antispoof $SSHAddress -pw $SSHPassword -m ./firstdeploy.ps1

Write-Output 'Your project has been created!'
Start-Sleep 3