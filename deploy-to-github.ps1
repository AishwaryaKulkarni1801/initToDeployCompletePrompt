# Angular to GitHub Pages Deployment Automation
# PowerShell Script for Windows

Write-Host "====================================================" -ForegroundColor Green
Write-Host "   Angular to GitHub Pages Deployment Automation" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Set default values
$defaultUsername = "AishwaryaKulkarni1801"
$defaultRepoName = "initToDeployCompletePrompt"
$defaultBranchName = "main"

# Prompt for inputs with defaults
$username = Read-Host "Enter GitHub Username (default: $defaultUsername)"
if ([string]::IsNullOrEmpty($username)) { $username = $defaultUsername }

$repoName = Read-Host "Enter Repository Name (default: $defaultRepoName)"
if ([string]::IsNullOrEmpty($repoName)) { $repoName = $defaultRepoName }

$branchName = Read-Host "Enter Branch Name (default: $defaultBranchName)"
if ([string]::IsNullOrEmpty($branchName)) { $branchName = $defaultBranchName }

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  GitHub Username: $username" -ForegroundColor White
Write-Host "  Repository Name: $repoName" -ForegroundColor White
Write-Host "  Branch Name: $branchName" -ForegroundColor White
Write-Host ""

# Function to run git commands with error checking
function Invoke-GitCommand {
    param([string]$Command, [string]$Description)
    
    Write-Host "[$Description]" -ForegroundColor Cyan
    Invoke-Expression $Command
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: $Description failed" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Check if git is initialized
$isFirstTime = $false
if (-not (Test-Path ".git")) {
    Write-Host "[STEP 1] Initializing Git repository..." -ForegroundColor Cyan
    Invoke-GitCommand "git init" "Git initialization"
    
    Write-Host "[STEP 2] Adding all files to Git..." -ForegroundColor Cyan
    Invoke-GitCommand "git add ." "Adding files"
    
    Write-Host "[STEP 3] Making initial commit..." -ForegroundColor Cyan
    Invoke-GitCommand "git commit -m 'Initial Angular project'" "Initial commit"
    
    Write-Host "[STEP 4] Setting default branch to $branchName..." -ForegroundColor Cyan
    Invoke-GitCommand "git branch -M $branchName" "Setting default branch"
    
    Write-Host "[STEP 5] Adding remote origin..." -ForegroundColor Cyan
    Invoke-GitCommand "git remote add origin https://github.com/$username/$repoName.git" "Adding remote origin"
    
    Write-Host "[STEP 6] Pushing to GitHub..." -ForegroundColor Cyan
    git push -u origin $branchName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to push to GitHub. Make sure the repository exists and you have access." -ForegroundColor Red
        Write-Host "You may need to create the repository at: https://github.com/$username/$repoName" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    $isFirstTime = $true
} else {
    Write-Host "[STEP 1] Git repository already exists. Updating..." -ForegroundColor Cyan
    
    Write-Host "[STEP 2] Adding changes..." -ForegroundColor Cyan
    Invoke-GitCommand "git add ." "Adding changes"
    
    Write-Host "[STEP 3] Committing changes..." -ForegroundColor Cyan
    git commit -m "Workflow / code update"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "No changes to commit or commit failed" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[STEP 7] Creating GitHub Actions workflow directory..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path ".github" | Out-Null
New-Item -ItemType Directory -Force -Path ".github\workflows" | Out-Null

Write-Host "[STEP 8] Creating GitHub Actions workflow file..." -ForegroundColor Cyan

# Extract project output path from angular.json
$angularJson = Get-Content "angular.json" | ConvertFrom-Json
$projectNames = $angularJson.projects | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
$firstProject = $projectNames[0]
$outputPath = $angularJson.projects.$firstProject.architect.build.options.outputPath

# Create the workflow content
$workflowContent = @"
name: Deploy Angular App to GitHub Pages

on:
  push:
    branches: [ $branchName ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 'lts/*'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build Angular app
        run: npm run build -- --base-href '/$repoName/'

      - name: Copy index.html to 404.html
        run: cp $outputPath/index.html $outputPath/404.html

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '$outputPath'

  deploy:
    environment:
      name: github-pages
      url: `${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
"@

# Write the workflow file
$workflowContent | Out-File -FilePath ".github\workflows\angular-deploy.yml" -Encoding utf8

Write-Host "[STEP 9] Workflow file created successfully!" -ForegroundColor Green

Write-Host "[STEP 10] Committing workflow file..." -ForegroundColor Cyan
Invoke-GitCommand "git add .github\workflows\angular-deploy.yml" "Adding workflow file"
git commit -m "Add GitHub Actions workflow for deployment"
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Failed to commit workflow file or no changes to commit" -ForegroundColor Yellow
}

if (-not $isFirstTime) {
    Write-Host "[STEP 11] Pushing workflow to GitHub..." -ForegroundColor Cyan
    Invoke-GitCommand "git push origin $branchName" "Pushing to GitHub"
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host "                   SUCCESS!" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Angular project has been set up for GitHub Pages deployment!" -ForegroundColor White
Write-Host ""
Write-Host "Repository URL: https://github.com/$username/$repoName" -ForegroundColor Cyan
Write-Host "GitHub Pages URL: https://$username.github.io/$repoName/" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Go to your repository: https://github.com/$username/$repoName" -ForegroundColor White
Write-Host "2. Navigate to Settings > Pages" -ForegroundColor White
Write-Host "3. Under 'Source', select 'GitHub Actions'" -ForegroundColor White
Write-Host "4. The workflow will automatically run on the next push" -ForegroundColor White
Write-Host ""
Write-Host "The deployment workflow will:" -ForegroundColor Yellow
Write-Host "- Build your Angular app with the correct base-href" -ForegroundColor White
Write-Host "- Deploy to GitHub Pages automatically" -ForegroundColor White
Write-Host "- Be available at: https://$username.github.io/$repoName/" -ForegroundColor White
Write-Host ""
Write-Host "====================================================" -ForegroundColor Green

Read-Host "Press Enter to exit"
