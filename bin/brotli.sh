#!/bin/sh 

ASSET=https://strat.olx.com.bh/assets/main.mobile.69d8a28bb41b5a36cb4d.js

print() {
echo "------------------------------------------------------------------------------------------------------------------------------"
echo "$1"
echo "------------------------------------------------------------------------------------------------------------------------------"
}
otfile
purge() {
curl -X POST "https://api.cloudflare.com/client/v4/zones/2ee9e950fe7176455878abda9c83818d/purge_cache" \
     -H "Content-Type:application/json" \
     -H "Authorization: Bearer ${TF_VAR_cloudflare_olxmena_prod_api_token}" \
     --fail \
     -s \
	 --data "{\"files\":[\"${ASSET}\"]}"     	
}

request_asset() {
  curl --dump-header - -o /dev/null -H "Accept-Encoding: deflate, gzip" "${ASSET}" | egrep  -e 'content-encoding: \w+'  -A 100 -B 100 --color='always'| grep -E 'HIT|MISS' -A 100 -B 100 --color='always'
}


print "Purge the cache..."
purge
print "Requesting mobile bundle with Brotli..."
request_asset "br"
print "Request again with Brotli"
request_asset "br"
print "Purge the cache..."
purge
print "Requesting mobile bundle with Gzip..."
request_asset "gzip"
print "Requesting again with Gzip..."
request_asset "gzip"
