#!/bin/bash
#
# Print info about xrdp Xvnc sessions
#

RED=$(tput setaf 1; tput bold) #"\033[1;31m"
GREEN=$(tput setaf 2; tput bold) #"\033[1;32m"
YELLOW=$(tput setaf 3; tput bold)
ENDCOLOR=$(tput sgr0) #"\033[0m"
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Format string for printf
_printf="%7s %-20s %-19s %-10s %4s %-12s\n"

# Print header
printf "\n${_printf}" PID USERNAME START_TIME GEOMETRY BITS STATUS

ps h -C Xvnc -o user:20,pid,lstart,cmd | while read _ps; do
	timestring=$(echo ${_ps} | awk '{print $3,$4,$5,$6,$7}');
	start_time=$(date -d "${timestring}" +"%Y-%m-%d %H:%M:%S");
	[ $(date -d "${start_time}" +%s) -lt $(date -d "-30 days" +%s) ] && start_time="${YELLOW}${start_time}${ENDCOLOR}"
	read username pid geometry colorbits <<< $(echo ${_ps} | awk '{user=$1; pid=$2; for(i=8;i<=NF;i++){if($i=="-geometry"){geom=$(++i)} if($i=="-depth"){bits=$(++i)}} print user,pid,geom,bits}');
	ss -tep 2>/dev/null | grep -q pid\=${pid}, && status="${GREEN}active${ENDCOLOR}" || status="${RED}disconnected${ENDCOLOR}";
	printf "${_printf}" ${pid} ${username} "${start_time}" ${geometry} ${colorbits} "${status}";
done
echo ""
