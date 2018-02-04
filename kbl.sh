#!/bin/bash

WRONG_ARGS=85

if [ -z $1 ]
then
    echo "Usage: $(basename $0) [ru|ua]"
    exit $WRONG_ARGS
fi

if [ "$1" == 'ru' ]
then
    notify-send "EN-RU"
    setxkbmap -layout us -option
    setxkbmap -layout us,ru -option "grp:caps_toggle,grpled:caps"
elif [ "$1" == 'ua' ]
then
    notify-send "EN-UA"
    setxkbmap -layout us -option
    setxkbmap -layout us,ua -option "grp:caps_toggle,grpled:caps"
elif [ "$1" == 'what' ]
then
    notify-send "$(setxkbmap -query | grep layout)"
fi
