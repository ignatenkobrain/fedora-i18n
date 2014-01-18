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
PKGS_ANACONDA="transifex-client fedpkg mock createrepo"
PKGS_KICKSTART="pungi sudo"
check_pkgs $PKGS_ANACONDA $PKGS_KICKSTART
if [ "$?" -eq "1" ]; then
  exit 1
fi

print_help ()
{
  echo "Usage: `basename $0` [-h] [-v] [-f <fver>] [-a <arches>]"
  echo ""
  echo "where:"
  echo "    -h show this help text"
  echo "    -v enable verbose mode"
  echo "    -f specify fedora version. for example: f20"
  echo "    -a arches separated by space. for example: x86_64 i386"
  exit $EXIT_CODE
}

while getopts "hva:f:" opts; do
  case "$opts" in
    h)
      EXIT_CODE=0
      print_help
      ;;
    v)
      set -x
      v="-v"
      ;;
    a)
      arch="$OPTARG"
      ;;
    f)
      fver=$OPTARG
      ;;
    *)
      EXIT_CODE=-1
      print_help
      ;;
    esac
done

if [ -z "$arch" ]; then
  arch="x86_64 i386"
fi
if [ -z "$fver" ]; then
  fver="rawhide"
fi

`dirname $(readlink -f $0)`/anaconda_prepare.sh -f $fver
`dirname $(readlink -f $0)`/anaconda_build.sh "$v" -f $fver -a "$arch"
`dirname $(readlink -f $0)`/kickstart_prepare.sh -f $fver
sudo `dirname $(readlink -f $0)`/kickstart_build.sh "$v" -f $fver -a "$arch"

exit 0

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
