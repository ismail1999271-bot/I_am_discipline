@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo === I Am Disiplin kurulum ===
where flutter >nul 2>nul || (echo Flutter bulunamadi. Kur: https://docs.flutter.dev/get-started/install/windows & pause & exit /b)
if not exist android (
  echo Android klasoru olusturuluyor...
  call flutter create . --project-name i_am_disiplin --platforms android
)
powershell -ExecutionPolicy Bypass -File android_ayar.ps1
call flutter pub get
echo Kod kontrol ediliyor...
call flutter analyze --no-fatal-infos --no-fatal-warnings > hata_kaydi.txt 2>&1
findstr /C:"error" hata_kaydi.txt >nul && (
  type hata_kaydi.txt
  echo.
  echo HATA VAR: hata_kaydi.txt dosyasinin icerigini Claude'a yapistir.
  pause & exit /b
)
echo Kod temiz.
where ollama >nul 2>nul && (
  echo Koc modeli indiriliyor, ilk sefer birkac dakika surer...
  ollama pull qwen2.5:7b
)
call flutter run
pause
