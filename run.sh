#!/bin/bash
set -euxo pipefail
if [ $GITHUB_EVENT_NAME = check_run ]
then
  if [ "$(jq -r .check_run.name < $GITHUB_EVENT_PATH)" \!= "$NAME" ]
  then
    echo wrong check
    exit 1
  elif [ "$(jq -r .check_run.status < $GITHUB_EVENT_PATH)" \!= completed ]
  then
    echo not completed
    exit 1
  elif [ "$(jq -r .check_run.conclusion < $GITHUB_EVENT_PATH)" \!= success ]
  then
    echo did not succeed
    exit 1
  elif [ "$(jq -r .check_run.head_sha < $GITHUB_EVENT_PATH)" \!= $GITHUB_SHA ]
  then
    echo unexpected commit
    exit 1
  else
    echo passing
  fi
elif [ $GITHUB_EVENT_NAME = workflow_dispatch ]
then
  gh api -X GET -F check_name="$NAME" -F status=completed /repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs | jq -e '.check_runs | .[] | select(.conclusion == "success") | .id'
else
  echo unknown event type $GITHUB_EVENT_NAME
  exit 1
fi
