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
    echo "$0: Archive a UM output file to MDSS" 1>&2
    echo 1>&2
    echo "Usage: $0 [-h|--help] [-c|--cleanup] [-n|--netcdf] FILE RUNID" 1>&2
    echo "    --help:    Print this help and exit" 1>&2
    echo "    --cleanup: Remove the local file after copying" 1>&2
    echo "    --netcdf:  Convert to netcdf format" 1>&2
    echo 1>&2
    echo "    FILE:      File to archive" 1>&2
    echo "    RUNID:     Run id to store the file under" 1>&2
    echo "FILE and RUNID may also be passed in as environment variables of the same name" 1>&2
}

options=$(getopt --options hc --longoptions help,cleanup -- "$@")
eval set -- "$options"
cleanup=false
netcdf=false

while true; do
    case "$1" in
        -h|--help)
            usage; exit; shift ;;
        -c|--cleanup)
            cleanup=true; shift ;;
        -n|--netcdf)
            netcdf=true; shift ;;
        --)
            shift; break ;;
    esac
done

infile="${1:-$FILE}"
runid="${2:-$RUNID}"

if [[ -z "$infile" || -z "$runid" ]]; then
    usage
    exit 1
fi

if [[ ! -f "$infile" ]]; then
    echo "ERROR: No file $infile" 1>&2
    exit 2
fi

outfile=$(./decode.py $(basename $infile))

if [[ "$netcdf" == "true" ]]; then
    outfile=$outfile.nc
    # Convert to NetCDF with decoded name
    um2netcdf.py -i $infile -o $outfile
else
    cp $infile $outfile
fi

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
