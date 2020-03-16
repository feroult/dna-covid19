import sys
import csv
import datetime

BASE_COLS=4

isheader = True
dates = []
case_type = sys.argv[1]

writer = csv.writer(sys.stdout, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

def format_date(d):
    return datetime.datetime.strptime(d, '%m/%d/%y').strftime('%Y-%m-%d')

for row in csv.reader(iter(sys.stdin.readline, ''), delimiter=',', quotechar='"'):
    base = row[0:BASE_COLS]
    if isheader:
        writer.writerow(base + ["Case Type", "Date", "Cases"])
        dates = [format_date(d) for d in row[BASE_COLS:]]
        isheader = False
    else:
        for i in range(BASE_COLS,len(row)):
            date = dates[i-BASE_COLS]
            count = row[i]
            writer.writerow(base + [case_type, date, count])
            