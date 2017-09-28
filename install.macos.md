# Dependencies installation in MacOS

Install dependencies through brew.

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install freetype
```

Install python modules:

```
# install virtualenv
pip install virtualenv

cd my_project_folder
virtualenv venv
source venv/bin/activate

# $INSTALL_DIR represent the lncfuntk install directory.
python -m  pip install -r  $INSTALL_DIR/python.package.requirement.txt
```

then, run command as follow for installation:

```
cd ./lncfuntk
perl INSTALL.pl
# installation finished.
```
