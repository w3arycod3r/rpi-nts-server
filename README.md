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
1 x Passive GPS antenna  
1 x PoE+ HAT  
1 x PoE+ Switch or injector  

## Notes
The external GPS antenna may not be required if signal is good enough on the antenna built into the HAT

# Software
## Raspbian
A recent version of raspbian should be installed and set up on an SD card. Many tutorials exist for this.  
Another distro, such as Ubuntu could be used as well, but this tutorial will focus on raspbian.
## gpsd
Link to adafruit GPS hat setup tut.

Deviations from tutorial:  

## chrony
chrony 4.0 or later should be installed (4.0 added NTS support). Recent versions of raspbian or other distros should include this.  

Make the following configuration changes:  

# Testing
Testing can be done using pulse-per-second (PPS) generators on the server and a client device. We used another RPi 4 as a client and output this PPS signal to a GPIO pin. The client should also have chrony 4.0+ installed and be configured to sync with your server using NTS. If using self-signed certs, you will have to copy this cert to the client and configure it to trust the cert. 

PPS script from pigpio site:  

Using an oscilloscope, you can measure the phase difference between these PPS signals. This represents the accuracy of synchronization achieved.
# References
