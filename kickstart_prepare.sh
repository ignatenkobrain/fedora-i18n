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
check_pkgs "git"
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
      ;;
    f)
      fver=${OPTARG}
      ;;
    *)
      print_help
      ;;
    esac
done

if [ -z "$fver" ]; then
  fver=master
fi
if [ -d "spin-kickstarts" ]; then
  rm -rf "spin-kickstarts"
fi
git clone https://git.fedorahosted.org/git/spin-kickstarts.git -b "$fver"

cat > temp.ks << EOF
repo --name=anaconda --baseurl=file://`pwd`/anaconda/repo/\$basearch --cost=9999
%include ./spin-kickstarts/fedora-livecd-desktop.ks
EOF

exit 0

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
