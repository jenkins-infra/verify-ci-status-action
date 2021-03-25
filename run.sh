#!/bin/bash
set -euo pipefail

function outputResult() {
  local result=$1
  local exitCode=$2

  echo $result

  if [ $OUTPUT_RESULT = true ]; then
    echo "::set-output name=result::$result"
    exit 0
  else
    exit $exitCode
  fi
}

if [ $GITHUB_EVENT_NAME = check_run ]
then
  if [ "$(jq -r .check_run.name < $GITHUB_EVENT_PATH)" \!= "$NAME" ]
  then
    outputResult wrong-check 1
  elif [ "$(jq -r .check_run.status < $GITHUB_EVENT_PATH)" \!= completed ]
  then
    outputResult not-completed 1
  elif [ "$(jq -r .check_run.conclusion < $GITHUB_EVENT_PATH)" \!= success ]
  then
    outputResult check-failed 1
  elif [ "$(jq -r .check_run.head_sha < $GITHUB_EVENT_PATH)" \!= $GITHUB_SHA ]
  then
    outputResult unexpected-commit 1
  else
    outputResult passed 0
  fi
elif [ $GITHUB_EVENT_NAME = workflow_dispatch ]
then
  ID=$(gh api -X GET -F check_name="$NAME" -F status=completed /repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/check-runs | jq -e '.check_runs | .[] | select(.conclusion == "success") | .id' || echo 'failed')

  if [[ $ID != 'failed' ]]; then
    outputResult passed 0
  else
    outputResult failed 1
  fi
else
  outputResult unknown-event-type-$GITHUB_EVENT_NAME 1
fi
