#!/bin/bash
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATE=$(date +'%Y%m%d')
wget ../kv1feeds/veolia  --accept=zip -q -P ../kv1feeds/veolia -nd -r http://kv1.openov.nl/veolia/ -l 1

python manager.py -d kv1vtn -f ../kv1feeds/veolia
status=$?
rm -rf /tmp/*.txt
if [ $status != 0 ];
then exit 1
fi
psql -d kv1vtn -f ../sql/gtfs-shapes-veolia.sql
psql -d kv1vtn -f ../sql/gtfs-shapes-passtimes.sql
zip -j ../gtfs/veolia/gtfs-kv1veolia-$DATE.zip /tmp/agency.txt /tmp/calendar_dates.txt /tmp/feed_info.txt /tmp/routes.txt /tmp/stops.txt /tmp/stop_times.txt /tmp/trips.txt /tmp/shapes.txt
rm ../gtfs/veolia/gtfs-kv1veolia-latest.zip
ln -s gtfs-kv1veolia-$DATE.zip ../gtfs/veolia/gtfs-kv1veolia-latest.zip

#Validate using Google TransitFeed
python transitfeed/feedvalidator.py ../gtfs/veolia/gtfs-kv1veolia-$DATE.zip -o ../gtfs/veolia/gtfs-kv1veolia-$DATE.html -l 50000 --error_types_ignore_list=ExpirationDate,FutureService
python transitfeed/kmlwriter.py ../gtfs/veolia/gtfs-kv1veolia-$DATE.zip
zip -j ../gtfs/veolia/gtfs-kv1veolia-$DATE.kmz ../gtfs/veolia/gtfs-kv1veolia-$DATE.kml
rm ../gtfs/veolia/gtfs-kv1veolia-$DATE.kml
