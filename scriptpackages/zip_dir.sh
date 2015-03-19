#!/bin/sh

if [[ "$1" == "" ]] ; then
  echo "Missing argumen: directory to zip"
  exit 1
fi 

zip -r -j  $1.zip $1
