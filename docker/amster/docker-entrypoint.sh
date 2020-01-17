#!/bin/bash

set -eup pipefail

DS_INSTANCES="fr-ds-ctsstore-0.fr-ds-ctsstore:1389/fr-ds-ctsstore-1.fr-ds-ctsstore:1389"
DS_INSTANCES="${DS_INSTANCES} fr-ds-dynamic-configstore-0.fr-ds-dynamic-configstore:1389/fr-ds-dynamic-configstore-1.fr-ds-dynamic-configstore:1389"

trap exit_script SIGINT SIGTERM SIGUSR1 EXIT

exit_script() {
    echo "Got signal. Killing child processes"
    trap - SIGINT SIGTERM # clear the trap
    kill -- -$$ # Sends SIGTERM to child/sub processes
    echo "Exiting"
    exit 0
}

configure () {
    while true; do
        if [ "$(get_start_flag configstore)" == "starting:unconfigured" ]; then
            echo "Configstore has been started in an unconfigured state, beginning configuration."
            wait_for_port localhost:2389
            set_start_flag configstore started:unconfigured
            /opt/amster/pre-configure-passwords.sh
            set_start_flag configstore started:passwords-changed
            wait_for_port ${DS_INSTANCES}
            set_start_flag cts ready
            /opt/amster/amster-install.sh
            set_start_flag configstore ready
            echo "Sleeping until config store needs to be reconfigured."
        fi
        sleep 5
    done
}


case $1  in
    configure)
        configure
    ;;
    *) 
        exec "$@"
    ;;
esac
