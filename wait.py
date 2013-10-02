#!/usr/bin/python
import time
import sys

if (len(sys.argv) > 1):
	print sys.argv[1]
	interval = int(sys.argv[1])
else:
	interval = 1
time.sleep(interval)
