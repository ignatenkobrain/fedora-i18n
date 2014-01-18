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
if [ -d tmp ]; then
  sudo rm -rf tmp
fi
mkdir tmp
pushd tmp
# XXX: implement arch-builds
sudo pungi --nosource --nodebuginfo -c ../temp.ks --name "Fedora Trans `date '+%d%m%Y'`" --ver $release -G -C -B -I
popd
sudo find tmp/ -type d -name iso -exec chown -R $EUID {} \;

if [ ! -d iso ]; then
  mkdir iso
fi
dir_iso=`find tmp/ -type d -name iso`
mv "$dir_iso"/* iso/

exit 0

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
