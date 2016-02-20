To build the Helper, the introducer must already be running as the bootstraping will give the unique FURL for the introducer. To collect the FURL, just type the following command line on your Docker host where the introducer is running :

    docker exec -t -i introducer /bin/cat /etc/tahoe/private/introducer.furl 

The result will look like :

    pb://uyl5lfsh4fl5gxabj7nnyfzcelv3v54r@introducer:44190/6ys34pdkhk2o5dq2hygysi6bjcx2srcd 

Then edit your Helper docker file with this furl in the introducer.furl section (don't forget to escape the /).
