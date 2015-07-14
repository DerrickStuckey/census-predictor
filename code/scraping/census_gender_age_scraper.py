## Pulls population data by zip code from US census API

import codecs
import requests
from urlparse import urljoin
from contextlib import closing
import csv

output_csv_filename = "../../prepared_data/pop_race_zip_derrick.csv"
# output_csv_filename = "./pop_zip_derrick.csv"

api_endpoint = "http://api.census.gov/data/2010/sf1"

base_get_clause = "?get="
for_clause = "&for=zip+code+tabulation+area:*"
base_in_clause = "&in=state:"

# race_vars = {'Total':'P0030001',
#              'White':'P0030002',
#              'Black':'P0030003',
#              'American_Indian_and_Alaskan_Native':'P0030004',
#              'Asian':'P0030005',
#              'Native_Hawaiian_Other_Pacific':'P0030006',
#              'Other':'P0030007',
#              'Multiple':'P0030008'}

query_vars = {'P0010001':'Population',
              'P0030001':'Total_Race_Count',
              'P0030002':'White',
              'P0030003':'Black',
              'P0030004':'American_Indian_and_Alaskan_Native',
              'P0030005':'Asian',
              'P0030006':'Native_Hawaiian_Other_Pacific',
              'P0030007':'Other',
              'P0030008':'Multiple'}

# 'P0120001':'Total_Sex_Count',
# 'P0120002':'Male_Population'

#obviously, states are indexed from 1 to 56, with a few values (3,7,14,43,52) missing
state_range = range(1,60)
state_list = ['%02d' % n for n in state_range]

print state_list

def construct_query(state):
    get_clause = base_get_clause + ','.join([k for k in query_vars.keys()])
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
def write_results(csv_filename, results, header=None):
    with open(csv_filename, 'a') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        if(header):
            writer.writerow(header)
        for row in results[1:]:
            writer.writerow(row)

#truncate the output csv file before beginning
with open(output_csv_filename, 'wb') as csv_file:
    pass

#test:
print construct_query('02')

#write results for the first state
results = run_state_query(construct_query(state_list[0]))
header = results[0]
print header

def map_varname(varname):
    if varname in query_vars.keys():
        return query_vars[varname]
    else:
        return varname

newheader = [map_varname(x) for x in header]
print newheader

write_results(output_csv_filename, results, header=newheader)

#write results for all other states
for state in state_list[1:]:
    # for some reason, state '03' query failing
    try:
        query = construct_query(state)
        results = run_state_query(query)
        write_results(output_csv_filename, results)
    except:
        print "unable to obtain results for state ", state

