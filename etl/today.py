#!/usr/bin/env python3

import json
import requests
import csv
import sys
import datetime

URL = 'https://services9.arcgis.com/N9p5hsImWXAccRNI/arcgis/rest/services/Nc2JKvYFoAEOFCG5JSI6/FeatureServer/2/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Confirmed%20desc&resultOffset=0&resultRecordCount=190&cacheHint=true'
REFERER = 'https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html'

today = datetime.datetime.utcnow().date().strftime('%Y-%m-%d')

def format_float(s):
    return '{0:.4f}'.format(float(s))

response = requests.get(
    URL,
    headers={'referer': REFERER},
)

json_response = response.json()
countries = json_response['features']

writer = csv.writer(sys.stdout, delimiter=',',
                    quotechar="\"", quoting=csv.QUOTE_MINIMAL)

writer.writerow(['Province/State', 'Country/Region', 'Lat',
              'Long', 'Case Type', 'Date', 'Cases'])

for country in countries:
    a = country['attributes']
    base = ['', a['Country_Region'], format_float(a['Lat']), format_float(a['Long_'])]
    writer.writerow(base + ['Confirmed', today, a['Confirmed']])
    writer.writerow(base + ['Deaths', today, a['Deaths']])
    writer.writerow(base + ['Recovered', today, a['Recovered']])
