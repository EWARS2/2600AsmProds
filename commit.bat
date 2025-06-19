@echo off
git init
git add --all
git commit -m "Autocommit: %*"
git push
