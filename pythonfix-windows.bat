@echo off
:: If not running as admin, relaunch with "am_admin" argument
if not "%1"=="am_admin" (
    powershell -Command "Start-Process -Verb RunAs -FilePath '%0' -ArgumentList 'am_admin'"
    exit /b
)

:got_admin
:: Create worker.ps1 using echo commands
echo $html = Invoke-WebRequest "https://www.python.org/downloads" -UseBasicParsing > worker.ps1
echo $newest_version = $html.Links ^| Where-Object {$_.href -like "https://www.python.org/ftp/python/*/python-*amd64.exe"} ^| Select-Object -Last 1 -ExpandProperty href >> worker.ps1
echo $ver = $newest_version -replace "https://www.python.org/ftp/python/", "" -replace "/python-.*", "" >> worker.ps1

echo try { >> worker.ps1
echo     python.exe --version ^> $null >> worker.ps1
echo     $status = "Working" >> worker.ps1
echo } catch { >> worker.ps1
echo     $status = "Not Working" >> worker.ps1
echo } >> worker.ps1

echo if ($status -eq "Working") { >> worker.ps1
echo     Write-Host "Python already works and is on PATH" >> worker.ps1
echo     EXIT >> worker.ps1
echo } else { >> worker.ps1
echo     if (Test-Path "C:\Users\$env:UserName\AppData\Local\Programs\Python\*\python.exe") { >> worker.ps1
echo         Write-Host "Python installed but not on PATH - fixing..." >> worker.ps1
echo         try { >> worker.ps1
echo             $root = Get-ChildItem "C:\Users\$env:UserName\AppData\Local\Programs\Python" -Directory -Recurse -Filter "" ^| Select-Object -First 1 >> worker.ps1
echo             $scripts = Get-ChildItem "C:\Users\$env:UserName\AppData\Local\Programs\Python" -Directory -Recurse -Filter "Scripts" ^| Select-Object -First 1 >> worker.ps1
echo             [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$($root.FullName);$($scripts.FullName)", "User") >> worker.ps1
echo             Write-Host "Python added to PATH. Reopen your terminal." >> worker.ps1
echo         } catch { >> worker.ps1
echo             Write-Host "Error adding Python to PATH!" >> worker.ps1
echo         } >> worker.ps1
echo     } else { >> worker.ps1
echo         Write-Host "Python not installed. Downloading..." >> worker.ps1
echo         [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 >> worker.ps1
echo         Invoke-WebRequest -Uri "https://www.python.org/ftp/python/$ver/python-$ver-amd64.exe" -UseBasicParsing -OutFile $env:TEMP\pysetup.exe >> worker.ps1
echo         Start-Process "cmd.exe" -ArgumentList "/c echo Installing Python... & $env:TEMP\pysetup.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Wait >> worker.ps1
echo         Remove-Item $env:TEMP\pysetup.exe -Force >> worker.ps1
echo     } >> worker.ps1
echo } >> worker.ps1

:: Run the PowerShell script and clean up
powershell -ExecutionPolicy Bypass -File worker.ps1
del worker.ps1

exit
