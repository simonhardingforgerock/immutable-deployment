#!/bin/bash
# This is a placeholder that you can replace with your own script to copy in assets such as images
# or a web.xml file.
# Some Environment variables that are available:
# CATALINA_HOME: The expanded openam war file is in $CATALINA_HOME/webapps/openam
# OPENAM_HOME
# DOMAIN: The cookie domain (includes leading .)
# NAMESPACE: The Kubernetes namespace
echo "AM customization script"
echo -n "changeit" > $OPENAM_HOME/secrets/defaultpass

wait_for_start_flag () {
    while true; do
        echo "Checking if start flag '${1}' is '${2}'."
        if [ -f /var/run/startflags/${1} ]; then
            if [ "$(< /var/run/startflags/${1})" == "${2}" ]; then
                echo "Start flag '${1}' is '${2}'. Continuing with startup..."
                break
            else
                echo "Start flag '${1}' is '${2}'. Will continue to wait."
            fi
        else
            echo "Start flag '${1}' does not exist. Will continue to wait."
        fi
        sleep 5
    done  
}

wait_for_start_flag "configstore" "started:passwords-changed"
wait_for_start_flag "cts" "ready"
