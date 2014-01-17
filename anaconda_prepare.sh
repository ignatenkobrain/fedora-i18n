#!/bin/bash

# Copyright 2014 Igor Gnatenko
# Author(s): Igor Gnatenko <i.gnatenko.brain AT gmail DOT com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# See http://www.gnu.org/copyleft/gpl.html for the full text of the license.

EXIT_CODE=0

print_help ()
{
  echo "Usage: `basename $0` [-h] [-l lang] [-f fver] [-d]"
  echo ""
  echo "where:"
  echo "    -h show this help text"
  echo "    -l specify languages (separate by comma). https://git.fedorahosted.org/cgit/anaconda.git/plain/po/LINGUAS"
  echo "    -f specify fedora version. for example: f20"
  echo "    -d enable debugging"
  exit $EXIT_CODE
}

black='\E[0;30m'
red='\E[0;31m'
green='\E[0;32m'

# color-echo
# $1 - message
# $2 - color
cecho ()
{
  local default_msg="No message passed."
  message=${1:-$default_msg}   # Defaults to default message.
  color=${2:-$black}           # Defaults to black, if not specified.
  echo -ne "$color"
  echo "$message"
  tput sgr0
  return
} 

check_pkgs ()
{
  local failed=0
  for pkg in "$@"
  do
    echo "Checking for $pkg.."
    rpm -q $pkg &>/dev/null
    if [ $? -eq 1 ]; then
      cecho "-> Install $pkg!" $red
      let failed++
    else
      cecho "-> Found $pkg" $green
    fi
  done
  if [ $failed -gt 0 ]; then
    EXIT_CODE=1
    exit $EXIT_CODE
  else
    return
  fi
}

while getopts "hdl:f:" opts; do
  case "$opts" in
    h)
      print_help
      ;;
    d)
      set -x
      ;;
    l)
      langs=${OPTARG}
      ;;
    f)
      fver=${OPTARG}
      ;;
    *)
      print_help
      ;;
    esac
done

PKGS="transifex-client fedpkg"
check_pkgs $PKGS

if [ -d anaconda ]; then
  rm -rf anaconda
fi

if [ -z "$fver" ]; then
  fver="master"
  branch="$fver"
else
  branch="$fver-branch"
fi
fedpkg clone --anonymous anaconda --branch "$fver"
cd anaconda
fedpkg sources
archive=`basename *.tar.bz2`; folder="${archive%%.tar.bz2}"
tar xf "$archive"
pushd "$folder"
  mkdir -p .tx/
  curl "https://git.fedorahosted.org/cgit/anaconda.git/plain/.tx/config?h=$branch" -o .tx/config
popd
cp -pR "$folder" "${folder}.orig"
pushd "$folder"
  if [ -z "$langs" ]; then
    langs=`sed -e "/#/d" -e "s/ /,/g" po/LINGUAS`
  fi
  echo "Translation languages to update: $langs"
  tx pull -l "$langs"
popd
diff -uNr "${folder}.orig" "$folder" > i18n.patch
rm -rf "$folder" "${folder}.orig"
sed -i -e "s/^\(Source0:.*\)/\1\nPatch0: i18n.patch/g" anaconda.spec
sed -i -e "s/^\(%setup -q\)/\1\n%patch0 -p1 -b .i18n/g" anaconda.spec
fedpkg srpm

EXIT_CODE=$?
exit $EXIT_CODE

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
