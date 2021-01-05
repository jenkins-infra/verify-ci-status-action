#!/bin/bash
set -euxo pipefail
if [ $GITHUB_EVENT_NAME = check_run ]
then
  jq . < $GITHUB_EVENT_PATH
  if [ $(jq -r .check_run.name < $GITHUB_EVENT_PATH) \!= $NAME ]
  then
    echo wrong check
    exit 1
  elif [ $(jq -r .check_run.status < $GITHUB_EVENT_PATH) \!= completed ]
  then
    echo not completed
    exit 1
  elif [ $(jq -r .check_run.conclusion < $GITHUB_EVENT_PATH) \!= success ]
  then
    echo did not succeed
    exit 1
  elif [ $(jq -r .check_run.head_sha < $GITHUB_EVENT_PATH) \!= $GITHUB_SHA ]
  then
    echo unexpected commit
    exit 1
  else
    echo passing
  fi
elif [ $GITHUB_EVENT_NAME = workflow_dispatch ]
then
  if gh api /repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/statuses | jq -e '.[] | select(.context == "'$CONTEXT'" and .state == "success")'
  then
    echo passing
  else
    echo not passing
    exit 1
  fi
else
  echo unknown event type $GITHUB_EVENT_NAME
  exit 1
fi
