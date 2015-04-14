## Pulls population data by zip code from US census API

import codecs
import requests
from urlparse import urljoin
from contextlib import closing
import csv

output_csv_filename = "../../prepared_data/pop_zip_derrick.csv"
# output_csv_filename = "./pop_zip_derrick.csv"

api_endpoint = "http://api.census.gov/data/2010/sf1"

get_clause = "?get=P0010001"
for_clause = "&for=zip+code+tabulation+area:*"
base_in_clause = "&in=state:"

#obviously, states are indexed from 1 to 56, with a few values (3,7,14,43,52) missing
state_range = range(1,60)
state_list = ['%02d' % n for n in state_range]

print state_list

def construct_query(state):
    query = api_endpoint + get_clause + for_clause + base_in_clause + state
    return query

#testing#
# for state in state_list:
#     print construct_query(state)

# response will be a list of lists, each sub-list is a row in csv format
def run_state_query(query_url):
    with closing(requests.get(query_url, stream=False)) as response:
        # Check that the response was successful
        if response.status_code == 200:
            results = response.json()
            return results
        else:
            raise IOError("Response code ", response.status_code, " returned from query ", query_url)

# appends results to the csv file specified, writing a header only if first=True
def write_results(csv_filename, results, first=False):
    with open(csv_filename, 'a') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        startindex = 0 if first else 1
        for row in results[startindex:]:
            writer.writerow(row)

#truncate the output csv file before beginning
with open(output_csv_filename, 'wb') as csv_file:
    pass

#write results for the first state
results = run_state_query(construct_query(state_list[0]))
write_results(output_csv_filename, results, first=True)

#write results for all other states
for state in state_list[1:]:
    # for some reason, state '03' query failing
    try:
        query = construct_query(state)
        results = run_state_query(query)
        write_results(output_csv_filename, results, first=False)
    except:
        print "unable to obtain results for state ", state

