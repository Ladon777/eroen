#!/bin/sh

# for media-libs/fmod
#export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}/opt/fmodex/fmoddesignerapi/api/lib"

# neither my libsdl2 or fmod work right for some reason
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}@VAR2@"

cd "@VAR0@"
exec "@VAR1@"
