#!/bin/bash

# Get the username from the current session
USER=$(whoami)

# Default values for overridable variables
SOURCE_REPOSITORY=git@github.com:OpenXcom/OpenXcom.git
FLAVOUR=vanilla # your definition of the source repo flavour
SHELL_PROFILE=~/.bashrc # your preferred shell profile to create an alias to the start script

# Parse command-line arguments
while getopts r:f:s: flag
do
    case "${flag}" in
        r) SOURCE_REPOSITORY=${OPTARG};;
        f) FLAVOUR=${OPTARG};;
        s) SHELL_PROFILE=${OPTARG};;
    esac
done

# Where the resulting build and user data will be
# This will NOT be overwritten if re-compiling a flavour, allowing to updated mostly seamlessly.
ROOT_GAME_DIRECTORY=/home/$USER/games/openxcom
ASSETS_DIRECTORY=$ROOT_GAME_DIRECTORY/$FLAVOUR/bin
USERDATA_ROOT_DIRECTORY=$ROOT_GAME_DIRECTORY/userdata/$FLAVOUR
USERDATA_USER_DIRECTORY=$USERDATA_ROOT_DIRECTORY/user
USERDATA_SAVES_DIRECTORY=$USERDATA_ROOT_DIRECTORY/saves
USERDATA_CONFIG_DIRECTORY=$USERDATA_ROOT_DIRECTORY/config


# Where the sources for the builds are
ROOT_SOURCE_DIRECTORY=/home/$USER/workspace/openxcom # the directory for all sources
SOURCE_REPOSITORY_DIRECTORY=$ROOT_SOURCE_DIRECTORY/$FLAVOUR #a folder per game version


BASE_ASSETS_PATH="/home/$USER/.local/share/Steam/steamapps/common/XCom UFO Defense/XCOM" # standard steam install path for linux
BASE_PATCHED_ASSETS_PATH=$ROOT_SOURCE_DIRECTORY/patched_assets
PATCH_PATH=$ROOT_SOURCE_DIRECTORY/universal-patch-ufo.zip
PATCH_URL=https://openxcom.org/download/extras/universal-patch-ufo.zip

ROOT_TARGET=$ROOT_GAME_DIRECTORY/$FLAVOUR
TARGET_ASSETS_PATH=$ROOT_TARGET/bin/UFO # replace with /bin/TFTD if using XCOM2 assets
TARGET_BUILD_PATH=$ROOT_TARGET/build
CMAKE_BUILD_TYPE=Release

# Root openxcom install directory that may contain several installations
mkdir -p $ROOT_GAME_DIRECTORY
echo "Base directory for installations is $ROOT_GAME_DIRECTORY"

# Assets handling
if [ ! -d "$BASE_PATCHED_ASSETS_PATH" ]; then
  if [ ! -f "$PATCH_PATH" ]; then
    echo "Patch not found $PATCH_PATH . Downloading from $PATCH_URL"
    wget -O $PATCH_PATH $PATCH_URL
  fi

  echo "Creating patched assets directory..."
  mkdir -p $BASE_PATCHED_ASSETS_PATH

  echo "Copying base assets from $BASE_ASSETS_PATH"
  cp -r "$BASE_ASSETS_PATH/"* "$BASE_PATCHED_ASSETS_PATH/"

  echo "Unzipping the patch..."
  unzip -o $PATCH_PATH -d $BASE_PATCHED_ASSETS_PATH
fi

# Cloning / Updating the source/flavour project
if [ ! -d "$SOURCE_REPOSITORY_DIRECTORY" ]; then
  echo "Cloning the source repository $SOURCE_REPOSITORY into $SOURCE_REPOSITORY_DIRECTORY..."
  git clone $SOURCE_REPOSITORY $SOURCE_REPOSITORY_DIRECTORY
else
  echo "Updating the source repository..."
  git -C $SOURCE_REPOSITORY_DIRECTORY pull
fi


# Copying patched assets to the target assets path
echo "Copying patched assets to the target directory..."
mkdir -p $TARGET_ASSETS_PATH
cp -r $BASE_PATCHED_ASSETS_PATH/* $TARGET_ASSETS_PATH/

# Building the project
echo "Creating build directory..."
mkdir -p $TARGET_BUILD_PATH

echo "Running cmake..."
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -S $SOURCE_REPOSITORY_DIRECTORY -B $TARGET_BUILD_PATH

echo "Compiling the project..."
make -C $TARGET_BUILD_PATH -j10

echo "Done."
echo "Executable ($TARGET_BUILD_PATH/build/bin/openxcom) uses assets from $ASSETS_DIRECTORY"

echo "Initialising Matching userdata structure"
mkdir -p $USERDATA_USER_DIRECTORY
echo "User directory (logs, mods, saves etc...) at $USERDATA_USER_DIRECTORY"
mkdir -p $USERDATA_CONFIG_DIRECTORY
echo "Config / Settings directory at $USERDATA_CONFIG_DIRECTORY"

# Generate starting script
START_SCRIPT=$ROOT_GAME_DIRECTORY/openxcom-$FLAVOUR.sh
echo "Generating starting script at $START_SCRIPT"
cat <<EOL > $START_SCRIPT
#!/bin/sh
"$TARGET_BUILD_PATH/bin/openxcom" \\
 -data "$ASSETS_DIRECTORY" \\
 -user "$USERDATA_USER_DIRECTORY" \\
 -config "$USERDATA_CONFIG_DIRECTORY"
EOL
chmod +x $START_SCRIPT

echo "alias openxcom-$FLAVOUR='$ROOT_GAME_DIRECTORY/openxcom-$FLAVOUR.sh'" >> $SHELL_PROFILE

echo "OpenXcom ($FLAVOUR) setup complete! Use 'openxcom-$FLAVOUR' command to start the game (source or restart shell)"

