#!/bin/bash
export LIBRARY_PATH=$(pwd)/lib/voidcsfml
export LD_LIBRARY_PATH="$LIBRARY_PATH"
crystal app/app.cr