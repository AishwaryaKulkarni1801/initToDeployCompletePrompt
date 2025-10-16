#!/bin/bash

# Angular to GitHub Pages Deployment Automation
# Cross-platform shell script

echo "===================================================="
echo "   Angular to GitHub Pages Deployment Automation"
echo "===================================================="
echo ""

# Set default values
DEFAULT_USERNAME="AishwaryaKulkarni1801"
DEFAULT_REPO_NAME="initToDeployCompletePrompt"
DEFAULT_BRANCH_NAME="main"

# Function to prompt with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local varname="$3"
    
    read -p "$prompt (default: $default): " input
    if [ -z "$input" ]; then
        eval "$varname='$default'"
    else
        eval "$varname='$input'"
    fi
}

# Prompt for inputs with defaults
prompt_with_default "Enter GitHub Username" "$DEFAULT_USERNAME" "USERNAME"
prompt_with_default "Enter Repository Name" "$DEFAULT_REPO_NAME" "REPO_NAME"
prompt_with_default "Enter Branch Name" "$DEFAULT_BRANCH_NAME" "BRANCH_NAME"

echo ""
echo "Configuration:"
echo "  GitHub Username: $USERNAME"
echo "  Repository Name: $REPO_NAME"
echo "  Branch Name: $BRANCH_NAME"
echo ""

# Function to run commands with error checking
run_command() {
    local description="$1"
    local command="$2"
    
    echo "[$description]"
    if ! eval "$command"; then
        echo "ERROR: $description failed"
        exit 1
    fi
}

# Check if git is initialized
IS_FIRST_TIME=false
if [ ! -d ".git" ]; then
    echo "[STEP 1] Initializing Git repository..."
    run_command "Git initialization" "git init"
    
    echo "[STEP 2] Adding all files to Git..."
    run_command "Adding files" "git add ."
    
    echo "[STEP 3] Making initial commit..."
    run_command "Initial commit" "git commit -m 'Initial Angular project'"
    
    echo "[STEP 4] Setting default branch to $BRANCH_NAME..."
    run_command "Setting default branch" "git branch -M $BRANCH_NAME"
    
    echo "[STEP 5] Adding remote origin..."
    run_command "Adding remote origin" "git remote add origin https://github.com/$USERNAME/$REPO_NAME.git"
    
    echo "[STEP 6] Pushing to GitHub..."
    if ! git push -u origin "$BRANCH_NAME"; then
        echo "ERROR: Failed to push to GitHub. Make sure the repository exists and you have access."
        echo "You may need to create the repository at: https://github.com/$USERNAME/$REPO_NAME"
        exit 1
    fi
    
    IS_FIRST_TIME=true
else
    echo "[STEP 1] Git repository already exists. Updating..."
    
    echo "[STEP 2] Adding changes..."
    run_command "Adding changes" "git add ."
    
    echo "[STEP 3] Committing changes..."
    git commit -m "Workflow / code update" || echo "No changes to commit or commit failed"
fi

echo ""
echo "[STEP 7] Creating GitHub Actions workflow directory..."
mkdir -p .github/workflows

echo "[STEP 8] Creating GitHub Actions workflow file..."

# Extract project output path from angular.json
OUTPUT_PATH=$(grep -o '"outputPath"[[:space:]]*:[[:space:]]*"[^"]*"' angular.json | sed 's/.*"outputPath"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

# Create the workflow file
cat > .github/workflows/angular-deploy.yml << EOF
name: Deploy Angular App to GitHub Pages

on:
  push:
    branches: [ $BRANCH_NAME ]
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
        run: npm run build -- --base-href '/$REPO_NAME/'

      - name: Copy index.html to 404.html
        run: cp $OUTPUT_PATH/index.html $OUTPUT_PATH/404.html

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '$OUTPUT_PATH'

  deploy:
    environment:
      name: github-pages
      url: \${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
EOF

echo "[STEP 9] Workflow file created successfully!"

echo "[STEP 10] Committing workflow file..."
run_command "Adding workflow file" "git add .github/workflows/angular-deploy.yml"
git commit -m "Add GitHub Actions workflow for deployment" || echo "WARNING: Failed to commit workflow file or no changes to commit"

if [ "$IS_FIRST_TIME" = false ]; then
    echo "[STEP 11] Pushing workflow to GitHub..."
    run_command "Pushing to GitHub" "git push origin $BRANCH_NAME"
fi

echo ""
echo "===================================================="
echo "                   SUCCESS!"
echo "===================================================="
echo ""
echo "Your Angular project has been set up for GitHub Pages deployment!"
echo ""
echo "Repository URL: https://github.com/$USERNAME/$REPO_NAME"
echo "GitHub Pages URL: https://$USERNAME.github.io/$REPO_NAME/"
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. Go to your repository: https://github.com/$USERNAME/$REPO_NAME"
echo "2. Navigate to Settings > Pages"
echo "3. Under 'Source', select 'GitHub Actions'"
echo "4. The workflow will automatically run on the next push"
echo ""
echo "The deployment workflow will:"
echo "- Build your Angular app with the correct base-href"
echo "- Deploy to GitHub Pages automatically"
echo "- Be available at: https://$USERNAME.github.io/$REPO_NAME/"
echo ""
echo "===================================================="
