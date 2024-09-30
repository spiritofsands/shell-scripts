#!/bin/bash

# Workaround on long suspend for Starlite Mk V
echo '1-3.2' | sudo tee /sys/bus/usb/drivers/usb/unbind
