#!/bin/bash

if [ ! -f /etc/tahoe/private/aliases ]
then
	tahoe -d /etc/tahoe/ start
	tahoe -d /etc/tahoe/ create-alias tahoe
	tahoe -d /etc/tahoe/ stop
fi

tahoe start /etc/tahoe/ && tail -f /etc/tahoe/logs/twistd.log 
