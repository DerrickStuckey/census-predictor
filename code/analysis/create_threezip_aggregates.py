# -*- coding: utf-8 -*-
"""
Practicum 
Find 3-digit zipcode counts of relevant count variables
@author: Kit

"""
import csv
from itertools import groupby

###########################################################
# INPUT: select relevant columns from dataset
columns = [31,33,35,37,44,46]
columns.extend(range(48,63))

###########################################################

with open("PracticumData_FinalVersion_unprocessed.csv") as doc:
    data = [list(line) for line in csv.reader(doc)]
doc.close()

subset = []

for i in range(1,len(data)):
    threezip = data[i][0][:-2]
    row = data[i]
    entry = [row[0][:-2]]
    entry.extend(map(lambda x: row[x], columns))
    entry = map(float, entry)
    subset.append(entry)

results_sum = {}
results_avg = {}

for key, group in groupby(subset, lambda x: x[0]):
    results_avg[key] = list(map(lambda y: sum(y)/float(len(y)), zip(*group)))[1:]
    
for key, group in groupby(subset, lambda x: x[0]):
    results_sum[key] = list(map(lambda x: sum(x), zip(*group)))[1:]

names = list(data[0][i] for i in columns)
data[0].extend(map(lambda x: str(x + "_avg"), names))
data[0].extend(map(lambda x: str(x + "_sum"), names))
data[0].append("threezip")

for row in data[1:]:
    threezip = int(row[0][:-2])
    row.extend(results_avg[threezip])
    row.extend(results_sum[threezip])     
    row.append(threezip)

with open("Practicum_FinalVersion.csv", "wb") as out:
    writer = csv.writer(out)
    writer.writerows(data)
out.close()
