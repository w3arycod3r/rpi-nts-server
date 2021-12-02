#!/bin/bash
# Skew system clock to test chrony synchronization

systemctl stop chrony
sleep 1
date +%T.%N -s "09:11:00.694201946"
sleep 1
systemctl start chrony
