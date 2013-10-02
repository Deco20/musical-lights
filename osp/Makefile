#Makefile for Lightorgan

all: lightorgan.c
		gcc lightorgan.c -lasound -lwiringPi -g -o lightorgan

inst: all
		sudo cp lightorgan /usr/sbin
		sudo chmod 700 /usr/sbin/lightorgan
		sudo chown root /usr/sbin/lightorgan
