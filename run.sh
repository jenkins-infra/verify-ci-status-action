#!/bin/bash
set -euxo pipefail
if [ $GITHUB_EVENT_NAME = status ]
then
  state=$(jq -r .state < $GITHUB_EVENT_PATH)
  context=$(jq -r .context < $GITHUB_EVENT_PATH)
  sha=$(jq -r .sha < $GITHUB_EVENT_PATH)
  if [ $state = success -a $context = $CONTEXT -a $sha = $GITHUB_SHA ]
  then
    echo passing
  else
    echo not passing, or wrong status
    exit 1
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
