#!/bin/bash

# Copyright 2014 Igor Gnatenko
# Author(s): Igor Gnatenko <i.gnatenko.brain AT gmail DOT com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# See http://www.gnu.org/copyleft/gpl.html for the full text of the license.

while getopts "va:f:" opts; do
  case "$opts" in
    a)
      arch="$OPTARG"
      ;;
    v)
      verbose="--verbose"
      ;;
    f)
      fver=$OPTARG
      ;;
    *)
      echo "Wrong usage!"
      exit 1
      ;;
    esac
done

if [ -d anaconda/repo ]; then
  rm -rf anaconda/repo
fi
mkdir -p anaconda/repo/SRPMS
if [[ "$fver" == "rawhide" ]]; then
  fver="rawhide"
else
  fver="${fver#f}"
fi
for arch in $arch
do
  mkdir anaconda/repo/$arch
  mock -r fedora-$fver-$arch --rebuild anaconda/*.src.rpm --resultdir anaconda/repo/$arch $verbose
  find anaconda/repo/$arch -type f -name "*.src.rpm" -or -name "*-debuginfo*.rpm" -delete
  createrepo anaconda/repo/$arch
done
cp anaconda/*.src.rpm anaconda/repo/SRPMS/
createrepo anaconda/repo/SRPMS

exit 0

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
