#!/bin/sh

PUBLIC=../Public
DIR=$1
FILE=$DIR.xhtml
FILEPATH=$PUBLIC/$DIR/$FILE
HEADER=${DIR}_header.txt
FOOTER=${DIR}_footer.txt
CDIR=`pwd`

cd $PUBLIC/$DIR

cat $CDIR/$HEADER > $FILE

for i in *.$DIR; do
	echo "<p><a href='$i'>$i</a></p>" >> $FILE
	if [ "$DIR" == "mp3" ]; then
		LEN=`afinfo -r "$i" | grep duration | cut -d ' ' -f 3 | cut -d '.' -f 1`
		ENCODED="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$i")"
		echo "file: $i"
		echo "encoded: $ENCODED"
		echo "<object type=\"application/x-shockwave-flash\" data=\"http://flv-mp3.com/i/pic/ump3player_500x70.swf\" height=\"30\" width=\"200\"><param name=\"wmode\" 
		value=\"transparent\" /><param name=\"allowFullScreen\" value=\"true\" /><param name=\"allowScriptAccess\" value=\"always\" />
		<param name=\"movie\" value=\"http://flv-mp3.com/i/pic/ump3player_500x70.swf\" /><param name=\"FlashVars\"
		value=\"way=${ENCODED}&amp;swf=http://flv-mp3.com/i/pic/ump3player_500x70.swf&amp;w=300&amp;h=45&amp;time_seconds=${LEN}&amp;autoplay=0&amp;q=&amp;skin=grey&amp;volume=90&amp;comment=\" />
		</object>" >> $FILE
	fi;
done

cat $CDIR/$FOOTER >> $FILE