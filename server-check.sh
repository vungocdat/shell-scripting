#!/bin/bash

# Ping server. If ping comes through the server is considered up otherwise it
# is considered down


# The file where servers are listed
SERVER_FILE="/tmp/servers"


# If the file does not exists, echo an error with exit status of 1
if [[ ! -e "${SERVER_FILE}" ]]
then
  echo "File ${SERVER_FILE} does not exists." >&2
  exit 1
fi

# Ping server(s)
for SERVER in $(cat ${SERVER_FILE})
do
  
  echo "Pinging ${SERVER}."
  ping -c 2 ${SERVER} &> /dev/null
  if [[ "${?}" -eq 0 ]]
  then
    echo "${SERVER} is UP."
  else
    echo "${SERVER} is DOWN."
  fi
  echo

done
