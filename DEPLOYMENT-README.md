# Angular to GitHub Pages Automation Scripts

This repository contains ready-to-run automation scripts that will:
1. Initialize Git repository (if not already done)
2. Push your Angular project to GitHub
3. Create a complete CI/CD workflow for GitHub Pages deployment
4. Handle both first-time setup and subsequent updates

## 🚀 Quick Start

### For Windows Users

#### Option 1: Batch Script (Recommended)
```cmd
deploy-to-github.bat
```

#### Option 2: PowerShell Script
```powershell
.\deploy-to-github.ps1
```

### For Linux/Mac Users
```bash
chmod +x deploy-to-github.sh
./deploy-to-github.sh
```

## 📋 What the Scripts Do

### Automatic Setup:
- ✅ Detects if Git is already initialized
- ✅ Prompts for GitHub username, repository name, and branch name (with defaults)
- ✅ Initializes Git repository (if needed)
- ✅ Adds remote origin and pushes to GitHub
- ✅ Creates `.github/workflows/angular-deploy.yml` with complete CI/CD workflow
- ✅ Automatically detects Angular project name from `angular.json`
- ✅ Configures correct build settings with proper base-href
- ✅ Commits and pushes the workflow file

### GitHub Actions Workflow Features:
- 🔄 Triggers on every push to main branch + manual dispatch
- 🟢 Uses latest Node.js LTS
- 📦 Builds Angular app with correct base-href for GitHub Pages
- 📄 Copies `index.html` to `404.html` for SPA routing
- 🚀 Deploys to GitHub Pages using official actions
- 🔒 Sets correct permissions (contents: read, pages: write, id-token: write)
- ⚡ Uses concurrency to cancel previous runs
- 🌐 Outputs deployed page URL

## 🎯 Default Configuration

The scripts come pre-configured with your details:
- **GitHub Username**: `AishwaryaKulkarni1801`
- **Repository Name**: `initToDeployCompletePrompt`
- **Branch Name**: `main`

You can accept these defaults or change them when prompted.

## 📝 After Running the Script

1. **Go to your GitHub repository**: `https://github.com/AishwaryaKulkarni1801/initToDeployCompletePrompt`
2. **Navigate to Settings → Pages**
3. **Under "Source", select "GitHub Actions"**
4. **Your site will be available at**: `https://AishwaryaKulkarni1801.github.io/initToDeployCompletePrompt/`

## 🔧 Manual Configuration (if needed)

If you need to modify the workflow later, edit `.github/workflows/angular-deploy.yml`:

```yaml
name: Deploy Angular App to GitHub Pages

on:
  push:
    branches: [ main ]
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
        run: npm run build -- --base-href '/initToDeployCompletePrompt/'

      - name: Copy index.html to 404.html
        run: cp dist/init-to-deploy-complete-prompt/index.html dist/init-to-deploy-complete-prompt/404.html

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: 'dist/init-to-deploy-complete-prompt'

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## 🚨 Important Notes

1. **Repository Must Exist**: Make sure your GitHub repository exists before running the script
2. **GitHub Pages Setting**: After running the script, you MUST set the Pages source to "GitHub Actions" in repository settings
3. **First Run**: The first run will initialize Git and push everything. Subsequent runs will just update and push changes
4. **Permissions**: Make sure you have push access to the repository

## 🔍 Troubleshooting

### Script fails to push to GitHub:
- Ensure the repository exists on GitHub
- Check your GitHub credentials/token
- Verify you have push access to the repository

### GitHub Pages not working:
- Go to Settings → Pages and select "GitHub Actions" as source
- Check the Actions tab for workflow run status
- Ensure the workflow completed successfully

### Build failures:
- Check that `npm install` and `npm run build` work locally
- Verify your `angular.json` configuration
- Check the Actions logs for specific error messages

## 🎉 Success!

After successful setup, your Angular app will be automatically deployed to GitHub Pages on every push to the main branch. The deployment URL will be:

**https://AishwaryaKulkarni1801.github.io/initToDeployCompletePrompt/**
