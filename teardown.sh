#!/bin/bash
DISK_NAME='pd-helloworld'
DISK_TYPE='pd-balanced'
VM_NAME='vm-withpd-helloworld'
COMPUTE_ZONE='us-west1-a'
COMPUTE_REGION='us-west1'
IMAGE_NAME='ubuntu-1804-bionic-v20210623'
IMAGE_PROJECT='ubuntu-os-cloud'
KEY_NAME='gcp-vm-withpd'
DEVICE_NAME='pdv'
DATA_DIR='test.dat'
SNAPSHOT_NAME='pd-snapshot-helloworld'
STORAGE_LOCATION='us-west1'

#delete the disk
gcloud compute instances delete $VM_NAME --zone=$COMPUTE_ZONE --quiet
gcloud compute disks delete $DISK_NAME --zone=$COMPUTE_ZONE --quiet
gcloud compute snapshots delete $SNAPSHOT_NAME --quiet
