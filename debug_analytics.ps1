$env:Path += ";$env:LOCALAPPDATA\Android\Sdk\platform-tools"
adb shell setprop debug.firebase.analytics.app com.developfly.unitv
Write-Host "Firebase debug mode aktif edildi." -ForegroundColor Green
