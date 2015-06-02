__author__ = 'dstuckey'


import csv

## write zip_count results to designated filename
def write_results(zip_counts, output_filename):
    with open(output_filename, 'wb') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        writer.writerow(['zip_code','count'])
        for zip_code in zip_counts.keys():
            writer.writerow([zip_code,str(zip_counts[zip_code])])

## read all zip codes from population data
def get_all_zips():
    filename = "../../prepared_data/population_by_zip.csv"
    with open(filename, 'r') as popzipcsv:
        reader = csv.DictReader(popzipcsv, delimiter=",")
        zip_codes = [row['zipCode'] for row in reader]
    return zip_codes
