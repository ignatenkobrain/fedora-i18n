#!/bin/bash

# Copyright 2014 Igor Gnatenko
# Author(s): Igor Gnatenko <i.gnatenko.brain AT gmail DOT com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# See http://www.gnu.org/copyleft/gpl.html for the full text of the license.

while getopts "vf:a:" opts; do
  case "$opts" in
    v)
      verbose="--verbose"
      ;;
    f)
      fver=$OPTARG
      ;;
    a)
      arch="$OPTARG"
      ;;
    *)
      echo "Wrong Usage!"
      exit 1
      ;;
    esac
done

if [[ "$fver" == "rawhide" ]]; then
  fver="rawhide"
  release="$fver"
else
  release="${fver#f}"
fi
for arch in $arch
do
  setarch $arch livecd-creator $verbose --config=./temp.ks --fslabel=$fver-LiveCD-`date "+%d%m%Y"`_$arch --cache=/var/cache/livecd --releasever=$release
done

exit 0

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
