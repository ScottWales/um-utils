#!/bin/bash
# Script to set up the UM environment
#
# AUTHORS: 
# Scott Wales <scott.wales@unimelb.edu.au> 
# ARC Centre of Excellence for Climate System Science <climate_help@nf.nci.org.au>
#
# Available at https://github.com/ScottWales/um-utils
#
# ----------------------------------------------------------------------
# Copyright 2012 ARC Centre of Excellence for Climate System Science
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy
# of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.
# ----------------------------------------------------------------------
#

# Check for SVN privilages
echo "Checking for the Subversion server"
echo "Please enter your NCI password when prompted"
svn info https://access-svn.nci.org.au/svn/um 
if [[ $? != 0 ]] then
    echo "Error: Subversion access failed." >2
    echo "Please ask climate_help@nf.nci.au to enable svn access" >2
    exit 1
else
    echo "========================="
    echo "Subversion test succeeded"
    echo "========================="
fi

# Check for FCM
which fcm
if [[ $? != 0 ]] then
    echo "Unable to find FCM" >2
else
    echo "========================="
    echo "FCM test succeeded"
    echo "========================="
fi

# Get the Vayu certificates
mkdir --parents ~/.ssh
ssh-keyscan -t rsa {vu,vayu{,1,2,3}}{,.nci.org.au} 192.43.239.10{1,2,3} \
    >> ~/.ssh/known_hosts
echo "========================="
echo "Added Vayu certificates"
echo "========================="

echo "Generating a ssh key"
echo "Please create a secure password when prompted (Not your NCI password)"
echo "This will be your ssh passphrase"
echo "See http://xkcd.com/936/ for tips"
ssh-keygen -t rsa -f ~/.ssh/id_rsa

echo "Copying your public key to Vayu"
echo "Please enter your NCI password when prompted"
ssh-copy-id -i ~/.ssh/id_rsa.pub vayu.nci.org.au

echo "Setting up your accesscollab profile"
cat >> ~/.logout << EOF
# Kill the ssh-agent
ssh-agent -k
EOF
cat >> ~/.bash_logout << EOF
# Kill the ssh-agent
ssh-agent -k
EOF
cat >> ~/.login << EOF
# Start a ssh-agent
eval `ssh-agent -t 1d`
ssh-add -t 1d

# Vayu output path
setenv DATAOUTPUT /short/$PROJECT/$USER/UM_ROUTDIR
EOF
cat >> ~/.bash_profile << EOF
# Start a ssh-agent
eval `ssh-agent -t 1d`
ssh-add -t 1d

# Vayu output path
export DATAOUTPUT=/short/$PROJECT/$USER/UM_ROUTDIR
EOF

echo "Starting up the ssh-agent"
echo "Enter the passphrase you just created when prompted"
eval `ssh-agent -t 1d`
ssh-add -t 1d

echo "Setting up your vayu profile"
echo "You should not be prompted for a password"
ssh vayu 'cat >> ~/.login << EOF
# Vayu output path
setenv DATAOUTPUT /short/$PROJECT/$USER/UM_ROUTDIR
module load ~access/access.module
EOF'
ssh vayu 'cat >> ~/.profile << EOF
# Vayu output path
export DATAOUTPUT=/short/$PROJECT/$USER/UM_ROUTDIR
module load ~access/access.module
EOF'

