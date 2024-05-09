import json
import requests
import os
import calendar
import time
import pprint
import requests

from datetime import datetime
from datetime import timedelta

url = "https://api.cloudflare.com/client/v4"

x_auth_email = os.getenv("CF_LOGPUSH_EMAIL")
x_auth_key = os.getenv("CF_LOGPUSH_API_KEY")

zone_id = os.getenv("CF_LOGPUSH_ZONE_ID")

destination_conf = "s3://<BUCKET_NAME>/logs?region=us-west-1"

logpull_url = url + "/zones/%s/logs/received" % zone_id
logpull_fields_url = url + "/zones/%s/logs/received/fields" % zone_id

start_time = "2022-09-22 08:00:00"
end_time = "2022-09-22 10:00:00"
headers = {
    'X-Auth-Email': x_auth_email,
    'X-Auth-Key': x_auth_key,
    'Content-Type': 'application/json'
}
start_time_empoch = calendar.timegm(time.strptime(start_time, '%Y-%m-%d %H:%M:%S'))
end_time_empoch = calendar.timegm(time.strptime(end_time, '%Y-%m-%d %H:%M:%S'))

start = datetime(2022, 9, 22, 00, 00, 00)
end = datetime(2022, 9, 22, 11, 00, 00)


def get_fields():
    return "CacheCacheStatus,CacheResponseBytes,CacheResponseStatus,CacheTieredFill,ClientASN,ClientCountry,ClientDeviceType,ClientIP,ClientIPClass,ClientRequestBytes,ClientRequestHost,ClientRequestMethod,ClientRequestPath,ClientRequestProtocol,ClientRequestReferer,ClientRequestURI,ClientRequestUserAgent,ClientSSLCipher,ClientSSLProtocol,ClientSrcPort,ClientXRequestedWith,Cookies,EdgeColoCode,EdgeColoID,EdgeEndTimestamp,EdgePathingOp,EdgePathingSrc,EdgePathingStatus,EdgeRateLimitAction,EdgeRateLimitID,EdgeRequestHost,EdgeResponseBytes,EdgeResponseCompressionRatio,EdgeResponseContentType,EdgeResponseStatus,EdgeServerIP,EdgeStartTimestamp,FirewallMatchesActions,FirewallMatchesRuleIDs,FirewallMatchesSources,OriginIP,OriginResponseBytes,OriginResponseHTTPExpires,OriginResponseHTTPLastModified,OriginResponseStatus,OriginResponseTime,OriginSSLProtocol,ParentRayID,RayID,RequestHeaders,ResponseHeaders,SecurityLevel,WAFAction,WAFFlags,WAFMatchedVar,WAFProfile,WAFRuleID,WAFRuleMessage,WorkerCPUTime,WorkerStatus,WorkerSubrequest,WorkerSubrequestCount,ZoneID"


with open("auth_logs.txt", "w") as f:
    while start < end:
        start_increment_interval = start
        end_increment_interval = start + timedelta(minutes=59)
        params = {
            'fields': get_fields(),
            'sample': "0.1",
            'start': calendar.timegm(start_increment_interval.timetuple()),
            'end': calendar.timegm(end_increment_interval.timetuple())
        }
        print(
            f"Getting logs between {start_increment_interval}[{params['start']}] => {end_increment_interval}[{params['end']}]")

        r = requests.get(logpull_url, headers=headers, params=params)

        assert r.status_code == 200
        for line in r.iter_lines():

            # filter out keep-alive new lines
            if line:
                decoded_line = line.decode('utf-8')
                try:
                    log_line = json.loads(decoded_line)
                    if log_line['ClientRequestHost'] == "auth.olx.com.pk":
                        f.write(decoded_line)
                        f.write('\n')
                except json.decoder.JSONDecodeError:
                    print(f"Could not parse line {line}\n")
        start += timedelta(hours=1)

#
# # Keep id of the new job
# id = r.json()["result"]["id"]
#
# # Get job
# r = requests.get(logpush_url + "/jobs/%s" % id, headers=headers)
# print(r.status_code, r.text)
# assert r.status_code == 200
#
# # Get all jobs for a zone
# r = requests.get(logpush_url + "/jobs", headers=headers)
# print(r.status_code, r.text)
# assert r.status_code == 200
# assert len(r.json()["result"]) > 0
#
# # Update job
# r = requests.put(logpush_url + "/jobs/%s" % id, headers=headers, data=json.dumps({"enabled":True}))
# print(r.status_code, r.text)
# assert r.status_code == 200
# assert r.json()["result"]["enabled"] == True
#
# # Delete job
# r = requests.delete(logpush_url + "/jobs/%s" % id, headers=headers)
# print(r.status_code, r.text)
# assert r.status_code == 200
