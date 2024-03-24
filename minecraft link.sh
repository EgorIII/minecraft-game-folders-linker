#!/bin/bash
echo 'Version from 24.03.24 1.2.1 modified and intended to run as Prism Launcher custom pre-launch command'

MinecratBackupFolder="$HOME/Backups/Game data/Minecraft"

           #WHERE GAME THINKS FILE IS AND LINK WILL BE     FOLDER WITH ACTUAL DATA TO BE LINKED TO
array=()
array+=("$INST_MC_DIR/screenshots" "$MinecratBackupFolder/screenshots")
array+=("$INST_MC_DIR/schematics" "$MinecratBackupFolder/schematics")
array+=("$INST_MC_DIR/resourcepacks" "$MinecratBackupFolder/resourcepacks")
array+=("$INST_MC_DIR/shaderpacks" "$MinecratBackupFolder/shaderpacks")

#for place in $array; do #loop
N=$((${#array[@]}/2-1)); echo "$(($N+1)) entires"
for i in $(seq 0 $N); do
place=${array[((2*$i))]} #selects first location in pair
ActualDataPlace=${array[$((2*$i+1))]} #selects second item in pair

function do_the_link { 
echo "ln --interactive --symbolic --verbose --no-target-directory \"$ActualDataPlace\" \"$place\""
ln --interactive --symbolic --verbose --no-target-directory "$ActualDataPlace" "$place"
}

# check if everything done already
if [ "$(readlink -f "$place")" = "${ActualDataPlace}" ]; then echo "Already there: $place"

# check if file is a link already
elif [ -L "${place}" ]; then echo "link '$place' -> '$(readlink -f "$place")' is to other location, changing"
    do_the_link

#test if folder empty
#elif ! ls -A1q "${place}" | grep -q .; then echo "Folder $place is empty removing and linking"
elif rm -d "${place}"; then echo "Folder '$place' was empty, removed and linking"
    do_the_link

#check if folder is not empty
elif [ -d "${place}" ]; then
    echo "$place exists"
    echo "ls  -Alh \"$place\""
    ls  -Alh "${place}"
    rsync --archive --verbose --remove-source-files  "$place" "${ActualDataPlace%/*}"
    echo "rm --dir \"${place}\""
    rm --dir "${place}"
    do_the_link

elif [ ! -e "${place}" ]; then echo "everything okay making parents"
    mkdir --parents --verbose "${place%/*}"                     #  %/* removes last thing idk
    do_the_link

fi; done
