#!/bin/bash

wait_for_port () {
    CHECK_SVCS=$*
    for SVC_GROUP in $CHECK_SVCS; do
        while true; do
            RESPONDED="false"
            GROUP=${SVC_GROUP//\// }
            echo "Waiting one of $SVC_GROUP"
            for SVC in ${GROUP}; do
                HST=$(echo $SVC | cut -d ":" -f 1)
                PRT=$(echo $SVC | cut -d ":" -f 2)
                nc -z $HST $PRT
                if [ $? -ne 0 ];
                then
                    sleep 5
                    if (( ${SECONDS} > 600 )); then
                        echo "ABORTING WAITING FOR $SVC, TIMEOUT REACHED."
                        exit 10
                    fi
                else
                    RESPONDED="true"
                    echo "Service $SVC is up"
                    break
                fi
            done 
            if [ "${RESPONDED}" == "true" ]; then
                break
            fi
        done
    done
}

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

exit_script() {
    echo "Got signal. Killing child processes"
    trap - SIGINT SIGTERM # clear the trap
    kill -- -$$ # Sends SIGTERM to child/sub processes
    echo "Exiting"
    exit 0
}