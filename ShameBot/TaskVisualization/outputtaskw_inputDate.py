import json
import pytz
import os
import urllib.request
import sys
import datetime
from dateutil import tz
import iso8601

# Get the input.
inputdate = sys.argv[1]

# Get the date that was entered.
export = os.popen('timew export from ' + str(inputdate) + ' for 1day').read()
parsed = json.loads(export)

# Hardcode zones.
to_zone = tz.gettz('America/Chicago')

# Hardcode midnight time.
# midnight_str = str(inputdate) + ' 05:00:00'
# midnight = datetime.datetime.strptime(midnight_str, '%Y-%m-%d %H:%M:%S')
# midnight = pytz.utc.localize(midnight)
# midnight = midnight.astimezone(to_zone)
# midnight = datetime.datetime.strptime(str(inputdate) + ' 05:00:00', '%Y-%m-%d %H:%M:%S')
# midnight = midnight + datetime.timedelta(days=1)
# midnight = pytz.utc.localize(midnight)
midnightyesterday = datetime.datetime.strptime(str(inputdate) + ' 05:00:00', '%Y-%m-%d %H:%M:%S')
midnightyesterday = pytz.utc.localize(midnightyesterday)
midnighttoday = midnightyesterday + datetime.timedelta(days=1)
# midnightyesterday = datetime.datetime.strptime(str(yesterday) + ' 05:00:00', '%Y-%m-%d %H:%M:%S')
# midnightyesterday = pytz.utc.localize(midnightyesterday)
# print(midnight)

# Go through every entry in json file.
for entry in parsed:
    startx = iso8601.parse_date(entry['start'])
    tocentral = startx.astimezone(to_zone)
    minutepercent = tocentral.minute/60.00
    startval = str(tocentral.hour) + '.' + str(minutepercent)[2:]

    # startxcentral = startx.astimezone(to_zone)

    # Add a new entry that contains the start time represented in decimal.
    entry['startx'] = float(startval)

    try:
        endx = iso8601.parse_date(entry['end'])
        # endxcentral = endx.astimezone(to_zone)

        # Make sure it does not cross to the next day.
        if endx > midnighttoday:
            print("endx" + str(endx) + " is greater than" + str(midnighttoday))
            difference = midnighttoday - startx
        elif startx < midnightyesterday:
            difference = endx - midnightyesterday
            entry['startx'] = float(0)
        else:
            difference = endx - startx

        seconds = int(difference.total_seconds())

        # Add a new entry that contains the duration of task represented in seconds.
        entry['seconds'] = seconds

    except KeyError:
        print("failed to get seconds")
        entry['seconds'] = 0

    # Find tag that will be displayed in pie chart key.
    tags = entry['tags']
    index = 0
    if (len(tags) > 1):
        for tag in tags:
            if (tag.isupper()):

                # Add a new entry that will store the category for pie chart key.
                entry['displaytag'] = tag
    if (tags[0] == 'SLEEP'):
          entry['displaytag'] = 'SLEEP'
          entry['tags'] += "s"

    if (tags[0] == 'EAT'):
          entry['displaytag'] = 'EAT'
          entry['tags'] += "s"

with open('timewjson.json', 'w') as file:
    file.write(str(json.dumps(parsed)))

# Get sunrise and sunset json.
url = "https://api.sunrise-sunset.org/json?lat=29.42412&lng=-98.49363&date="+ str(inputdate)
json_url = urllib.request.urlopen(url)
data = json.loads(json_url.read())
results = data['results']
sunrise = str(results['sunrise'])
sunset = str(results['sunset'])

utc = pytz.utc
sunrisetime = datetime.datetime.strptime(sunrise, "%I:%M:%S %p")
sunriselocalize = utc.localize(sunrisetime)
sunrisecentral = sunriselocalize.astimezone(to_zone).time()
sunsettime = datetime.datetime.strptime(sunset, "%I:%M:%S %p")
sunsetlocalize = utc.localize(sunsettime)
sunsetcentral = sunsetlocalize.astimezone(to_zone).time()
print(sunrisecentral)
print(sunsetcentral)

results['sunrise'] = str(sunrisecentral)
results['sunset'] = str(sunsetcentral)

# data = "[" + str(json.loads(json_url.read())) + "]"
data = "[" + str(data) + "]"

print(data)

with open('sundata.json', 'w') as sunfile:
# with open('./sundata.json', 'w') as sunfile:
    sunfile.write(data)

sys.exit(0)

