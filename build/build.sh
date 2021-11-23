#!/bin/bash

workspace_name=Equinox.xcworkspace

function build_scheme()
{
  workspace=$1
  scheme=$2
  destination=$3
  
  xcodebuild \
    -workspace "$workspace" \
    -scheme "$scheme" \
    -destination "$destination" \
    clean build
  
  if [ $? -ne 0 ] 
  then
    exit 1
  fi
}

cd "$(dirname "$0")/../"

build_scheme $workspace_name 'Equinox' 'platform=macOS,arch=x86_64'
