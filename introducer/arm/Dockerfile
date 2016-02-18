FROM resin/rpi-raspbian:jessie 

RUN apt-get update &&\
	apt-get install -y --force-yes --no-install-recommends \
		python-twisted tahoe-lafs &&\
	apt-get autoclean &&\
    	apt-get autoremove &&\
	rm -rf /var/lib/apt/lists/*
	
RUN	mkdir -p /data /etc/tahoe /var/tmp/tahoe /var/log/tahoe && \
	tahoe create-introducer -C /etc/tahoe && \
	cp /etc/tahoe/tahoe.cfg /tmp &&\
	cat /tmp/tahoe.cfg | sed -e 's/^nickname =.*/nickname = introducer/g ' |\
		sed -e 's/^web.port =.*/web.port = tcp:3456/g ' |\
		sed -e 's/^#tub.port =.*/tub.port = tcp:44190/g ' |\
		sed -e 's/^#tub.location =.*/tub.location = introducer:44190/g ' > /etc/tahoe/tahoe.cfg &&\
	echo "tempdir = /var/tmp/tahoe" >> /etc/tahoe/tahoe.cfg &&\
	tahoe --version

EXPOSE 3456 44190
	
WORKDIR /data

CMD tahoe start /etc/tahoe/ -l /var/log/tahoe/introducer.log -n
