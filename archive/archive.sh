#!/bin/bash
## \file    archive.sh
#  \author  Scott Wales (scott.wales@unimelb.edu.au)
#  \brief   Archive a UM output file
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

#PBS -q copyq
#PBS -N umarchive
#PBS -j oe
#PBS -o ~/um_output
#PBS -l other=mdss
#PBS -l ncpus=1
#PBS -l walltime=10:00

function usage {
cat 1>&2 << EOF
$0: Archive a UM output file to MDSS"

Usage: $0 [-h|--help] [-c|--cleanup] [-n|--netcdf] FILE [RUNID]"
    --help:    Print this help and exit"
    --cleanup: Remove the local file after copying"
    --netcdf:  Convert to netcdf format"

    FILE:      File to archive"
    RUNID:     Run id to store the file under (default is 'test')"
FILE and RUNID may also be passed in as environment variables of the same name"
EOF
}

options=$(getopt --options hcn --longoptions help,cleanup,netcdf -- "$@")
eval set -- "$options"
cleanup=false
netcdf=false

while true; do
    case "$1" in
        -h|--help)
            usage; exit; shift ;;
        -c|--cleanup)
            cleanup=true; shift ;;
        --)
            shift; break ;;
    esac
done

infile=${1:-$FILE}
runid=${RUNID:-test}
runid="${2:-$runid}"

if [[ -z "$infile" || -z "$runid" ]]; then
    usage
    exit 1
fi

if [[ ! -f "$infile" ]]; then
    echo "ERROR: No file $infile" 1>&2
    exit 2
fi

# The output file will use a decoded timestamp
outfile=$(decode-um-filename.py $(basename $infile)).nc

# Convert to NetCDF with decoded name
um2netcdf.py -i $infile -o $outfile

# Compress and move to MDSS
gzip $outfile
mdss mkdir $USER/$runid
mdss put $outfile.gz $USER/$runid
mdss verify $USER/$runid/$outfile.gz

# Remove local files
if [[ "$cleanup" == "true" ]]; then
    rm -fv $infile
fi
rm -fv $outfile.gz
