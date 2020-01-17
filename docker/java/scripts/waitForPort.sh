#!/bin/bash

wait_for_port () {

    if ! nc -h &> /dev/null; then
        echo "ERROR: [wait_for_port] nc not found, aborting script."
        exit 10
    fi 

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