FROM debian:jessie 

RUN apt-get update &&\
	apt-get install -y --force-yes --no-install-recommends \
		python-twisted tahoe-lafs &&\
	apt-get autoclean &&\
    	apt-get autoremove &&\
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data /etc/tahoe /var/tmp/tahoe /var/log/tahoe && \
        tahoe create-node -C /etc/tahoe && \
        cp /etc/tahoe/tahoe.cfg /tmp &&\
        cat /tmp/tahoe.cfg | sed -e 's/^web.port =.*/web.port = tcp:3458/g ' |\
        sed -e 's/^#tub.port =.*/tub.port = tcp:8098/g ' |\
        sed -e 's/^#tub.location =.*/tub.location = AUTO/g' |\
        sed -e ':a;N;$!ba;s/\/authorized_keys.*\[client\]/\/authorized_keys\ntempdir = \/var\/tmp\/tahoe\n\n\[client\]/g' |\
        sed -e 's/^introducer.furl =.*/introducer.furl = __PUT_INTRODUCER_FURL_HERE__\/raeapcnibqjlus44h2i5mug5xjnoja6t/g' |\
        sed -e 's/^helper.furl =.*/helper.furl = __PUT_HELPER_FURL_HERE__/g ' |\
                sed -e 's/^#shares.needed =.*/shares.needed = 1/g ' |\
        sed -e 's/^#shares.happy =.*/shares.happy = 2/g ' |\
        sed -e 's/^#shares.total =.*/shares.total = 3/g ' > /etc/tahoe/tahoe.cfg &&\
        tahoe --version
	
ADD tahoe.cfg-post /etc/tahoe/
ADD ssh_host_rsa_key /etc/tahoe/private/ 
ADD ssh_host_rsa_key.pub /etc/tahoe/private/
ADD aliases /etc/tahoe/private/
ADD ftp.accounts /etc/tahoe/private/

RUN cat /etc/tahoe/tahoe.cfg-post >> /etc/tahoe/tahoe.cfg

WORKDIR /data

CMD tahoe start /etc/tahoe/ && tail -f /etc/tahoe/logs/twistd.log  
