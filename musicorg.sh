#!/bin/bash
# Moves all music files from current dir to a specific dir with Artist/(year - )Album hierarchy
# Also a tool for adding new albums to my backlog

musicdir="/media/Lokal_disk/musikk"

find $1 -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.flac" | {
	while read i; do
		perf=`mediainfo --Inform="General;%Album/Performer%" "$i"`
			
		#for comps, I use the album artist tag
		if [ ! "$perf" ];then
			perf=`mediainfo --Inform="General;%Performer%" "$i"`
		fi
		alb=`mediainfo --Inform="General;%Album%" "$i"`
		recorded=`mediainfo --Inform="General;%Recorded_Date%" "$i"`
		year=`echo "$recorded" | awk -F\- '{print $1}' | sed 's/[^0-9]*//g' | awk 'length >= 4' `
		
		if [ "$year" ];then
			year="$year - "
		else
			year=""
		fi
		dir="$musicdir"/"$perf"/"$year$alb"
		mkdir -p "$dir"   
		mv "$(dirname -- "$i")"/* "$dir"		
		
		echo "$perf - $alb" >> ~/musicbacklog.txt
		echo $1
	done
}
find . -type d -empty -delete
sort ~/musicbacklog.txt | uniq > ~/musicbacklognew.txt
mv ~/musicbacklognew.txt ~/musicbacklog.txt

if [ $? -ne 0 ];then
	echo Something went wrong
else
	echo Success! Files organized and moved to $musicdir. Musicbacklog.txt updated.
fi
