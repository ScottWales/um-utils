#!/usr/bin/env python
"""
file:   decode-name.py
author: Scott Wales (scott.wales@unimelb.edu.au)

Copyright 2013 ARC Centre of Excellence for Climate System Science

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import sys
import re

month3 = "jan feb mar apr may jun jul aug sep oct nov dec".split()
season3 = "djf jfm fma mam amj mjj jja jas aso son ond ndj".split()
month2 = "ja fb mr ar my jn jl ag sp ot nv dc".split()
season2 = "df jm fa mm aj mj ja js ao sn od nj".split()

modelcode = {'a':'atmosphere'}
clockcode = {'_':'relative',
             '.':'standard',
             '-':'short',
             '@':'long'}

def filetype(code):
    if code[0] == "d":
        return "dump of " + dumptype(code[1])
    else:
        return "unknown"
def dumptype(code):
    if re.match('[a-j]',code):
        return "STASH stream " + code
    else:
        return "unknown"
def decodetime(clock, code):
    if clock == "standard":
        decade = int(code[0],36)
        decade_year = int(code[1])
        month = code[2:-2]
        if month in month3:
            month = month3.index(month) + 1
        elif month in season3:
            month = season3.index(month) + 1
        else:
            month = int(month,12)
        day = int(code[-2],31)
        hour = int(code[-1],24)
        return "%03d%d-%02d-%02dT%02d:00:00"%(
                decade,
                decade_year,
                month,
                day,
                hour)
    elif clock == "long":
        century = int(code[0],36)
        century_year = int(code[1:3])
        month = code[3:-1]
        if month in month2:
            month = month2.index(month) + 1
        elif month in season2:
            month = season2.index(month) + 1
        else:
            month = int(month,12)
        day = int(code[-1],31)
        return "%02d%02d-%02d-%02d"%(
                century,
                century_year,
                month,
                day)
    else:
        return "unknown"
        

name = sys.argv[1]

jobid = name[0:5]
model = modelcode.get(name[5],'unknown')
clock = clockcode.get(name[6],'unknown')
file  = filetype(name[7:9])
time  = decodetime(clock,name[9:])

print "Job ID " + jobid
print "Model type " + model
print "Clock " + clock
print "File " + file
print "Time " + time
