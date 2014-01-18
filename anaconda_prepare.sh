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
      exit -1
      ;;
    esac
done

if [ -d anaconda ]; then
  rm -rf anaconda
fi

if [[ "$fver" == "rawhide" ]]; then
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
  langs=`sed -e "/#/d" -e "s/ /,/g" po/LINGUAS`
  echo "Translation languages to update: $langs"
  tx pull -l "$langs"
popd
diff -uNr "${folder}.orig" "$folder" > i18n.patch
rm -rf "$folder" "${folder}.orig"
sed -i -e "/Release:/s/[0-9]/999/" anaconda.spec
sed -i -e "s/^\(Source0:.*\)/\1\nPatch0: i18n.patch/g" anaconda.spec
sed -i -e "s/^\(%setup.*\)/\1\n%patch0 -p1 -b .i18n/g" anaconda.spec
fedpkg srpm

exit $?

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
