#!/bin/bash

# GLOBAL VARIABLES

workspace_name=Equinox.xcworkspace

# FUNCTIONS

function test_scheme()
{
  workspace=$1
  scheme=$2
  destination=$3
  
  xcodebuild \
    -workspace "$workspace" \
    -scheme "$scheme" \
    -destination "$destination" \
    test
  
  if [ $? -ne 0 ] 
  then
    exit 1
  fi
}

# ACTION

cd "$(dirname "$0")/../"

test_scheme $workspace_name 'EquinoxCoreTests' 'platform=macOS,arch=x86_64'
