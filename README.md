# OpenXcom flavours installer

Compile easily from source multiples versions for concurrent runs.

## 0. Installing the dependencies

```shell
apt install --no-install-recommends \
    git cmake build-essential libboost-dev libsdl1.2-dev libsdl-mixer1.2-dev \
    libsdl-image1.2-dev libsdl-gfx1.2-dev libyaml-cpp-dev xmlto
```

## 1. Make the install-from-source-repository.sh script executable
```shell
chmod +x install-from-source-repository.sh
```

## 2. Installing a new game version
### Command structure
./install-from-source-repository.sh -r REPOSITORY -f FLAVOUR -s SHELL_PROFILE_PATH

## Examples
### Vanilla
SOURCE_REPOSITORY=git@github.com:OpenXcom/OpenXcom.git  
FLAVOUR=vanilla  
SHELL_PROFILE=~/.bashrc  

```shell
./install-from-source-repository.sh
```

### OXCE+
from https://github.com/MeridianOXC/OpenXcom

```shell
./install-from-source-repository.sh -r git@github.com:MeridianOXC/OpenXcom.git -f oxce -s ~/.zshrc 
```

### Brutal AI
from https://github.com/Xilmi/OpenXcom
```shell
./install-from-source-repository.sh -r git@github.com:Xilmi/OpenXcom.git -f brutal-ai -s ~/.zshrc 
```
