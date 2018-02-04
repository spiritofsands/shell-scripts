#!/bin/bash

# find -p /path/a/b/c

set -f

editor='vim'
maxResults=30

args=''
path=''
while [[ $# -ne 0 ]]; do
    case $1 in
        -p)
            shift
            if [[ -z $1 ]]; then
                echo "No path was specified"
                exit 85;
            else
                while [[ -n $1 ]]; do
                    path+="$1 "
                    shift
                done
            fi
            ;;
        -e)
            edit='y'
            ;;
        *)
            args+="$1 "
            ;;
    esac

    shift
done

args=${args% }

if [[ "$edit" == 'y' ]]; then
    findResults=($(find $path $args))
    count=${#findResults[@]}

    if [[ $count -eq 0 ]]; then
        echo "No results."
        exit 0;
    elif [[ $count -ne 1 ]]; then
        if [[ $count -gt "$maxResults" ]]; then
            echo "Too much results: $count. Trimming to $maxResults."
            count=$maxResults
        fi

        echo "Choose from $count results:"
        for (( i=0; i<count; i++ )); do
            printf "%2d: %s\n" $((i+1)) ${findResults[i]}
        done

        echo
        read "-n${#count}" -p "Choice> " index
        ((index--))
        echo
    else
        index=0;
    fi

    echo "$editor ${findResults[index]}"
    $editor "${findResults[index]}"
else
    find $path $args
fi

exit 0
