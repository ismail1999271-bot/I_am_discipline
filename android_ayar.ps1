# flutter create sonrasi Android ayarlarini otomatik yapar (tekrar calistirmak guvenli).
$ErrorActionPreference = "Stop"
$m = "android/app/src/main/AndroidManifest.xml"
$x = Get-Content $m -Raw
if ($x -notmatch "POST_NOTIFICATIONS") {
  $x = $x -replace '<application', "<uses-permission android:name=`"android.permission.POST_NOTIFICATIONS`"/>`n    <uses-permission android:name=`"android.permission.RECEIVE_BOOT_COMPLETED`"/>`n    <uses-permission android:name=`"android.permission.INTERNET`"/>`n    <application"
}
if ($x -notmatch "usesCleartextTraffic") {
  $x = $x -replace '<application', '<application android:usesCleartextTraffic="true"'
}
Set-Content $m $x -Encoding UTF8

$kts = "android/app/build.gradle.kts"
$grv = "android/app/build.gradle"
if (Test-Path $kts) {
  $g = Get-Content $kts -Raw
  if ($g -notmatch "isCoreLibraryDesugaringEnabled") {
    $g = $g -replace 'compileOptions\s*\{', "compileOptions {`n        isCoreLibraryDesugaringEnabled = true"
    $g += "`ndependencies {`n    coreLibraryDesugaring(`"com.android.tools:desugar_jdk_libs:2.1.4`")`n}`n"
  }
  Set-Content $kts $g -Encoding UTF8
} elseif (Test-Path $grv) {
  $g = Get-Content $grv -Raw
  if ($g -notmatch "coreLibraryDesugaringEnabled") {
    $g = $g -replace 'compileOptions\s*\{', "compileOptions {`n        coreLibraryDesugaringEnabled true"
    $g += "`ndependencies {`n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'`n}`n"
  }
  Set-Content $grv $g -Encoding UTF8
}
Write-Host "Android ayarlari tamam."
