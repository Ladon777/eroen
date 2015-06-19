#!/bin/sh

# my libsdl2 does not work right for some reason
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}@VAR2@"

cd "@VAR0@"
exec "@VAR1@"
