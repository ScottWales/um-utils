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
dumpcode  = {'a':'instantaneous',
             'z':'instantaneous pre-run',
             't':'ten-day mean',
             'm':'monthly mean',
             's':'seasonal mean',
             'y':'yearly mean',
             '1':'period 1 mean',
             '2':'period 2 mean',
             '3':'period 3 mean',
             '4':'period 4 mean'}
ppcode    = {'a':'STASH stream "a"',
             'b':'STASH stream "b"',
             'c':'STASH stream "c"',
             'd':'STASH stream "d"',
             'e':'STASH stream "e"',
             'f':'STASH stream "f"',
             'g':'STASH stream "g"',
             'h':'STASH stream "h"',
             'i':'STASH stream "i"',
             'j':'STASH stream "j"',
             't':'ten-day mean',
             'm':'monthly mean',
             's':'seasonal mean',
             'y':'yearly mean',
             '1':'period 1 mean',
             '2':'period 2 mean',
             '3':'period 3 mean',
             '4':'period 4 mean'}

def filetype(code):
    if code[0] == "d":
        return ('model dump',dumpcode.get(code[1],'unknown'))
    elif code[0] == "p":
        return ('processed file',ppcode.get(code[1],'unknown'))
    else:
        return ('unknown','unknown')
def decodetime(clock, code):
    if clock == "standard":
        decade = 180 + int(code[0],36)
        decade_year = int(code[1])
        if code[2:] in month3:
            month = month3.index(code[2:]) + 1
            day = 0
            hour = 0
        elif code[2:] in season3:
            month = season3.index(code[2:]) + 1
            day = 0
            hour = 0
        else:
            month = int(code[2],12)
            day = int(code[3],31)
            hour = int(code[4],24)
        return "%03d%d-%02d-%02dT%02d"%(
                decade,
                decade_year,
                month,
                day,
                hour)
    elif clock == "long":
        century = int(code[0],36)
        century_year = int(code[1:3])
        if code[2:] in month2:
            month = month2.index(code[2:]) + 1
            day = 0
        elif code[2:] in season2:
            month = season2.index(code[2:]) + 1
            day = 0
        else:
            month = int(code[2],12)
            day = int(code[3],31)
        return "%02d%02d-%02d-%02d"%(
                century,
                century_year,
                month,
                day)
    else:
        return "unknown"
        
def decode(name):
    out = {}
    out['jobid'] = name[0:5]
    out['model'] = modelcode.get(name[5],'unknown')
    out['clock'] = clockcode.get(name[6],'unknown')
    out['type']  = filetype(name[7:9])
    out['date']  = decodetime(out['clock'],name[9:])
    return out

name = sys.argv[1]
traits = decode(name)

streamcode = {'pa':'monthly',
              'pe':'daily',
              'pj':'3hourly',
              'ph':'hourly'}

stream = streamcode.get(name[7:9],'unknown')
newname = '.'.join([traits['jobid'], stream, traits['date']])
print newname
