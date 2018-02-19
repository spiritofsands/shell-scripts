#!/bin/bash

# All time should be set in minutes

workTime='25'
breakTime='5'

#==============================================================

title='Pomodoro timer'

askExit()
{
    status=$1
    if [[ $status -ne 0 ]]; then
        zenity --question --text='Close timer?' --title="$title"
        status=$?

        if [[ $status -eq 0 ]]; then
            exit 0
        fi
    fi
}

askContinue()
{
    subj="$1"
    zenity --question --text="Continue to $subj?" --title="$title"

    askExit $?
}

runTimer()
{
    time=$(( $1 * 60 ))
    subj=$2
    timeSeq="$( seq 1 $time )"
    for i in $timeSeq; do
        sleep '1s'
        echo $(( $i * 100 / $time ))
    done | zenity --progress --auto-close --text="${subj^} time" --title="$title"

    askExit $?

    notify-send "${subj^} is over"
}

while true; do
    runTimer $workTime 'sprint'
    askContinue 'break'

    runTimer $breakTime 'break'
    askContinue 'work'
done
#
