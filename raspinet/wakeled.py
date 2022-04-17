#!/usr/bin python3

import RPi.GPIO as GPIO 
import os, sys, time, subprocess
#from netiface import *
import signal

# Red LED is pin 18
# Blue LED is pin 25
# Green LED is pin 23
# Power switch is pin 3
# Button 2 will be pin 5 (not setup yet)

# A simple call to turn pin HIGH and keep it that way
REDPIN = 18

ON = 1
OFF = 0
iface = "eth0"

##############################################################################################################################


GPIO.setmode(GPIO.BCM)
GPIO.setup(REDPIN,GPIO.OUT)
GPIO.setwarnings(False)

for i in range(0,10):
    GPIO.output(REDPIN,ON)
    time.sleep(0.5)
    GPIO.output(REDPIN,OFF)
    time.sleep(0.5)


while True:
    GPIO.output(REDPIN,ON)
