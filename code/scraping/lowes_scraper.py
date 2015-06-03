__author__ = 'dstuckey'


import requests
from urlparse import urljoin
from contextlib import closing
# import csv
from bs4 import BeautifulSoup
from collections import defaultdict

import scraping_utils

## scrape store locations for a single zip code
def scrape_single_zip(target_zip_code):
    max_count = 10
    base_url = "http://www.lowes.com/IntegrationServices/resources/storeLocator/json/v2_0/stores?langId=-1&storeId=10702&catalogId=10051&place="
    req_url = base_url + str(target_zip_code) + "&count=" + str(max_count)
    with closing(requests.get(req_url, stream=False)) as response:
        # Check that the response was successful
        if response.status_code == 200:
            # store_soup = BeautifulSoup(response.text)
            json_response = response.json()
            store_results = json_response['Location']
        else:
            raise IOError("Response code ", response.status_code, " returned from query ", req_url)

    # print(store_results[0])

    zip_codes = [r['ZIP'] for r in store_results]
    # print zip_codes

    matching_zips = [z for z in zip_codes if z==target_zip_code]
    return len(matching_zips)

#testing:
# zip_count = scrape_single_zip('99540')
# print zip_count


zip_counts = {}

all_zips = scraping_utils.get_all_zips()

for target_zip_code in all_zips:
    try:
        target_count = scrape_single_zip(target_zip_code)
        zip_counts[target_zip_code] = target_count
        print "zip code ", target_zip_code, "; count ", target_count
    except:
        print "unable to obtain count for zip code ", target_zip_code
        continue

scraping_utils.write_results(zip_counts,output_filename="./lowes_locations.csv")