# -*- coding: utf-8 -*-
"""
Created on Mon Jun 08 15:50:11 2015

@author: Kit
"""

from BeautifulSoup import BeautifulSoup
import urllib2
import csv

states = ["DC"]

with open("states.csv") as doc:
    [states.append(state.strip("\n")) for state in doc]
doc.close()

zips = []

for state in states:
    
    url= str("http://www.target.com/store-locator/state-result?stateCode=" + state)
    hdr = {'User-Agent': 'Mozilla/5.0'}
    req = urllib2.Request(url,headers=hdr)
    page = urllib2.urlopen(req)
    soup = BeautifulSoup(page)
    
    content = soup.fetch("tr")
       
    for i in range(len(content)):
        match = content[i].contents[7].contents[0]
        try:
            pos = match.index(state)
            zips.append(match[pos+2:pos+7])
        except ValueError:
            pass        

with open("Target Locations by zip code (2015).csv", "wb") as out:
    writer = csv.writer(out)
    for zipcode in zips:
        writer.writerow([zipcode])
out.close()
    