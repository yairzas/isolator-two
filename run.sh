#!/bin/bash
Xvfb -screen 0 1024x768x16 -ac &
export DISPLAY=:0
x11vnc -rfbauth /root/.vnc/passwd -display :0 -forever &
/usr/local/sbin/guacd -b 0.0.0.0 -f &
/usr/bin/firefox