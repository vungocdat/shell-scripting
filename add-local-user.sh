#!/bin/bash

# shell script that will add users to the same Linux system as the script is
# executed on
# the user will be asked to type in username, a full name as a comment and
# password
# those information will be displayed to the user
#-----------------------------------------------------------------------------

# enforcing that it will be executed with superuser (root) privileges. If not
# it will not attemp to create a user and return exit status 1
ROOT_NUMBER=0
if [[ "${UID}" -ne "${ROOT_NUMBER}" ]]
  then
    echo "The script is not executed with root privileges"
    exit 1
fi

# prompt user to enter username
read -p "Enter your username: " USER_NAME

# prompt user to enter real name
read -p "Enter your full name: " COMMENT

# prompt to enter initial password
read -p "Enter your password: " PASSWORD

# create a new local user with full name as a comment
useradd  -c "${COMMENT}" -m ${USER_NAME}

# informs that account was not able to be created for some reason. return exit
# status of 1
if [[ "${?}" -ne 0  ]]
  then
    echo "Something went wrong. try again."
    exit 1
fi

# set password for the user
echo "${PASSWORD}" | passwd --stdin ${USER_NAME}

# set a new password once log in
passwd -e ${USER_NAME}

# display username, password and host
echo "Username: ${USER_NAME}"
echo "Password: ${PASSWORD}"
echo "Hostname: ${HOSTNAME}"
exit 0;
