#!/bin/bash

git fetch origin master:$1
git checkout $1
git push origin -u $1
