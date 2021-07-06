#!/bin/bash
DEVICE_NAME=sdb
MOUNT_DIR=data
sudo fsfreeze -f /mnt/disks/$MOUNT_DIR
sudo umount /mnt/disks/$MOUNT_DIR

