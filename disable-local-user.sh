#!/bin/bash
#
# The script disables, deletes and/or archives users on the local system
# Disable by default



# Variables
ARCHIVE_DIR="/archive"




# Show the usage of the script like in manual pages
usage() {
  echo "Usage: ${0} [-dra] USER [USERN] ..." >&2
  echo "Disable a local Linux account." >&2
  echo "    -d  Deletes accounts instead of disabling them." >&2
  echo "    -r  Remove  home directoryassosiated with the account(s)." >&2
  echo "    -a  Create an archive of the home directory asssosiated with the account." >&2
  exit 1
}




# Make sure that the script is executed with root privileges
if [[ "${UID}" -ne 0 ]]
then
  echo "The script need root privileges." >&2
  exit 1
fi


# Parse options
while getopts dra OPTION
do
  case ${OPTION} in
    d) DELETE_USER='true' 
    ;;
    r) REMOVE_OPTION="-r"
    ;;
    a) ARCHIVE='true'
    ;;
    *) usage
    ;;
  esac
done


# Drop the optiong to get to arguments
shift "$(( OPTIND -1 ))"


# If no argument is given show the usage
if [[ "${#}" -lt 1 ]]
then
  usage
fi


# Loop thourgh all the arguments
for USERNAME in "${@}"
do
  echo "Executing the script for ${USERNAME}"

  # Check if it is a system user
  USER_ID=$(id -u ${USERNAME})
  if [[ "${USER_ID}" -lt 1000 ]]
  then
    echo "User ${USERNAME} with UID ${USER_ID} cannot be deleted or disabled." >&2
    exit 1
  fi

  # Create an archive if option "a" is given
  if [[ ${ARCHIVE} = 'true' ]]
  then
    # Check if /archive directory exists
    if [[ ! -d ${ARCHIVE_DIR} ]]
    then
      echo "Creating ${ARCHIVE_DIR} directory."
      mkdir -p ${ARCHIVE_DIR}
      if [[ "${?}" -ne 0 ]]
      then
        echo "Archive directory ${ARCHIVE_DIR} could not be created." >&2
        exit 1
      fi
    fi

    # Archive the user's directory with tar
    HOME_DIR="/home/${USERNAME}"
    TAR_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
    if [[ -d "${HOME_DIR}" ]]
    then
      echo "Creating a tar file for ${HOME_DIR} to ${TAR_FILE}"
      tar -czf "${TAR_FILE}" "${HOME_DIR}" &> /dev/null
      if [[ "${?}" -ne 0 ]]
      then
        echo "Could not create an archive ${TAR_FILE}" >&2
        exit 1
      fi
    else
      echo "${HOME_DIR} does not exists." >&2
      exit 1
    fi
  fi

  # Delete user if option "d" is given.
  # If option "r" is given it will also delete user's home directory
  if [[ "${DELETE_USER}" = 'true' ]]
  then
    userdel ${REMOVE_OPTION} ${USERNAME}
    if [[ "${?}" -ne 0 ]]
    then
      echo "${USERNAME} account was NOT deleted." >&2
      exit 1
    fi
    echo "The ${USERNAME} account was deleted."
  else
    # disable account by default - option "d" is not given
    chage -E 0 ${USERNAME}
    if [[ "${?}" -ne 0 ]]
    then
      echo "${USERNAME} account was NOT disabled." >&2
      exit 1
    fi
    echo "${USERNAME} account was disabled."
  fi
done

exit 0
