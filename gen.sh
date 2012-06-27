#!/bin/sh

PUBLIC=../Public
DIR=$1
FILE=$DIR.xhtml
HEADER=${DIR}_header.txt
FOOTER=${DIR}_footer.txt
CDIR=`pwd`

# mp3 props
PLAYER_WIDTH=300
PLAYER_HEIGHT=45
PLAYER_VOLUME=90
PLAYER_SRC=player.swf

cd $PUBLIC/$DIR

cat $CDIR/$HEADER > $FILE

function hms {
	local s=$1
	local hours=$((s / 3600))
	local seconds=$((s % 3600))
	local minutes=$((s / 60))
	local seconds=$((s % 60))
	local str=""
	if [ "$hours" != "0" ]; then
		if [ ${#hours} == 1 ]; then
			hours=0${hours}
		fi
		str=${str}${hours}:
	fi
	if [ "$minutes" != "0" ]; then
		if [ ${#minutes} == 1 ]; then
			minutes=0${minutes}
		fi
		str=${str}${minutes}:
	fi
	if [ ${#seconds} == 1 ]; then
			seconds=0${seconds}
	fi
	str=${str}${seconds}
	echo $str
}

for i in *.$DIR; do
	SIZE=`du -h "$i" | cut -f 1`
	echo "<p><a href='$i'>$i</a>" >> $FILE
	echo " ($SIZE)" >> $FILE
	if [ "$DIR" == "mp3" ]; then
		LEN=`afinfo -r "$i" | grep duration | cut -d ' ' -f 3 | cut -d '.' -f 1`
		STRLEN=$(hms $LEN)
		echo " <i>${STRLEN}</i>" >> $FILE
		ENCODED="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$i")"
		echo "<br/>
		<object type=\"application/x-shockwave-flash\" data=\"${PLAYER_SRC}\" height=\"${PLAYER_HEIGHT}\" width=\"${PLAYER_WIDTH}\"><param name=\"wmode\" 
		value=\"transparent\" /><param name=\"allowFullScreen\" value=\"true\" /><param name=\"allowScriptAccess\" value=\"always\" />
		<param name=\"movie\" value=\"${PLAYER_SRC}\" /><param name=\"FlashVars\"
		value=\"way=${ENCODED}&amp;swf=${PLAYER_SRC}&amp;w=${PLAYER_WIDTH}&amp;h=${PLAYER_HEIGHT}&amp;time_seconds=${LEN}&amp;autoplay=0&amp;q=&amp;skin=grey&amp;volume=${PLAYER_VOLUME}&amp;comment=\" />
		</object>" >> $FILE
	fi;
	echo "</p>" >> $FILE
done

cat $CDIR/$FOOTER >> $FILE
FILESIZE=$(du -h "$FILE" | cut -f 1)
echo "Generated file $FILE ($FILESIZE)"