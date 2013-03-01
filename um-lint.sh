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

# basis_var(file, variable)
#   Get the value of variable in file
function basis_var {
    file=$1
    var=$2
    # Match only multiple values
    sed -n $file -e '/\<'"$var"'=.*,\s*$/,/[^,]\s*$/s|.*'"'"'\s*\(\S\(.*\S\)\?\)\?\s*'"'"'\s*,\?\s*$|\1|p'
    # Match only one value
    sed -n $file -e 's|.*\<'"$var"'\s*=\s*'"'"'\s*\(\S\(.*\S\)\?\)\s*'"'"'\s*$|\1|p'
}

# check_var(file, variable, pattern)
#   Checks all values in variable match pattern, if they don't print an error
#   message for each case
function check_var {
    file=$1
    variable=$2
    pattern=$3

    basis_var $file $variable | sed '/^'${pattern}'$/d' | \
        sed -n 's|.*|'$(basename $file)': ERROR in '$variable', was "\0" but should match /'$pattern'/|p'
}

for file in "$@"; do
    # Basic set-up
    check_var $file USERID '\$USER'
    check_var $file TIC '\(\$PROJECT\|s*\)'
    check_var $file MACH_OTHER 'vayu'
    check_var $file SUBMIT_METHOD '0'

    # Log Files
    check_var $file PRINT_STATUS 'PrStatus_Normal'
    check_var $file UIPRINT 'N'
    check_var $file RCF_PRINTSTATUS '2'

    # Output directories
    check_var $file DATAM '\$DATAOUTPUT/\$USER/\$RUNID'
    check_var $file DATAW '\$DATAOUTPUT/\$USER/\$RUNID'

    # Environment directories
    check_var $file ENVAR_VAL '/data/projects/access/.*'

    # Hand edits
    check_var $file HEDFILE '\(~access/umdir/.*\|~access/umui_jobs/hand_edits/.*\)'
    check_var $file USE_HEDFILE 'Y'

    # FCM
    check_var $file UMFCM_OUTDIR '\$HOME/UM_OUTDIR'
    check_var $file UMFCM_ROUTDIR '\$DATAOUTPUT'
    check_var $file LFULL_EXT 'N'
    check_var $file FCM_VERB_EXT '1'
    check_var $file FCM_OUT_EXT '\$UM_OUTDIR/ext.out'
    check_var $file LFULL_BLD 'N'
    check_var $file FCM_VERB_BLD '1'

    # Branches
    check_var $file FCM_USRBRN_USE 'Y'
    check_var $file LFCM_USRWRKCP 'N'

    # Build - Model
    check_var $file OMUC '1'
    check_var $file FCM_COMP_GEN 'safe'
    check_var $file PATHEXEC '\$DATAW/bin'
    check_var $file FILEEXEC '\$RUNID.exe'
    check_var $file CONSD 'N'

    # Build - Recon
    check_var $file RECEX '1'
    check_var $file PATHREC '\$DATAW/bin'
    check_var $file FILEREC 'qxreconf'

    # Overrides
    check_var $file UMUSE_COP 'Y'
    check_var $file UFUSE_OP 'Y'

    # Input files
    check_var $file PATH20 '\$[A-Za-z0-9_]\+'
    check_var $file APATH '\$[A-Za-z0-9_]\+'
done
