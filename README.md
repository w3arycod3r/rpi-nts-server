# rpi-nts-server
A tutorial on configuring a Raspberry Pi Based Stratum 1 (GPS fed) NTS Server using chrony

This server is intended to be located near a window, powered by PoE, feeding a Stratum 2 NTS server (public facing) located in a server room.
Self-signed certificates can be used to authenticate the local connection between these two servers, but you will want a properly signed cert for the public facing server.
This tutorial will focus on the Stratum 1 server, and show how to connect one client device as an example. We used another Raspberry Pi for simplicity. This client device could be replaced with your Stratum 2 server.  

# Server Hardware
1 x 4 GB Raspberry Pi 4B  
1 x Raspberry Pi 4 power supply  
1 x Raspberry Pi 4 case  
1 x Adafruit Ultimate GPS HAT for Raspberry Pi A+/B+/Pi 2/3/Pi 4 - Mini Kit  
1 x Active GPS antenna  
1 x PoE+ HAT  
1 x PoE+ Switch or injector  

## Notes
The external GPS antenna may not be required if signal is good enough on the antenna built into the HAT

# Example Client Hardware
1 x 4 GB Raspberry Pi 4B  
1 x Raspberry Pi 4 power supply  

# Software
## Raspberry Pi OS
A recent version of Raspberry Pi OS should be installed and set up on an SD card. Here is a nice tutorial from Raspberry Pi:  
https://projects.raspberrypi.org/en/projects/raspberry-pi-getting-started  
Repeat this for a separate SD card to be used with the client Pi.

Another distro, such as Ubuntu could be used as well, but this tutorial will focus on Raspberry Pi OS.
## gpsd
Follow this tutorial from Adafruit to configure your GPS HAT:  
https://learn.adafruit.com/adafruit-ultimate-gps-hat-for-raspberry-pi/

Essentially, gpsd will communicate with the GPS module over the serial link, interpret the NMEA sentences along with the PPS signal, and provide location and time information to other programs that request it.

We will need to pipe this data into chrony so that we can use it to serve accurate, precise time to clients.

Deviations from tutorial:  

## Install chrony
chrony 4.0 or later should be installed (4.0 added NTS support). Recent versions of Raspberry Pi OS or other distros should include this in the default repos.

Raspberry Pi OS includes NTPD by default. Installing chrony replaces this. Install chrony with:
```
sudo apt-get install chrony
```
Check the version with:
```
chronyc -v
```

Repeat these steps for the client Pi as well.

# Configure chrony (Server)
Make these changes to /etc/chrony/chrony.conf :  

```
function test() {
  console.log("notice the blank line before this function?");
}
```

Example config file for the server: [chrony_server.conf](chrony_server.conf)

## Self-Signed Certificate
You will first need to install GnuTLS in order to use the certtool command. Install using:
```
sudo apt-get install gnutls-bin
```
This is a great resource on GnuTLS:
https://help.ubuntu.com/community/GnuTLS

The script [gen_certs.sh](gen_certs.sh) in the repo (also shown below) can be used to generate self-signed certificates suitable for NTS authentication with chrony.
```
#!/bin/bash
# Generate self-signed certificates for use with NTS and chrony

set -e

server_name=nts-server.local
cert=/etc/ssl/chrony_certs/nts.crt
key=/etc/ssl/chrony_certs/nts.key

rm -f $cert $key

cat > cert.cfg <<EOF
cn = "$server_name"
serial = 001
activation_date = "2020-01-01 00:00:00 UTC"
expiration_date = "2030-01-01 00:00:00 UTC"
signing_key
encryption_key
EOF

certtool --generate-privkey --key-type=ed25519 --outfile $key
certtool --generate-self-signed --load-privkey $key --template cert.cfg --outfile $cert
chmod 640 $cert $key
chown root:_chrony $cert $key

systemctl restart chronyd

sleep 3

chronyc -N authdata
```

Change the "server_name" to match the hostname you have set on your Raspberry Pi. This is important, as the name on the certificate must match your hostname. We used the ".local" suffix to allow for local discovery without using IP addresses.

https://en.wikipedia.org/wiki/.local

You may change where the certs are located, if desired. These locations are in the "cert" and "key" variables.
This script does:
1. Sets up a few variables for the hostname and location of private key and public certificate.
2. Removes the key and cert if they already exist.
3. Creates a certificate "template" with some important info filled in.
4. Invokes certtool to generate a private key using ed25519 algorithm.
5. Invokes certtool again to generate a public certificate using that private key.
6. Changes the permissions of the cert and key so that the owner can R/W, the group can R, and the world cannot access at all.
7. Change the owner to root and the group to _chrony. This is the group that chrony runs under.

 NOTE: On some systems this group may be different. Verify the group chrony runs under with:
 ```
 ps -aux | grep chrony
 ```
 
8. Restart the chrony service.
9. Pause 3 seconds. (wait for chrony to come back up)
10. Run the authdata command on chrony to see some NTS info.

You can download this script or copy and paste it into a file, naming it gen_certs.sh
In the directory where the script is stored, run the following commands to add executable permissions and execute the script as root:
```
chmod +x gen_certs.sh
sudo ./gen_certs.sh
```

# Configure chrony (Client)

At this point you should have the cert and key in the /etc/ssl/chrony_certs folder. Now you need to copy the cert to your client device (or Stratum 2 server). Do that using scp (ssh copy):

```
scp /etc/ssl/chrony_certs/nts.crt pi@nts-client1.local:/etc/ssl/chrony_certs
```

More info on scp command here:
https://linuxize.com/post/how-to-use-scp-command-to-securely-transfer-files/

Now, change config of client chrony to accept the cert and use NTS for the connection.

Example config file for a client: [chrony_client.conf](chrony_client.conf)

# Security Hardening
Since you are obviously security minded, it is also a good idea to secure your server in other ways. A big fancy lock on your front door does little good if your back window is open :)  

Here are some tuts on securing a Raspberry Pi:

# Testing
Once you have the server and client properly communicating via chrony and NTS, you can test the performance of the system. This can be done using pulse-per-second (PPS) generators on both the server and client.

Download "Pulse Per Second generator" from pigpio site:  
http://abyz.me.uk/rpi/pigpio/examples.html  

Extract the code, compile, and run using these commands:
```
sudo apt-get install unzip build-essential
unzip pps_c.zip
cd pps_c
gcc -o pps pps.c -lpigpio
sudo ./pps -g 17
```
The last command will start the PPS generator on GPIO pin 17. See the pinout below for the location.  
![Screenshot 2021-12-03 124353](https://user-images.githubusercontent.com/18043699/144656098-41f1dfdf-a67f-4261-a90b-1225f2cb8060.png)

Repeat these steps for both the server and client.

Using an oscilloscope, you can measure the phase difference between these PPS signals. This is a measure of the sub-second accuracy of synchronization achieved.
# References
https://chrony.tuxfamily.org/faq.html  
https://chrony.tuxfamily.org/doc/4.0/chrony.conf.html
