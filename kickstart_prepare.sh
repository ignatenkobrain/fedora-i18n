#!/bin/bash

# Copyright 2014 Igor Gnatenko
# Author(s): Igor Gnatenko <i.gnatenko.brain AT gmail DOT com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# See http://www.gnu.org/copyleft/gpl.html for the full text of the license.

while getopts "f:" opts; do
  case "$opts" in
    f)
      fver=$OPTARG
      ;;
    *)
      echo "Wrong usage!"
      exit 1
      ;;
    esac
done

if [[ "$fver" == "rawhide" ]]; then
  fver="master"
fi
if [ -d "spin-kickstarts" ]; then
  rm -rf "spin-kickstarts"
fi
git clone https://git.fedorahosted.org/git/spin-kickstarts.git -b "$fver"

cat > temp.ks << EOF
repo --name=anaconda --baseurl=file://`pwd`/anaconda/repo/\$basearch --cost=9999
repo --name=anaconda-source --baseurl=file://`pwd`/anaconda/repo/SRPMS --cost=9999
%include ./spin-kickstarts/fedora-install-fedora.ks
EOF

exit 0

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
