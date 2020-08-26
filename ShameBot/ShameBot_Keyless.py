# -*- coding: utf-8 -*-

import sys
from twython import Twython
import random
import datetime
from dateutil import tz
import pytz
import json
import os
import iso8601
import urllib2
import math

# Twitter api strings.
apiKey = 'API_KEY'
apiSecret = 'API_SECRET'
accessToken = 'ACCESS_TOKEN'
accessTokenSecret = 'ACCESS_TOKEN_SECRET'
api = Twython(apiKey,apiSecret,accessToken,accessTokenSecret)

# Hardcode desired timezone:
to_zone = tz.gettz('America/Chicago')

# Get the date.
today = datetime.date.today()
yesterday = today - datetime.timedelta(days=1)

midnight = datetime.datetime.strptime(str(today) + ' 05:00:00', '%Y-%m-%d %H:%M:%S')
midnight = pytz.utc.localize(midnight)

# Get time json.
export = os.popen('/usr/bin/timew from ' + str(yesterday) + ' for 1day export').read()
parsed = json.loads(export)

# If json is empty.
if not parsed:
    tweetStr = 'yesterday Juan did nothing :('
    api.update_status(status=tweetStr)
    sys.exit(0)

# Get total time spent yesterday working.
totalcount = 0
for entry in parsed:
    startx = iso8601.parse_date(entry['start'])

    try:
        endx = iso8601.parse_date(entry['end'])
        if endx > midnight:
            difference = midnight - startx
        else:
            difference = endx - startx

        seconds = int(difference.total_seconds())
        totalcount += seconds
    except KeyError:
        print("one task was not finished...")

    # Find tag that will be displayed in pie chart key.
    tags = entry['tags']

    if tags[0] == 'SLEEP' or tags[0] == 'EAT':
        totalcount -= seconds

# It is possible for json not to be empty, but have a task with not end time.
if not seconds:
    print("could not find seconds")
    sys.exit(0)
else:
    minutes = round(totalcount/60.0, 2)

# If time spent is more than an hour, calculate appropriately.
if minutes > 60.0:
    hours = math.floor(minutes / 60.0)
    minutes -= math.floor(hours * 60);

    if (hours > 1):
        tweetStr = 'total time spent working yesterday is ' + str(int(hours)) + ' hours and ' + str(minutes) + ' minutes.'
    else:
        tweetStr = 'total time spent working yesterday is ' + str(int(hours)) + ' hour and ' + str(minutes) + ' minutes.'


else:
    tweetStr = 'total time spent working yesterday is: ' + str(minutes) + ' minutes.'

# For uploading an image.
# We first try a path from home directory incase it is being run from cron,
# othewise we try a path from the project directory in case it is being run from terminal.
try:
    image_open = open('/home/pi/ShameBot/TaskVisualization/visualization.png')
except IOError:
    print("Could not find visualization.png")
response = api.upload_media(media=image_open)

print(tweetStr)
api.update_status(status=tweetStr, media_ids=[response['media_id']])
