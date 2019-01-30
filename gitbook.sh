git checkout master
cp -r gitbook/_book/* gitbook/.
git add .
git commit -m $1
git push origin master
