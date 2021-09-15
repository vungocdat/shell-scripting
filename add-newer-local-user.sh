#!/bin/bash

# shell script that will add users to the same Linux system as the script is
# executed on
# the username and comment (optional)  will be given as argunets
# password will be generated with of of 'date' and 'sha256sum'
# username, password and host will be shown to the user
# the messages will be sent to the proper STDOUT or STDERR
#-----------------------------------------------------------------------------

# enforcing that it will be executed with superuser (root) privileges. If not
# it will not attemp to create a user and return exit status 1
# the message will be displayed on STDERR

if [[ "${UID}" -ne 0 ]]
  then
    echo "The script is not executed with root privileges" 1>&2
    exit 1
fi

# Provide a usage statement if user does not supply an username and return exit
# status of 1
# the message will be displayed on STDERR

if [[ ${#} -eq 0 ]]
  then
    echo "Usage: ${0} USER_NAME [COMMENT] ..." 1>&2
    echo " Create an user with USER_NAME on local system with comment of COMMENT" 1>&2
    exit 1
fi

# first argument will be treated as an USERNAME, the rest will be treated as a
# COMMENT
# both STDOUT and STDERR will be displayed. The error message is already
# managed by if statement

USERNAME=${1}
shift
COMMENT=${*}
useradd  -c "${COMMENT}" -m ${USERNAME} > /dev/null 2>&1

# informs that account was not able to be created for some reason. return exit
# status of 1
# the message will be displayed on STDERR

if [[ "${?}" -ne 0  ]]
  then
    echo "Something went wrong. try again." 1>&2
    exit 1
fi

# automatically generates a password for the new account
# the output wont be displayed
PASSWORD=$(date +%s%N | sha256sum | head -c 10)
echo ${PASSWORD} | passwd --stdin ${USERNAME} 1> /dev/null

# set a new password once log in
# the output wont be displayed
passwd -e ${USERNAME} 1> /dev/null


# display username, password and host

echo "Username: ${USERNAME}"
echo "Password: ${PASSWORD}"
echo "Hostname: ${HOSTNAME}"
exit 0;
