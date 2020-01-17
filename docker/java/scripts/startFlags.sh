#!/bin/bash

get_start_flag () {
    if [ -f /var/run/startflags/${1} ]; then
        cat /var/run/startflags/${1}
    else
        echo "none"
    fi
}

wait_for_start_flag () {
    while true; do
        echo "Checking if start flag ${1} is ${2}."
        local result=$(get_start_flag ${1})
        case ${result} in
            "none")
                echo "Start flag ${1} does not exist. Will continue to wait."
            ;;
            "${2}")
                echo "Start flag ${1} is ${2}. Continuing with startup..."
            ;;
            *)
                echo "Start flag ${1} is ${2}. Will continue to wait."
            ;;
        esac
        sleep 5
    done  
}

set_start_flag () {
    echo "Setting start flag ${1} to ${2}"
    echo -n "${2}" > /var/run/startflags/${1}
}
