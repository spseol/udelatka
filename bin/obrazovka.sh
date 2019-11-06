#!/bin/bash
# File:    obrazovka.sh
# Date:    16.10.2019 08:59
# Author:  Marek Nožka, marek <@t> tlapicka <d.t> net
# Licence: GNU/GPL 
# Task: 
############################################################

xrandr --output HDMI-2 --auto --primary
xrandr --output VGA-1 --auto --right-of HDMI-2
