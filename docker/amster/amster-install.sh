#!/bin/bash

set -euo pipefail

source /opt/scripts/waitForPort.sh

DIR=`pwd`

# Path to script location - this is *not* the path to the amster/*.json config files - it is the path
# to  *.amster scripts.
AMSTER_SCRIPTS=${AMSTER_SCRIPTS:-"${DIR}/scripts"}

# Default directory for optional post install scripts. Anything in this directory will be executed after
# all amster scripts have run.
POST_INSTALL_SCRIPTS=${POST_INSTALL_SCRIPTS:-"${AMSTER_SCRIPTS}"}


# Use 'openam' as the internal cluster dns name.
export SERVER_URL=${OPENAM_INSTANCE:-http://openam:8080}
export URI=${SERVER_URI:-/}

export INSTANCE="${SERVER_URL}${URI}"

# Alive check
ALIVE="${INSTANCE}/isAlive.jsp"
# Config page. This comes up if AM is not configured.
CONFIG_URL="${INSTANCE}/config/options.htm"

# Wait for AM to come up before configuring it.
# Curl times out after 2 minutes regardless of the --connect-timeout setting.
# todo: Find a faster way to test for AM readiness
wait_for_openam()
{
    # If we get lucky, AM will be up before the first curl command is issued.
    sleep 5
    local response="000"

    while true; do
        response=$(curl --fail --write-out %{http_code} -sS --connect-timeout 30 --output /dev/null ${CONFIG_URL}  || echo "000")
        echo "Got Response code $response"
        if [ ${response} = "302" ] || [ ${response} = "301" ]; then
            echo "Checking to see if AM has been set up."
        
            if ! curl --output /dev/null -sS ${CONFIG_URL} | grep -q "Configuration"; then
                break
            fi
            echo "ERROR: It looks like AM has not been set up, aborting."
            exit 0
        fi
      if [ ${response} = "200" ]; then
         echo "AM web app has been set up and is ready to receive runtime configuration."
         break
      fi

      echo "response code ${response}. Will continue to wait"
      sleep 5
   done

	# Sleep additional time in case DS is not quite up yet.
	echo "About to begin configuration"
}


echo "Waiting for AM server at ${CONFIG_URL} "

wait_for_openam

# Extract amster version for commons parameter to modify configs
echo "Extracting amster version"
./amster --version
VER=$(./amster --version)
[[ "$VER" =~ ([0-9].[0-9].[0-9]-([a-zA-Z][0-9]+|SNAPSHOT|RC[0-9]+)|[0-9].[0-9].[0-9].[0-9]|[0-9].[0-9].[0-9]) ]]
export VERSION=${BASH_REMATCH[1]}
echo "Amster version is: " $VERSION

# Execute Amster if the configuration is found.
if [ -d  ${AMSTER_SCRIPTS} ]; then
    if [ ! -r /var/run/secrets/amster/id_rsa ]; then
        echo "ERROR: Can not find the Amster private key"
        exit 1
    fi

    echo "Executing Amster to configure AM"
    # Need to be in the amster directory, otherwise Amster can't find its libraries.
    cd ${DIR}
    for file in ${AMSTER_SCRIPTS}/*.*
    do
        case "${file##*.}" in
        'amster')
            echo "Executing Amster script $file"
            sh ./amster -q ${file}
        ;;
        'sh')
            echo "Executing shell script $file"
            bash ${file}
        ;;
        esac
    done
fi

# Execute any shell scripts ending with *sh
if [ -d ${POST_INSTALL_SCRIPTS} ]; then
    for script in ${POST_INSTALL_SCRIPTS}/*.sh
    do
        if [ -x ${script} ]; then
            echo "Executing $script"
            ${script}
        fi
    done
fi


echo "Configuration script finished"
echo "Completed in ${SECONDS} seconds."