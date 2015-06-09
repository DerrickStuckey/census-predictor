# -*- coding: utf-8 -*-
"""
Practicum 
Find zipcode from latitude and longitude
@author: Kit

"""
import csv

with open("Farmers Markets by zip code (2011)_uncleaned.csv") as doc:
    markets = [list(line) for line in csv.reader(doc)]
doc.close()

zipcodes = {}
with open("zipcodes.csv") as doc:
    next(doc)
    for line in csv.reader(doc):
        zipcodes.setdefault(str(line[5].lower() + ", " + line[4].lower())\
        ,[]).append(str(line[0].lower() + ", " + line[1].lower() + ", " +\
        line[2].lower()))
doc.close()


for line in markets:
    if line[5].isdigit() == False:
        try:
            locations = zipcodes[str(line[3].lower() + ", " + line[8].lower())]
            lat = float(line[7])
            lon = float(line[6])        
            proximity = {}
            for loc in locations:
                loc = loc.split(',')
                ref_lat = float(loc[1])
                ref_lon = float(loc[2])
                proximity[((lat-ref_lat)**2+(lon-ref_lon)**2)] = loc[0]
            line[5] = proximity[min(proximity, key = proximity.get)]
        except ValueError:
            pass
        except KeyError:
            pass

with open("Farmers Markets by zip code (2011).csv", "wb") as out:
    writer = csv.writer(out)
    writer.writerows(markets)
        
        
        
