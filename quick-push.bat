@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo   Quick Fix: Push to Current Branch
echo ====================================================
echo.

REM Get current branch
for /f "tokens=*" %%i in ('git branch --show-current 2^>nul') do set "CURRENT_BRANCH=%%i"
if "!CURRENT_BRANCH!"=="" (
    for /f "tokens=2" %%i in ('git branch 2^>nul ^| findstr /r "^\*"') do set "CURRENT_BRANCH=%%i"
)

echo Current branch: %CURRENT_BRANCH%
echo.

echo Pushing to GitHub...
git push origin %CURRENT_BRANCH%

if !errorlevel! equ 0 (
    echo.
    echo ====================================================
    echo                   SUCCESS!
    echo ====================================================
    echo.
    echo Changes pushed successfully to branch: %CURRENT_BRANCH%
    echo.
    echo Your GitHub Pages site will be available at:
    echo https://AishwaryaKulkarni1801.github.io/initToDeployCompletePrompt/
    echo.
    echo IMPORTANT: Make sure to set Pages source to "GitHub Actions" 
    echo in your repository Settings → Pages
    echo.
) else (
    echo.
    echo ERROR: Failed to push to GitHub
    echo Make sure you have the correct remote and permissions
)

pause
