@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo   Angular to GitHub Pages Deployment Automation
echo ====================================================
echo.

REM Set default values
set "USERNAME=AishwaryaKulkarni1801"
set "REPO_NAME=initToDeployCompletePrompt"
set "BRANCH_NAME=main"

REM Prompt for inputs with defaults
set /p "input_username=Enter GitHub Username (default: %USERNAME%): "
if not "%input_username%"=="" set "USERNAME=%input_username%"

set /p "input_repo=Enter Repository Name (default: %REPO_NAME%): "
if not "%input_repo%"=="" set "REPO_NAME=%input_repo%"

set /p "input_branch=Enter Branch Name (default: %BRANCH_NAME%): "
if not "%input_branch%"=="" set "BRANCH_NAME=%input_branch%"

echo.
echo Configuration:
echo   GitHub Username: %USERNAME%
echo   Repository Name: %REPO_NAME%
echo   Branch Name: %BRANCH_NAME%
echo.

REM Check if git is initialized
if not exist .git (
    echo [STEP 1] Initializing Git repository...
    git init
    if !errorlevel! neq 0 (
        echo ERROR: Failed to initialize git repository
        pause
        exit /b 1
    )
    
    echo [STEP 2] Adding all files to Git...
    git add .
    if !errorlevel! neq 0 (
        echo ERROR: Failed to add files to git
        pause
        exit /b 1
    )
    
    echo [STEP 3] Making initial commit...
    git commit -m "Initial Angular project"
    if !errorlevel! neq 0 (
        echo ERROR: Failed to make initial commit
        pause
        exit /b 1
    )
    
    echo [STEP 4] Setting default branch to %BRANCH_NAME%...
    git branch -M %BRANCH_NAME%
    if !errorlevel! neq 0 (
        echo ERROR: Failed to set default branch
        pause
        exit /b 1
    )
    
    echo [STEP 5] Adding remote origin...
    git remote add origin https://github.com/%USERNAME%/%REPO_NAME%.git
    if !errorlevel! neq 0 (
        echo ERROR: Failed to add remote origin
        pause
        exit /b 1
    )
    
    echo [STEP 6] Pushing to GitHub...
    git push -u origin %BRANCH_NAME%
    if !errorlevel! neq 0 (
        echo ERROR: Failed to push to GitHub. Make sure the repository exists and you have access.
        echo You may need to create the repository at: https://github.com/%USERNAME%/%REPO_NAME%
        pause
        exit /b 1
    )
    
    set "IS_FIRST_TIME=true"
) else (
    echo [STEP 1] Git repository already exists. Updating...
    
    echo [STEP 2] Adding changes...
    git add .
    if !errorlevel! neq 0 (
        echo ERROR: Failed to add files to git
        pause
        exit /b 1
    )
    
    echo [STEP 3] Committing changes...
    git commit -m "Workflow / code update"
    if !errorlevel! neq 0 (
        echo No changes to commit or commit failed
    )
    
    set "IS_FIRST_TIME=false"
)

echo.
echo [STEP 7] Creating GitHub Actions workflow directory...
if not exist .github mkdir .github
if not exist .github\workflows mkdir .github\workflows

echo [STEP 8] Creating GitHub Actions workflow file...

REM Extract project name from angular.json
for /f "tokens=2 delims=:" %%a in ('findstr /r "\"outputPath\"" angular.json') do (
    set "output_line=%%a"
    set "output_line=!output_line: =!"
    set "output_line=!output_line:"=!"
    set "output_line=!output_line:,=!"
    set "PROJECT_DIST=!output_line!"
)

REM Create the workflow file
(
echo name: Deploy Angular App to GitHub Pages
echo.
echo on:
echo   push:
echo     branches: [ %BRANCH_NAME% ]
echo   workflow_dispatch:
echo.
echo permissions:
echo   contents: read
echo   pages: write
echo   id-token: write
echo.
echo concurrency:
echo   group: "pages"
echo   cancel-in-progress: false
echo.
echo jobs:
echo   build:
echo     runs-on: ubuntu-latest
echo     steps:
echo       - name: Checkout
echo         uses: actions/checkout@v4
echo.
echo       - name: Setup Node.js
echo         uses: actions/setup-node@v4
echo         with:
echo           node-version: 'lts/*'
echo           cache: 'npm'
echo.
echo       - name: Install dependencies
echo         run: npm ci
echo.
echo       - name: Build Angular app
echo         run: npm run build -- --base-href '/%REPO_NAME%/'
echo.
echo       - name: Copy index.html to 404.html
echo         run: cp %PROJECT_DIST%/index.html %PROJECT_DIST%/404.html
echo.
echo       - name: Setup Pages
echo         uses: actions/configure-pages@v4
echo.
echo       - name: Upload artifact
echo         uses: actions/upload-pages-artifact@v3
echo         with:
echo           path: '%PROJECT_DIST%'
echo.
echo   deploy:
echo     environment:
echo       name: github-pages
echo       url: ${{ steps.deployment.outputs.page_url }}
echo     runs-on: ubuntu-latest
echo     needs: build
echo     steps:
echo       - name: Deploy to GitHub Pages
echo         id: deployment
echo         uses: actions/deploy-pages@v4
) > .github\workflows\angular-deploy.yml

echo [STEP 9] Workflow file created successfully!

echo [STEP 10] Committing workflow file...
git add .github\workflows\angular-deploy.yml
git commit -m "Add GitHub Actions workflow for deployment"
if !errorlevel! neq 0 (
    echo WARNING: Failed to commit workflow file or no changes to commit
)

if "%IS_FIRST_TIME%"=="false" (
    echo [STEP 11] Pushing workflow to GitHub...
    git push origin %BRANCH_NAME%
    if !errorlevel! neq 0 (
        echo ERROR: Failed to push workflow to GitHub
        pause
        exit /b 1
    )
)

echo.
echo ====================================================
echo                   SUCCESS!
echo ====================================================
echo.
echo Your Angular project has been set up for GitHub Pages deployment!
echo.
echo Repository URL: https://github.com/%USERNAME%/%REPO_NAME%
echo GitHub Pages URL: https://%USERNAME%.github.io/%REPO_NAME%/
echo.
echo IMPORTANT NEXT STEPS:
echo 1. Go to your repository: https://github.com/%USERNAME%/%REPO_NAME%
echo 2. Navigate to Settings ^> Pages
echo 3. Under "Source", select "GitHub Actions"
echo 4. The workflow will automatically run on the next push
echo.
echo The deployment workflow will:
echo - Build your Angular app with the correct base-href
echo - Deploy to GitHub Pages automatically
echo - Be available at: https://%USERNAME%.github.io/%REPO_NAME%/
echo.
echo ====================================================

pause
