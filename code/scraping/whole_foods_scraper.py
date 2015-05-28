#!/usr/bin/python

import requests
from urlparse import urljoin
from contextlib import closing
import csv
from bs4 import BeautifulSoup
from collections import defaultdict

csv_filename = "./whole_foods_zip_counts.csv"

base_url = "http://www.wholefoodsmarket.com/stores/list/state?page="

def run_page_query(page_number):
    query_url = base_url + str(page_number)
    print query_url
    with closing(requests.get(query_url, stream=False)) as response:
        # Check that the response was successful
        if response.status_code == 200:
            soup = BeautifulSoup(response.text)
            return soup
        else:
            raise IOError("Response code ", response.status_code, " returned from query ", query_url)

def write_results(zip_counts):
    with open(csv_filename, 'wb') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        writer.writerow(['zip_code','store_count'])
        for zip_code in zip_counts.keys():
            writer.writerow([zip_code,str(zip_counts[zip_code])])

# pages range from 0 to 21
page_numbers = [str(x) for x in range(0,22,1)]

print page_numbers

zip_counts = defaultdict(lambda:0)

#iterate through each page, counting by zip code
for page_number in page_numbers:
    current_page_soup = run_page_query(page_number)
    postal_code_spans = current_page_soup.findAll(name='span', attrs={'class':'postal-code'})

    #increment the count for each postal code found
    for postal_code_span in postal_code_spans:
        postal_code = postal_code_span.text[:5]
        print(postal_code)
        zip_counts[postal_code] += 1

for zip_code in zip_counts.keys()[0:10]:
    print zip_code
    print zip_counts[zip_code]

write_results(zip_counts)


#dbg:
# page_0_soup = run_page_query(0)
# print(page_0_soup.prettify())
# postal_codes = page_0_soup.findAll(name='span', attrs={'class':'postal-code'})
#
# print len(postal_codes)
# print postal_codes[0:4]