#!/usr/bin/env python

import time
import locale

def formatted(fmt):
    locale.setlocale(locale.LC_ALL, '')
    print "Format='" + fmt + "'"
    print "Time=" + time.strftime(fmt, time.gmtime())
    print ""

formatted("%a %b %e, %R:%S")
formatted("%a %e %b, %R:%S")
formatted("%a %R:%S")
formatted("%a %e %b, %l:%M:%S %p")
