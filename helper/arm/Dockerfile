FROM resin/rpi-raspbian:jessie 

RUN apt-get update &&\
	apt-get install -y --force-yes --no-install-recommends \
		python-twisted tahoe-lafs &&\
	apt-get autoclean &&\
    	apt-get autoremove &&\
	rm -rf /var/lib/apt/lists/*

ADD startup.sh /
	
RUN	mkdir -p /data /etc/tahoe /var/tmp/tahoe /var/log/tahoe && \
	tahoe create-node -C /etc/tahoe && \
	cp /etc/tahoe/tahoe.cfg /tmp &&\
    cat /tmp/tahoe.cfg | sed -e 's/nickname =.*/nickname = helper/g' |\
        sed -e 's/^web.port =.*/web.port = tcp:3456/g ' |\
        sed -e 's/^#tub.port =.*/tub.port = tcp:8097/g ' |\
        sed -e 's/^#tub.location =.*/tub.location = helper:8097/g' |\
        sed -e ':a;N;$!ba;s/\/authorized_keys.*\[client\]/\/authorized_keys\ntempdir = \/var\/tmp\/tahoe\n\n\[client\]/g' |\
        sed -e 's/^introducer.furl =.*/introducer.furl = pb:\/\/uyl5lfsh4fl5gxabj7nnyfzcelv3v54r@introducer:44190\/6ys34pdkhk2o5dq2hygysi6bjcx2srcd/g' |\
        sed -e 's/^#shares.needed =.*/shares.needed = 1/g ' |\
        sed -e 's/^#shares.happy =.*/shares.happy = 2/g ' |\
        sed -e 's/^#shares.total =.*/shares.total = 3/g ' |\
        sed -e ':a;N;$!ba;s/\[storage\].*\[helper\]/\[helper\]/g' |\
        sed -e ':a;N;$!ba;s/\[helper\].*Shall this node run a helper service that clients can use?/\[helper\]/g' |\
        sed -e ':a;N;$!ba;s/\[helper\].*enabled = false.*\[drop_upload\]/\[helper\]\nenabled = true\n\n\[drop_upload\]/g' |\
        sed -e ':a;N;$!ba;s/\[drop_upload\].*//g' > /etc/tahoe/tahoe.cfg &&\
	chmod +x /startup.sh &&\
	tahoe --version
	
EXPOSE 3456 8097
	
WORKDIR /data

CMD /startup.sh
