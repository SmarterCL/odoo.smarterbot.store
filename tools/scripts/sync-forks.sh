#!/bin/bash

set -e

BASE_DIR="/root/repos"
mkdir -p $BASE_DIR

REPOS=(
  "chatwoot"
  "botpress"
  "n8n"
  "odoo"
)

UPSTREAMS=(
  "https://github.com/chatwoot/chatwoot.git"
  "https://github.com/botpress/botpress.git"
  "https://github.com/n8n-io/n8n.git"
  "https://github.com/odoo/odoo.git"
)

FORKS=(
  "https://github.com/SmarterCL/chatwoot.git"
  "https://github.com/SmarterCL/botpress.git"
  "https://github.com/SmarterCL/n8n.git"
  "https://github.com/SmarterCL/odoo.git"
)

for i in ${!REPOS[@]}; do
  REPO=${REPOS[$i]}
  UPSTREAM=${UPSTREAMS[$i]}
  FORK=${FORKS[$i]}

  echo "🔄 Syncing $REPO..."

  cd $BASE_DIR

  if [ ! -d "$REPO" ]; then
    git clone $FORK $REPO
    cd $REPO
    git remote add upstream $UPSTREAM
  else
    cd $REPO
  fi

  git fetch upstream
  git merge upstream/master --no-edit || git merge upstream/main --no-edit || true

  # Insert .env.example
  if [ -f "/root/env-templates/$REPO.env.example" ]; then
    cp "/root/env-templates/$REPO.env.example" ".env.example"
    git add .env.example
    git commit -m "chore: add .env.example and sync upstream" || true
  fi

  # Push changes
  git push origin master || git push origin main || true
done

echo "✔ Fork sync complete"
