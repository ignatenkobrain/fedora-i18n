#!/bin/bash

# Copyright 2014 Igor Gnatenko
# Author(s): Igor Gnatenko <i.gnatenko.brain AT gmail DOT com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# See http://www.gnu.org/copyleft/gpl.html for the full text of the license.

source `dirname $(readlink -f $0)`/check_pkgs.sh
check_pkgs "mock" "createrepo"
if [ "$?" -eq "1" ]; then
  exit 1
fi

print_help ()
{
  # XXX: implement help
  exit 0
}

while getopts "hdf:" opts; do
  case "$opts" in
    h)
      print_help
      ;;
    d)
      set -x
      verbose="--verbose"
      ;;
    f)
      fver=${OPTARG}
      ;;
    *)
      print_help
      ;;
    esac
done

if [ -d anaconda/repo ]; then
  rm -rf anaconda/repo
fi
mkdir -p anaconda/repo/{SRPMS,x86_64,i386}
if [ -z "$fver" ]; then
  fver="rawhide"
else
  fver="${fver#f}"
fi
for arch in x86_64 i386
do
  mkdir anaconda/repo/$arch
  mock -r fedora-$fver-$arch --rebuild anaconda/*.src.rpm --resultdir anaconda/repo/$arch $verbose
  find anaconda/repo/$arch -type f -name "*.src.rpm" -delete
  createrepo anaconda/repo/$arch
done
cp anaconda/*.src.rpm anaconda/repo/SRPMS/
createrepo anaconda/repo/SRPMS

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
