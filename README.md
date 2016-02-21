# Tahoe distributed filesystem for Raspberry Pi 2
 
## 1. Introduction
Tahoe LAFS is a distributed filesystem relying on peer-to-peer mechanisms. This repository gives all the tools required to run Tahoe on both ARM & X86.

There are 3 main components required to run Tahoe :
* the **introducer** (acting like a rendez-vous for all peers)
* the **helper** (acting like a proxy to optimize bandwidth)
* the **node** (used to store the data)

I also added an SFTP **gateway** to each storage node so the filesystem can be mounted locally. The ultimate goal is to provide a persistence layer shared across multiple Raspebrry to be used for file sharing or for VDI.

## 2. Context
The following set-up is assumed : 
* 1 central node hosting the *introducer* and the *helper*. I will assume this runs on an X86 host.
* N *storage* nodes running on Raspberry Pi (at least 3 storage nodes are required)

It is not possible to simply build the containers since there are some parameters issued by the introducer and helper bootstraps that are required to configure the nodes.

## 3. Bootstrap sequence for the introducer
1/ First, clone this repository :
```
git clone https://github.com/besn0847/arm-tahoe.git
```
2/ Move to the x86 repository for the introducer and build it :
```
cd arm-tahoe/introducer/x86 && docker build -t arm-tahoe-introducer .
```
3/ Start the introducer and bind the ports :
```
docker run -d -p 3456:3456 -p 44190:44190 --name introducer --hostname introducer arm-tahoe-introducer
```
4/ You need to collect the full address of your introducer to be used to build the helper, storage nodes ...
```
 docker exec -t -i introducer cat /etc/tahoe/private/introducer.furl
```
This looks like :
> pb://22ww5y363r5v5vl6jp5642l6dyscw247@introducer:44190/od6o247wfcbeeedk6hfbacl5vshn5bis

Note that the introducer FQDN in this FURL; so you can use an IP address or a hostname. Just make sure this can be resolved on each storage node.

You now have a fully operational introducer and you can point your web browser to its web page : 
> http://your_docker_host:3456

## 4. Bootstrap sequence for the helper
1/ Move to the helper x86 directory and edit the Dockerfile
```
cd ../../helper/x86 && vi Dockerfile
```
2/ Replace the __PUT_INTRODUCER_FURL_HERE__ tag by the introducer FURL collected above (don't forget to escape the / !!!). This should look like :
>  sed -e 's/^introducer.furl =.*/introducer.furl = pb:\/\/22ww5y363r5v5vl6jp5642l6dyscw247@introducer:44190\/od6o247wfcbeeedk6hfbacl5vshn5bis/g' |\

3/ Now you can build the helper
```
docker build -t arm-tahoe-helper .
```
4/ Start the helper 
```
docker run -d -p 3457:3457 -p 8097:8097 --name helper --hostname helper --link introducer arm-tahoe-helper
```
5/ Collect the helper FURL which will be needed for each storage
```
docker exec -t -i helper cat /etc/tahoe/private/helper.furl
```
> pb://xs2xe65gporo4dvwjvvnrcwoc6hg3as3@helper:8097/s54yv7eeobop2x5tuv4eaitswf2de67c

6/ Also collect the alias for the newly created distributed file system
```
docker exec -t -i helper cat /etc/tahoe/private/aliases
```
> tahoe: URI:DIR2:kdkuyuawcdzrbynaieqpep5cca:kbjxcb32opwy77vpj2dyrom3kejnsnymta36bebmymg7oogyfvvq

You now have an operational helper which will consolidate the replication flows between nodes. This is an optional set-up but it will help saving uplink bandwidth in an internet wide cluster.

## 5. Bootstrap sequence for each storage
The following step must be performed on each node. Or it also possible to perform it once and then upload your storage node image to your private registry. Also make sure that introducer and helper hostname cvan be resolved on each Raspberry.

1/ First clone the repository on your Raspberry running HypriotOS
```
git clone https://github.com/besn0847/arm-tahoe.git
```
2/ Move to your storage ARM directory 
```
cd arm-tahoe/storage/arm
```
3/ Edit your Dockerfile and replace the introducer and helper FURL tags by the address. This should look like:
>sed -e 's/^introducer.furl =.*/introducer.furl = pb:\/\/22ww5y363r5v5vl6jp5642l6dyscw247@introducer:44190\/od6o247wfcbeeedk6hfbacl5vshn5bis/g' |\
        sed -e 's/^helper.furl =.*/helper.furl = pb:\/\/xs2xe65gporo4dvwjvvnrcwoc6hg3as3@helper:8097\/s54yv7eeobop2x5tuv4eaitswf2de67c/g ' |\
4/ Create an aliases file with the alias above
```
echo "tahoe: URI:DIR2:kdkuyuawcdzrbynaieqpep5cca:kbjxcb32opwy77vpj2dyrom3kejnsnymta36bebmymg7oogyfvvq" > aliases
```
5/ Create an ftp.accounts file with the URI from the alias (set your own password)
```
echo "tahoe passw0rd URI:DIR2:kdkuyuawcdzrbynaieqpep5cca:kbjxcb32opwy77vpj2dyrom3kejnsnymta36bebmymg7oogyfvvq" > ftp.accounts
```
6/ Build your storage node
```
docker build -t arm-tahoe-storage .
```
7/ You are now ready to run your storage node (note i run it with --net host)
```
docker run -d -p 3458:3458 -p 8022:8022 -p 8098:8098 --net host arm-tahoe-storage
```

**Now just add at least 2 extra nodes**

## 6. Operations
To see all the nodes part of your distributed flesystem, just point your web browser to the helper web port :
> http://<docker_host_ip_running_helper>:3457

You can connect to storage nodes throught SFTP on port 8022 :
```
> sftp -P 8022 tahoe@localhost
  tahoe@localhost's password: **** (passw0rd)
  Connected to localhost.
sftp> ls
sftp> mkdir test
sftp> ls -ltr
drwxrwxrwx    1 tahoe    tahoe           0 Feb 21 15:11 test
sftp> 
```

## 7. References
* [Tahoe LAFS](https://tahoe-lafs.org)
* [Tahoe Docker App](https://github.com/besn0847/tahoe-app)
