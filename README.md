project uses git submodules, so after checking out you might need to:

git submodule init <br />
git submodule update<br />

<br />
to update all modules after:<br />
git submodule foreach git pull
