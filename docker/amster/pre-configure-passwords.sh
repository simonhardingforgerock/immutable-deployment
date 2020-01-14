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

    echo "setting root realm idRepo password..."
    java -jar /opt/amster/amadminpwdgen.jar -s \
    --baseDn ou=am-config  \
    --hostname localhost  \
    --port 2389  \
    --bindDn 'CN=Directory Manager'  \
    --bindPassword ${CFGDIR_PASS}  \
    -o 'ou=OpenDJ,ou=default,ou=OrganizationConfig,ou=1.0,ou=sunIdentityRepositoryService,ou=services'  \
    -t sun-idrepo-ldapv3-config-authpw  \
    -v ${USRDIR_PASS}

    echo "setting open banking realm idRepo(datastore) password..."
    java -jar /opt/amster/amadminpwdgen.jar -s \
    --baseDn ou=am-config  \
    --hostname localhost  \
    --port 2389  \
    --bindDn 'CN=Directory Manager'  \
    --bindPassword ${CFGDIR_PASS}  \
    -o 'ou=OpenDJ,ou=default,ou=OrganizationConfig,ou=1.0,ou=sunIdentityRepositoryService,ou=services,o=openbanking,ou=services'  \
    -t sun-idrepo-ldapv3-config-authpw  \
    -v ${USRDIR_PASS}

    echo "setting auth realm idRepo (datastore) password..."
    java -jar /opt/amster/amadminpwdgen.jar -s \
    --baseDn ou=am-config  \
    --hostname localhost  \
    --port 2389  \
    --bindDn 'CN=Directory Manager'  \
    --bindPassword ${CFGDIR_PASS}  \
    -o 'ou=OpenDJ,ou=default,ou=OrganizationConfig,ou=1.0,ou=sunIdentityRepositoryService,ou=services,o=auth,ou=services'  \
    -t sun-idrepo-ldapv3-config-authpw  \
    -v ${USRDIR_PASS}

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

    echo "setting dynamic datastore password..."
    java -jar /opt/amster/amadminpwdgen.jar -s \
    --baseDn ou=am-config  \
    --hostname localhost  \
    --port 2389  \
    --bindDn 'CN=Directory Manager'  \
    --bindPassword ${CFGDIR_PASS}  \
    -o 'ou=OB OAuth2 Client Store,ou=dataStoreContainer,ou=default,ou=GlobalConfig,ou=1.0,ou=amDataStoreService,ou=services'  \
    -t bindPassword  \
    -v ${CFGDIR_PASS}

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
# TODO: make this different to amadmin for extra security. Will require different 
# value set in ob-k8s-secrets.

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

    echo "enabling connection handler on 2389 so AM can start..."
    /opt/opendj/bin/dsconfig set-connection-handler-prop \
            --handler-name LDAP \
            --set enabled:true \
            --hostname localhost \
            --port 2444 \
            --bindDn c'n=Directory Manager' \
            --bindPassword ${CFGDIR_PASS} \
            --trustAll \
            --no-prompt

}

update_am_pwd
echo "pre-configure completed in ${SECONDS} seconds."
