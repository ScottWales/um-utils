#!/bin/bash
## \file    server.sh
#  \author  Scott Wales (scott.wales@unimelb.edu.au)
#  \brief   Server to delegate archiving of UM files
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

# Monitor STDIN for new output
while true; do
    read magic filename request type

    if [[ $? == 0 ]]; then
        if [[ ! "$magic" == "%%%" ]]; then continue; fi
        if [[ "$request" == "ARCHIVE" ]]; then
            archive $filename
        fi
    else
        # No new input
        if [[ ! -f "$lockfile" ]]; then break; fi
        sleep 10
    fi
done
