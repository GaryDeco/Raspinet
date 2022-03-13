#!/usr/bin/env python

'''
Author: Gary Decosmo
Description: Enable GPIO5 (pin3) to listen for button state to wake/sleep raspberry pi

'''

import RPi.GPIO as GPIO
import subprocess


GPIO.setmode(GPIO.BCM)
GPIO.setup(3, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.wait_for_edge(3, GPIO.RISING)

subprocess.call(['shutdown', '-h', 'now'], shell=False)