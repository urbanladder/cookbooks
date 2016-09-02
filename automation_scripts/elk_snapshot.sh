#!/bin/sh
#The snapshot names are snapshot_followed by the particular date of the index
#Fill in the values give below.
set -e

username=''
password=''
elk_host=''
elk_repo=''
s3_bucket=''
s3_region=''
aws_access_key=''
aws_secret_key=''
Host="http://$username:$password/$elk_host"

day=1
repo_status=$(curl -s -o /dev/null -I -w "%{http_code}" -XGET $Host/_snapshot/$elk_repo/_all)

# create repo if not exists
if [ $repo_status != 200 ]; then
  echo "  Creating the repo"
  {
    curl -XPUT "'$Host'/_snapshot/$elk_repo" -d '{
      "type": "s3",
      "settings": {
      "bucket": "'$s3_bucket'",
      "region": "'$s3_region'",
      "access_key": "'$aws_access_key'",
      "secret_key": "'$aws_secret_key'",
      "protocol": "https"
    }
    }'
  }

  # Still not created? Exit!
  repo_status=$(curl -s -o /dev/null -I -w "%{http_code}" -XGET $Host/_snapshot/$elk_repo/_all)
  if [ $repo_status != 200 ]; then
    echo "  failed to create repo."
    exit 1;
  fi
fi

# Check for snapshot
index_date=$(date --date="$day days ago" +%Y.%m.%d)
snapshot_status=$(curl -s -o /dev/null -I -w "%{http_code}" -XGET $Host/_snapshot/$elk_repo/snapshot_$name)
if [ $snapshot_status = 200 ]; then
  echo "  The snapshot for the index logstash-$index_date already exists"
  exit 0
fi

# Create snapshot if not exists
echo "  creating snapshot"
output=$(
  curl -XPUT "$Host/_snapshot/$elk_repo/snapshot_$index_date" -d '{
  "indices": "logstash-'$index_date'",
  "include_global_state": "false",
  "wait_for_completion": "true"
}'
)

if [ "$output" != "{\"accepted\":true}" ]
then
  echo "  not working"
  exit 1
fi

# Wait for completion and exit on timeout
while true
do
  echo "  Waiting for snapshot creation to complete.."
  creation_status=$(curl -s -o /dev/null -I -w "%{http_code}" -XGET $Host/_snapshot/$elk_repo/snapshot_$index_date)
  if [ $creation_status = 200 ]; then
    break
  fi

  let counter=counter+1
  if [ $counter -gt 15 ]; then
    echo "  Failed to create snapshot"
    exit 1
  fi
  sleep 5
done

echo "Snapshot created."
exit 0
