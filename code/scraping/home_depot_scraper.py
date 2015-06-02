__author__ = 'dstuckey'


import requests
from urlparse import urljoin
from contextlib import closing
import csv
from bs4 import BeautifulSoup
from collections import defaultdict

# csv_filename = "../../raw_data/home_depot_locations.csv"
csv_filename = "./home_depot_locations.csv"

locs_url = "http://localad.homedepot.com/HomeDepot/Entry/Locations/"
base_url = "http://localad.homedepot.com/homedepotsd/LocalAd?storeid="

def write_results(zip_counts):
    with open(csv_filename, 'wb') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        writer.writerow(['zip_code','store_count'])
        for zip_code in zip_counts.keys():
            writer.writerow([zip_code,str(zip_counts[zip_code])])

def get_all_storeids():
    with closing(requests.get(locs_url, stream=False)) as response:
        # Check that the response was successful
        if response.status_code == 200:
            base_soup = BeautifulSoup(response.text)
        else:
            raise IOError("Response code ", response.status_code, " returned from query ", locs_url)

    # print(base_soup.prettify())

    store_as = base_soup.findAll(name='a',attrs={'class':"locationsLink action-storelocation-changestore action-tracking-nav"})
    store_links = [store_a['data-tracking-redirectlink'] for store_a in store_as]
    # print store_links[0:5]

    # store_ids = [str(link).split(sep="=")[1] for link in store_links]
    store_ids = []
    for store_link in store_links:
        try:
            store_id = str(store_link).split("storeid=")[1]
            store_ids.append(store_id)
        except:
            continue

    # print store_ids[0:5]
    return store_ids

def get_store_zip_code(storeid):
    req_url = base_url + str(storeid)
    with closing(requests.get(req_url, stream=False)) as response:
        # Check that the response was successful
        if response.status_code == 200:
            store_soup = BeautifulSoup(response.text)
        else:
            raise IOError("Response code ", response.status_code, " returned from query ", req_url)

    zip_idx = store_soup.text.find('storeZip:')
    store_zip = store_soup.text[zip_idx+11:zip_idx+16]
    return store_zip

#testing:
# test_storeids = ['2502050', '2398130', '2489598', '2398131', '2550333']
# store_zips = [get_store_zip_code(storeid) for storeid in test_storeids]
# print store_zips

zip_counts = defaultdict(lambda:0)

storeids = get_all_storeids()

for storeid in storeids:
    try:
        store_zip = get_store_zip_code(storeid)
        print "store id ", storeid, ": zip ", store_zip
        zip_counts[store_zip] += 1
    except:
        print "Unable to obtain zip for store id ", storeid

write_results(zip_counts)