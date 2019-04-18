#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2017 Oracle and/or its affiliates. All rights reserved.
#
# Since: July, 2017
# Author: gerald.venzl@oracle.com
# Description: Runs user shell and SQL scripts
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Scripts modified in April 2019 by dennis.waterham@oracle.com

# Exit immediately if any command exits non-zero
set -eo pipefail

# Die function
die() { printf "ERROR: %s" "$1" >&2; exit 1; }

script_dir="$1"

# Check whether parameter has been passed on
[[ $script_dir ]] || die "No script directory provided. Scripts will not be run."

# Execute custom provided files (only if directory exists and has files in it)
if [[ -d $script_dir ]] && [[ $(ls -A "$script_dir") ]]; then

  printf "\nExecuting user defined scripts...\n"

  for script in $SCRIPTS_ROOT/*; do
    case "$script" in

      # Shell script
      *.sh)  printf "\n$0: running $f\n"
             . "$f";;

      # SQL file
      *.sql) printf "\n$0: running $f\n"
             $ORACLE_HOME/bin/sqlplus -s "/ as sysdba" @"$f";;

      # Other, ignore
      *)     printf "\n$0: ignoring $f\n";;
    esac
  done

  printf "\nDONE: Executing user defined scripts\n"

fi;
