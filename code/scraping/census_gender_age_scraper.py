## Pulls population data by zip code from US census API

import codecs
import requests
from urlparse import urljoin
from contextlib import closing
import csv

output_csv_filename = "../../prepared_data/pop_age_gender_zip.csv"
# output_csv_filename = "../../prepared_data/pop_gender_zip.csv"

api_endpoint = "http://api.census.gov/data/2010/sf1"

base_get_clause = "?get="
for_clause = "&for=zip+code+tabulation+area:*"
base_in_clause = "&in=state:"

query_vars = {'P0010001':'Population',
              'P0120001':'Total_Population',
              'P0120002':'Male_Total',
              "P0120003": "Male: !! Under 5 years",
              "P0120004": "Male: !! 5 to 9 years",
              "P0120005": "Male: !! 10 to 14 years",
              "P0120006": "Male: !! 15 to 17 years",
              "P0120007": "Male: !! 18 and 19 years",
              "P0120008": "Male: !! 20 years",
              "P0120009": "Male: !! 21 years",
              "P0120010": "Male: !! 22 to 24 years",
              "P0120011": "Male: !! 25 to 29 years",
              "P0120012": "Male: !! 30 to 34 years",
              "P0120013": "Male: !! 35 to 39 years",
              "P0120014": "Male: !! 40 to 44 years",
              "P0120015": "Male: !! 45 to 49 years",
              "P0120016": "Male: !! 50 to 54 years",
              "P0120017": "Male: !! 55 to 59 years",
              "P0120018": "Male: !! 60 and 61 years",
              "P0120019": "Male: !! 62 to 64 years",
              "P0120020": "Male: !! 65 and 66 years",
              "P0120021": "Male: !! 67 to 69 years",
              "P0120022": "Male: !! 70 to 74 years",
              "P0120023": "Male: !! 75 to 79 years",
              "P0120024": "Male: !! 80 to 84 years",
              "P0120025": "Male: !! 85 years and over",
              "P0120026": "Female: !! 85 years and over",
              "P0120027": "Female: !! Under 5 years",
              "P0120028": "Female: !! 5 to 9 years",
              "P0120029": "Female: !! 10 to 14 years",
              "P0120030": "Female: !! 15 to 17 years",
              "P0120031": "Female: !! 18 and 19 years",
              "P0120032": "Female: !! 20 years",
              "P0120033": "Female: !! 21 years",
              "P0120034": "Female: !! 22 to 24 years",
              "P0120035": "Female: !! 25 to 29 years",
              "P0120036": "Female: !! 30 to 34 years",
              "P0120037": "Female: !! 35 to 39 years",
              "P0120038": "Female: !! 40 to 44 years",
              "P0120039": "Female: !! 45 to 49 years",
              "P0120040": "Female: !! 50 to 54 years",
              "P0120041": "Female: !! 55 to 59 years",
              "P0120042": "Female: !! 60 and 61 years",
              "P0120043": "Female: !! 62 to 64 years",
              "P0120044": "Female: !! 65 and 66 years",
              "P0120045": "Female: !! 67 to 69 years",
              "P0120046": "Female: !! 70 to 74 years",
              "P0120047": "Female: !! 75 to 79 years",
              "P0120048": "Female: !! 80 to 84 years",
              "P0120049": "Female: !! 85 years and over"
              }

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

