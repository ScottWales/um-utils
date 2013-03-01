#!/bin/bash
## \file    um-lint.sh
#  \author  Scott Wales (scott.wales@unimelb.edu.au)
#  \brief   Checks the format of a UM standard test run
#  
#  Copyright 2013 ARC Centre of Excellence for Climate System Science
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  

function usage {
    echo "$0: Check a UM standard test run"
    echo "Usage: $0 INPUTS ... > OUTPUT"
    echo "  INPUTS: UMUI basis files"
    echo "  OUTPUT: List of diagnostic messages"
}

# Get options
options=$(getopt --options h --longoptions help -- "$@")
eval set -- "$options"
while true; do
    case "$1" in
        -h|--help)
            usage; exit; shift ;;
        --)
            shift; break ;;
    esac
done
if [ "$#" -lt 1 ]; then
    echo "ERROR: No input" >&2
    usage
    exit 1
fi

function basis_var {
    file=$1
    var=$2
    # Match only multiple values
    sed -n $file -e '/\<'"$var"'=.*,\s*$/,/[^,]\s*$/s|.*'"'"'\s*\(\S\(.*\S\)\?\)\?\s*'"'"'\s*,\?\s*$|\1|p'
    # Match only one value
    sed -n $file -e 's|.*\<'"$var"'\s*=\s*'"'"'\s*\(\S\(.*\S\)\?\)\s*'"'"'\s*$|\1|p'
}

function check_var {
    file=$1
    var=$2
    match=$3

    basis_var $file $var | sed '/^'${match}'$/d' | wc -l
}

for file in "$@"; do
    check_var $file USERID '\$USER'
    check_var $file TIC '\(\$PROJECT\|s*\)'
done
