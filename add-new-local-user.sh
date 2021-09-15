#!/bin/bash

# shell script that will add users to the same Linux system as the script is
# executed on
# the username and comment (optional)  will be given as argunets
# password will be generated with of of 'date' and 'sha256sum'
# username, password and host will be shown to the user
#-----------------------------------------------------------------------------

# enforcing that it will be executed with superuser (root) privileges. If not
# it will not attemp to create a user and return exit status 1

if [[ "${UID}" -ne 0 ]]
  then
    echo "The script is not executed with root privileges"
    exit 1
fi

# Provide a usage statement if user does not supply an username and return exit
# status of 1

if [[ ${#} -eq 0 ]]
  then
    echo "Usage: ${0} USER_NAME [COMMENT] ..."
    echo " Create an user with USER_NAME on local system with comment of
    COMMENT"
    exit 1
fi

# first argument will be treated as an USERNAME, the rest will be treated as a
# COMMENT

USERNAME=${1}
shift
COMMENT=${*}
useradd  -c "${COMMENT}" -m ${USERNAME}

# automatically generates a password for the new account
PASSWORD=$(date +%s%N | sha256sum | head -c 10)
echo ${PASSWORD} | passwd --stdin ${USERNAME}

# set a new password once log in
passwd -e ${USERNAME}

# informs that account was not able to be created for some reason. return exit
# status of 1

if [[ "${?}" -ne 0  ]]
  then
    echo "Something went wrong. try again."
    exit 1
fi

# display username, password and host

echo
echo "Username: ${USERNAME}"
echo "Password: ${PASSWORD}"
echo "Hostname: ${HOSTNAME}"
exit 0;
