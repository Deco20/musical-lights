# Musical Lights

![preview](https://raw.github.com/s3331816/musical-lights/master/imgs/IMG_0039.JPG)
A collaboration project that allows a user to use a MIDI file to play music through a speaker and sync with LEDs.

- [Living demo](http://alvarotrigo.com/fullPage/)

## Introduction

This version also contains testing for resources. 

Configured for the OS, Raspbian.

##Installation

Firstly ensure your Raspberry Pi is up-to-date.	

Run these commands:
`sudo apt-get update
`sudo apt-get upgrade

###GIT (For ease of acquisition of some programs)

Run this command:

`sudo apt-get install git-core

###ALSA

Advanced Linux Sound Architecture. Provides audio and MIDI functionality to the Linux 
system

You may visit the ALSA website for the latest library version: 

http://www.alsa-project.org/main/index.php/Main_Page

Otherwise this version worked fine with the current release:

ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.27.2.tar.bz2

In the install directory, execute these commands:

`tar jxvf alsa-lib-1.0.27.2.tar.bz2
`./configure
`make
`make install

###WiringPi

WiringPi is a GPIO access library written in C for the BCM2835 used in the Raspberry Pi. 

Via GIT:
`git clone git://git.drogon.net/wiringPi
`cd wiringPi
`./build

Other (download one of the snapshots):

https://git.drogon.net/?p=wiringPi;a=summary

Run the following commands:
`tar xfz wiringPi-98bcb20.tar.gz
`cd wiringPi-98bcb20
`./build

###Timidity

Plays MIDI files by converting them into PCM waveform data, supports output to a hard disk. It can be used as ALSA sequencer client.

Run this command:

`apt-get install timidity

###Lightorgan

Sets which LEDs to turn on and off with the given MIDI file.	

Code here: https://code.google.com/p/pi-lightorgan/source/browse/trunk

(Once everything is installed properly and downloaded, simply type “make” in the lightorgan.c directory.)


##Electronics Setup

Using the following links, connect your Pi up with the amount of LEDs you want to the corresponding GPIO ports.

GPIO header and pins: http://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/
GPIO key for wiringPi pins: https://projects.drogon.net/raspberry-pi/wiringpi/pins/

##Running the program

Run the program with the following command (replacing <midi path> with the path to your MIDI file:

`sudo nice -n -10 perl play.pl <midi path>
