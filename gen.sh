#!/bin/sh

TYPE=$1
DIR=$1
FILE_EXTS=""

if [ "$TYPE" == "mp3" ]; then
	DIR=mp3
	FILE_EXTS=mp3
elif [ "$TYPE" == "txt" ]; then
	DIR=txt
	FILE_EXTS=txt
elif [ "$TYPE" == "img" ]; then
	DIR=images
	FILE_EXTS="jpg png gif jpeg"
	THUMBS_DIR="thumbs"
	THUMBS_SIZE=100
fi

PUBLIC=../Public
# debug: ../
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

function listFiles {
	for ext in $FILE_EXTS; do
		local FILE_LIST=`find . -iname "*.$ext"`
		echo ${FILE_LIST}
	done
}

function trim {
    local trimmed=$1
    trimmed=${trimmed%% }
    trimmed=${trimmed## }
    echo $trimmed
}

TARGET_FILES=$(listFiles)
echo "Target: $TYPE, extensions: $FILE_EXTS, files: ${TARGET_FILES}"

for i in ${TARGET_FILES}; do
	# removing "./" from file name
	i=${i:2}
	echo $i
	# common processing
	echo "Processing file $i..."
	SIZE=`du -h "$i" | cut -f 1`
	SIZE=$(trim $SIZE)
	echo "<p><a href='$i'>$i</a>" >> $FILE
	echo " ($SIZE)" >> $FILE

	# mp3 processing
	if [ "$TYPE" == "mp3" ]; then
		# sound info
		LEN=`afinfo -r "$i" | grep duration | cut -d ' ' -f 3 | cut -d '.' -f 1`
		STRLEN=$(hms $LEN)
		echo " <i>${STRLEN}</i>" >> $FILE
		# mp3 tag (using mp3info utility)
		TAGS=`mp3info -p "%a - %t" $i | iconv -f cp1251`
		TR_TAGS=$(trim $TAGS)
		if [ "$TR_TAGS" != "-" ]; then
			echo "<br/><b>$TAGS</b>" >> $FILE
		fi
		# mp3 player
		ENCODED="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$i")"
		echo "<br/>
		<object type=\"application/x-shockwave-flash\" data=\"${PLAYER_SRC}\" height=\"${PLAYER_HEIGHT}\" width=\"${PLAYER_WIDTH}\">
		<param name=\"wmode\" value=\"transparent\" />
		<param name=\"allowFullScreen\" value=\"true\" />
		<param name=\"allowScriptAccess\" value=\"always\" />
		<param name=\"movie\" value=\"${PLAYER_SRC}\" /><param name=\"FlashVars\"
		value=\"way=${ENCODED}&amp;swf=${PLAYER_SRC}&amp;w=${PLAYER_WIDTH}&amp;h=${PLAYER_HEIGHT}&amp;time_seconds=${LEN}&amp;autoplay=0&amp;q=&amp;skin=grey&amp;volume=${PLAYER_VOLUME}&amp;comment=\" />
		</object>" >> $FILE
	fi;

	# images processing
	if [ "$TYPE" == "img" ]; then
		# image info
		IMG_WIDTH=`sips -g pixelWidth $i | grep "pixelWidth:" | cut -d ":" -f 2`
		IMG_WIDTH=$(trim ${IMG_WIDTH})
		IMG_HEIGHT=`sips -g pixelHeight $i | grep "pixelHeight:" | cut -d ":" -f 2`
		IMG_HEIGHT=$(trim ${IMG_HEIGHT})
		IMG_FORMAT=`sips -g format $i | grep "format:" | cut -d ":" -f 2`
		IMG_FORMAT=$(trim ${IMG_FORMAT})
		echo "<br/>(${IMG_FORMAT}, ${IMG_WIDTH}x${IMG_HEIGHT})" >> $FILE
		# image preview
		if [ ! -e ${THUMBS_DIR} ]; then
			mkdir ${THUMBS_DIR}
		fi
		THUMB_FILE=${THUMBS_DIR}/$i
		sips -Z ${THUMBS_SIZE} $i --out ${THUMB_FILE} &> /dev/null
		echo "<br/><a href='$i' target='_blank'><img src='${THUMB_FILE}' /></a>" >> $FILE
	fi
	echo "</p>" >> $FILE
done

cat $CDIR/$FOOTER >> $FILE
FILESIZE=$(du -h "$FILE" | cut -f 1)
FILESIZE=$(trim $FILESIZE)
echo "Generated file $FILE ($FILESIZE)"
