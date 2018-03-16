# Prepare python packages for lncFunTK


## Install pip
If you don't have pip, please download get-pip.py from https://bootstrap.pypa.io/get-pip.py and install pip module with [instructions](https://pip.pypa.io/en/stable/installing/):

```
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
```

## Install python packages

Install python packages using pip module:

```
cd lncfuntk
python -m  pip install -r  ./python.package.requirement.txt --user
```

## Install python packages without superuser privilege

You can also run it in python virtual environment, if you don't have superuser privilege.
```
# install virtualenv
pip install virtualenv --user

cd my_project_folder
virtualenv venv
source venv/bin/activate

# $INSTALL_DIR represent the lncfuntk install directory.
python -m  pip install -r  $INSTALL_DIR/python.package.requirement.txt
```

If you want to install lncFunTK in Ubuntu, please see [install.ubuntu.md](https://github.com/zhoujj2013/lncfuntk/blob/master/install.ubuntu.md) for details.
