#!/bin/sh

cd /vimrc-files
git pull
cd /root/workspace
/squashfs-root/AppRun "$1"
