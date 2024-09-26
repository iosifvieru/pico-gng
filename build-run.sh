#!/bin/bash -i
# created by Iosif Vieru.
# 26.09.2024

OPTSTRING=":qhd"
QUIET=false
DEBUG=false

PICOTOOL_PATH=$(which picotool)

usage()
{
    echo "Invalid options. Use -h for more informations."
    exit 1;
}

help()
{
    printf "
        Usage
            $0 [options]
        Options
            -q \t\t = Quiet mode -> the program won't print details about the build and run execution.
            -h \t\t = Help -> details about usage and options.
            -d \t\t = Debug -> prints stdio usb communcation
    
    "
}

while getopts ${OPTSTRING} opt; do
    case ${opt} in
        q)
            QUIET=true
            echo "Quiet mode on."
            ;;
        h)
            help
            exit 1;
            ;;
        d)
            DEBUG=true
            echo "Debug mode on."
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

# cmake
if $QUIET; then
    cmake build/ > /dev/null 2>&1
else
    cmake build/
fi

if [ $? -eq 0 ]; then
    echo "CMake executed succesfully."
else
    echo "Ooooops..... something went wrong."
fi

# ninja
if $QUIET; then
    ninja all > /dev/null 2>&1
else
    ninja all
fi

if [ $? -eq 0 ]; then
    echo "Ninja executed succesfully."
else 
    echo "Ooooops..... something went wrong."
fi

# loading the .elf to pico
if [ -z "$PICOTOOL_PATH" ]; then
    echo "picotool not found. try \"sudo apt-get install picotool\" "
else
    current_path=`pwd`
    sudo $PICOTOOL_PATH load $current_path/build/pico-gng.elf -fx
fi

# see what s going on
if $DEBUG; then
    sleep 1
    screen /dev/ttyACM0 115200 &

    if [ $? -eq 0 ]; then
        echo "It seems to be an error accesing /dev/ttyACM0."
        echo "Try running \"screen /dev/ttyACM0 115200\" manually insead."
    fi
fi