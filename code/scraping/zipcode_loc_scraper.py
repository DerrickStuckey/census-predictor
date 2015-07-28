__author__ = 'dstuckey'


import requests
from urlparse import urljoin
from contextlib import closing
import csv
from bs4 import BeautifulSoup
from collections import defaultdict

input_filename = "../../raw_data/missing_loc_zips.csv"
csv_filename = "../../raw_data/zipcode_locs_scraped.csv"

base_url = "http://zipcode.org/"

zip_latitudes = {}
zip_longitudes = {}

def run_page_query(zipcode):
    query_url = base_url + str(zipcode)
    print query_url
    with closing(requests.get(query_url, stream=False)) as response:
        # Check that the response was successful
        if response.status_code == 200:
            soup = BeautifulSoup(response.text)
            return soup
        else:
            raise IOError("Response code ", response.status_code, " returned from query ", query_url)

def write_results():
    with open(csv_filename, 'wb') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        writer.writerow(['zip_code','latitude','longitude'])
        for zip_code in zip_latitudes.keys():
            writer.writerow([zip_code,str(zip_latitudes[zip_code]),str(zip_longitudes[zip_code])])

def find_single_zip_loc(zipcode):
    thesoup = run_page_query(zipcode)
    block_labels = thesoup.findAll(name='div', attrs={'class':'Zip_Code_HTML_Block_Label'})
    block_texts = thesoup.findAll(name='div', attrs={'class':'Zip_Code_HTML_Block_Text'})

    block_labels_contents = [x.text.strip() for x in block_labels]
    block_texts_contents = [x.text.strip() for x in block_texts]

    latitude = block_texts_contents[5]
    longitude = block_texts_contents[6]

    zip_latitudes[zipcode] = latitude
    zip_longitudes[zipcode] = longitude

# read in input zip codes
with open(input_filename, 'rb') as input_file:
    reader = csv.reader(input_file)
    input_zipcodes = [r[0] for r in reader]

# for each zipcode, find lat and lon
for zipcode in input_zipcodes:
    find_single_zip_loc(zipcode)

# write the results
write_results()