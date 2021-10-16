# rpi-nts-server
A tutorial on configuring a Raspberry Pi Based Stratum 1 (GPS fed) NTS Server using chrony

This server is intended to be located near a window, powered by PoE, feeding a Stratum 2 NTS server (public facing) located in a server room.
Self-signed certificates can be used to authenticate the local connection between these two servers, but you will want a properly signed cert for the public facing server.
This tutorial will focus on the Stratum 1 server.  

# Hardware
1 x 4 GB Raspberry Pi 4B  
1 x Raspberry Pi 4 power supply  
1 x Raspberry Pi 4 case  
1 x Adafruit Ultimate GPS HAT for Raspberry Pi A+/B+/Pi 2/3/Pi 4 - Mini Kit  
1 x Active GPS antenna  
1 x PoE+ HAT  
1 x PoE+ Switch or injector  

## Notes
The external GPS antenna may not be required if signal is good enough on the antenna built into the HAT

# Software
## Raspbian
A recent version of raspbian should be installed and set up on an SD card. Here is a nice tutorial from Raspberry Pi:  
https://projects.raspberrypi.org/en/projects/raspberry-pi-getting-started  

Another distro, such as Ubuntu could be used as well, but this tutorial will focus on raspbian.
## gpsd
Follow this tutorial from Adafruit to configure your GPS HAT:  
https://learn.adafruit.com/adafruit-ultimate-gps-hat-for-raspberry-pi/

Deviations from tutorial:  

## chrony
chrony 4.0 or later should be installed (4.0 added NTS support). Recent versions of raspbian or other distros should include this.  

Make these changes to /etc/chrony/chrony.conf :  

```
function test() {
  console.log("notice the blank line before this function?");
}
```

## Self-Signed Certificate
Generate the cert using these commands:  

Move the cert to  

Change the permissions so chrony can read the cert  

Copy the cert to your client device (or Stratum 2 server)

Change config of client to accept the cert and use NTS for the connection  

# Security Hardening
Since you are obviously security minded, it is also a good idea to secure your server in other ways. A big fancy lock on your front door does little good if your back window is open :)  

Here are some tuts on securing a raspberry pi:

# Testing
Testing can be done using pulse-per-second (PPS) generators on the server and a client device. We used another RPi 4 as a client and output this PPS signal to a GPIO pin. The client should also have chrony 4.0+ installed and be configured to sync with your server using NTS. If using self-signed certs, you will have to copy this cert to the client and configure it to trust the cert. 

Download PPS script from pigpio site:  
http://abyz.me.uk/rpi/pigpio/examples.html  
http://abyz.me.uk/rpi/pigpio/code/pps_c.zip

Using an oscilloscope, you can measure the phase difference between these PPS signals. This is a measure of the sub-second accuracy of synchronization achieved.
# References
https://chrony.tuxfamily.org/faq.html  
https://chrony.tuxfamily.org/doc/4.0/chrony.conf.html
