#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

update_am_pwd() {

    echo "setting CTS password..."
    java -jar /opt/amster/amadminpwdgen.jar -s \
    --baseDn ou=am-config  \
    --hostname localhost  \
    --port 2389  \
    --bindDn 'CN=Directory Manager'  \
    --bindPassword ${CFGDIR_PASS}  \
    -o 'ou=server-default,ou=com-sun-identity-servers,ou=default,ou=GlobalConfig,ou=1.0,ou=iPlanetAMPlatformService,ou=services'  \
    -t serverconfig=org.forgerock.services.cts.store.password  \
    -v ${CTSDIR_PASS}


    echo "setting root realm idRepo (datastore) password..."
    java -jar /opt/amster/amadminpwdgen.jar -s \
    --baseDn ou=am-config  \
    --hostname localhost  \
    --port 2389  \
    --bindDn 'CN=Directory Manager'  \
    --bindPassword ${CFGDIR_PASS}  \
    -o 'ou=OpenDJ,ou=default,ou=OrganizationConfig,ou=1.0,ou=sunIdentityRepositoryService,ou=services'  \
    -t sun-idrepo-ldapv3-config-authpw  \
    -v ${USRDIR_PASS}


    echo "setting amadmin password..."
    java -jar /opt/amster/amadminpwdgen.jar -s \
    --baseDn ou=am-config  \
    --hostname localhost  \
    --port 2389  \
    --bindDn 'CN=Directory Manager'  \
    --bindPassword ${CFGDIR_PASS}  \
    -o 'ou=amAdmin,ou=users,ou=default,ou=GlobalConfig,ou=1.0,ou=sunIdentityRepositoryService,ou=services'  \
    -t userPassword  \
    -v ${AMADMIN_PASS} \
    -a

# This must match the dsameuser password set in the AM keystore by ob-k8s-secrets 
# otherwise there are situations where AM can't authenticate with itself. 
# On a normal AM install this is set to be the same password as amadmin.
# TODO: make this different to amadmin for extra security. 

    echo "setting dsameuser password..."
    java -jar /opt/amster/amadminpwdgen.jar -s \
    --baseDn ou=am-config  \
    --hostname localhost  \
    --port 2389  \
    --bindDn 'CN=Directory Manager'  \
    --bindPassword ${CFGDIR_PASS}  \
    -o 'ou=dsameuser,ou=users,ou=default,ou=GlobalConfig,ou=1.0,ou=sunIdentityRepositoryService,ou=services'  \
    -t userPassword  \
    -v ${AMADMIN_PASS} \
    -a

}

update_am_pwd
echo "pre-configure completed in ${SECONDS} seconds."
