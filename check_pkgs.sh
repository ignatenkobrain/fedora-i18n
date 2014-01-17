#!/bin/bash

# Copyright 2014 Igor Gnatenko
# Author(s): Igor Gnatenko <i.gnatenko.brain AT gmail DOT com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# See http://www.gnu.org/copyleft/gpl.html for the full text of the license.

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
    return 1
  else
    return 0
  fi
}

# vim:expandtab:tabstop=2:shiftwidth=2:softtabstop=2
