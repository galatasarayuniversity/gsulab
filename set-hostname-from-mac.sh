#!/bin/bash

PREFIX="dell"
MAC=`sed 's/://g' /sys/class/net/em1/address`
MAC=`echo $MAC | sed 's/\(.*\)/\U\1/'`

hostnamectl set-hostname "${PREFIX}-${MAC}-gsulab"
