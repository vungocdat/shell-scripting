#!/bin/bash


# A list of servers
SERVER_LIST="/tmp/servers"


# Options for the ssh command
SSH_OPTIONS="-o ConnectTimeout=2"


# show this usage of this script
usage() {
  echo "Usage ${0} [-nsv] [ -f FILE ] COMMAND" >&2
  echo "Executes COMMAND as a single command on every server." >&2
  echo "    -f FILE   Use FILE for the list of servers. Default: ${SERVER_LIST}" >&2
  echo "    -n        Dry run mode. Display the COMMAND that would have been executed and exit." >&2
  echo "    -s        Execute the COMMAND using sudo on the remote server." >&2
  echo "    -v        Verbose mode. Display the server name before executing COMMAND."
  exit 1
 }


# Make sure that the script is not executed with superuser privileges
if [[ "${UID}" -eq 0 ]]
then
  echo "Do not execute this script with as root or with superuser privileges." >&2
  echo "Use the option \"-s\" "
  usage
fi


# Parse the options
while getopts f:nsv OPTION
do
  case ${OPTION} in
    f) SERVER_LIST="${OPTARG}" ;;
    n) DRY_RUN="true" ;;
    s) SUDO="sudo" ;;
    v) VERBOSE="true" ;;
    *) usage ;;
  esac
done


# remove (shift) the options to leave only arguments
shift "$(( OPTIND -1 ))"


# Check if at least one argument is given
if [[ "${#}" -lt 1 ]]
then
  usage
fi


# The aruments are treated as a single command
COMMAND="${@}"


# Check if SERVER_LIST file exists
if [[ ! -e "${SERVER_LIST}" ]]
then
  echo "File ${SERVER_LIST} does not exists." >&2
  exit 1
fi


# Exit status variable
EXIT_STATUS='0'


# Execute the command(s) through the SERVER_LIST
for SERVER in $(cat ${SERVER_LIST})
do
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${SERVER}"
  fi

  SSH_COMMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"

  # If it's dry drun, then dont execute the command(s). Just echo
  if [[ "${DRY_RUN}" = 'true' ]]
  then
    echo "DRY RUN: ${SSH_COMMAND}"
  else
    ${SSH_COMMAND}
    SSH_EXIT_STATUS="${?}"

    # Report any non-zero exit status from SSH_COMMAND to the user
    if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
    then
      EXIT_STATUS="${SSH_EXIT_STATUS}"
      echo "Execution on ${SERVER} failed." >&2
    fi
  fi
done

exit ${EXIT_STATUS}
