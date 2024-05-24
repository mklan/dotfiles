git checkout --orphan tmp
git add -A
git commit -am "initial"
git branch -D main
git branch -m main
git push -f origin main
