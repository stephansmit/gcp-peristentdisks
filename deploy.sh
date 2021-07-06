#!/bin/bash
DISK_NAME='pd-helloworld'
DISK_TYPE='pd-ssd'
DISK_SIZE='100GB'
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


#create keys
#rm $PWD/$KEY_NAME $PWD/$KEY_NAME.pub
#
#ssh-keygen -t rsa -f $PWD/$KEY_NAME -C stephansmit
#chmod 400 $PWD/$KEY_NAME

#gcloud compute os-login ssh-keys add --key-file $PWD/$KEY_NAME.pub
rm ~/.ssh/known_hosts
#create the persistent disk
gcloud compute disks create $DISK_NAME --zone=$COMPUTE_ZONE --type=$DISK_TYPE --size=$DISK_SIZE --quiet
#create the compute vm
gcloud compute instances create $VM_NAME --zone=$COMPUTE_ZONE --image=$IMAGE_NAME --image-project=$IMAGE_PROJECT --metadata enable-oslogin=TRUE --quiet
#attach the disks
gcloud compute instances attach-disk $VM_NAME --disk=$DISK_NAME --zone=$COMPUTE_ZONE --device-name=$DEVICE_NAME --quiet
echo "waiting a few secs"
sleep 50s
#mount the disk
HOST=$(gcloud compute instances describe $VM_NAME --zone=$COMPUTE_ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
ssh -o StrictHostKeyChecking=no -i $KEY_NAME stephansmit_hotmail_com@$HOST 'bash -s' < mount_disk.sh

sleep 5s
#copy the data
rsync -Pav -e "ssh -i $KEY_NAME" $DATA_DIR stephansmit_hotmail_com@$HOST:/mnt/disks/data
#unmount the disk
HOST=$(gcloud compute instances describe $VM_NAME --zone=$COMPUTE_ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
ssh -o StrictHostKeyChecking=no -i $KEY_NAME stephansmit_hotmail_com@$HOST 'bash -s' < unmount_disk.sh
#sleep 10s
#create snapshot
gcloud compute disks snapshot $DISK_NAME --snapshot-names=$SNAPSHOT_NAME --storage-location=$STORAGE_LOCATION --zone=$COMPUTE_ZONE --quiet
#detach the disk
gcloud compute instances detach-disk $VM_NAME --disk=$DISK_NAME --zone=$COMPUTE_ZONE --quiet
#delete the disk
gcloud compute instances delete $VM_NAME --zone=$COMPUTE_ZONE --quiet
#delete the instance
gcloud compute disks delete $DISK_NAME --zone=$COMPUTE_ZONE --quiet




rm ~/.ssh/known_hosts
#create disk from snapshot
gcloud compute disks create $DISK_NAME --zone=$COMPUTE_ZONE --type=$DISK_TYPE --size=$DISK_SIZE --source-snapshot $SNAPSHOT_NAME --quiet
#create instance
gcloud compute instances create $VM_NAME --zone=$COMPUTE_ZONE --image=$IMAGE_NAME --image-project=$IMAGE_PROJECT --metadata enable-oslogin=TRUE --quiet
#attach disk
gcloud compute instances attach-disk $VM_NAME --disk=$DISK_NAME --zone=$COMPUTE_ZONE --device-name=$DEVICE_NAME --quiet
#mount disk with snapshot
echo "waiting a few secs"
sleep 30s
HOST=$(gcloud compute instances describe $VM_NAME --zone=$COMPUTE_ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
ssh  -o StrictHostKeyChecking=no -i $KEY_NAME stephansmit_hotmail_com@$HOST 'bash -s' < mount_disk_snapshot.sh

