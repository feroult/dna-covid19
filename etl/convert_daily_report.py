#!/usr/bin/env python3

import sys
import csv

HEADER = ['Province/State', 'Country/Region', 'Case Type', 'Date', 'Cases']

def fix_date(date):
    p = date.split('-')
    return p[2] + '-' + p[0] + '-' + p[1]

isheader = True
date = fix_date(sys.argv[1])
source = sys.argv[2]
sink = sys.argv[3] 

def parse_indexes(header):
    indexes = {}
    header = list(map(lambda c: c.replace(
        '_', '/').replace('\ufeff', ''), header))
    for col in ['Province/State', 'Country/Region', 'Confirmed', 'Deaths', 'Recovered']:
        indexes[col] = header.index(col)
    return indexes

with open(sink, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile, delimiter=',',
                        quotechar='"', quoting=csv.QUOTE_MINIMAL)

    with open(source, newline='') as csvfile:
        for row in csv.reader(csvfile, delimiter=',', quotechar='"'):
            if isheader:
                indexes = parse_indexes(row)
                writer.writerow(HEADER)
                isheader = False
            else:
                province_state = row[indexes['Province/State']]
                country_region = row[indexes['Country/Region']].replace(
                    'Mainland China', 'China').replace('South Korea', 'Korea, South')
                confirmed = row[indexes['Confirmed']]
                deaths = row[indexes['Deaths']]
                recovered = row[indexes['Recovered']]
                base = [province_state, country_region]
                writer.writerow(base + ["Confirmed", date, confirmed])
                writer.writerow(base + ["Deaths", date, deaths])
                writer.writerow(base + ["Recovered", date, recovered])
