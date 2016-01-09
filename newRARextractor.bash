#!/bin/bash
# unrar new files from a watched directory

# requires unrar
if ! $(command -v unrar >/dev/null 2>&1); then
	echo "Error: unrar not installed. Aborting."
	exit 1
fi

# directory variables
watchFolder=""	# must have trailing slash: "/path/to/watchFolder/"
outDir=""	# must NOT have trailing slash: "/path/to/outDir"
ignore_directory=""

# help: to mount to a samba share or windows network drive:
# 	sudo mount -t cifs //ip.address.or.servername.com/ShareName /mnt/foldername/

# move to working directory
cd $(dirname "${BASH_SOURCE[0]}")

# optionally store these variables in a separate file
if [ -f "credentials_local.bash" ]; then
  source "credentials_local.bash"
fi

# validate folders exist
if [[ ! -d "$watchFolder" ]] || [[ ! -d "$outDir" ]]; then
	echo "Error: invalid watchFolder or outDir. Check source code. Aborting."
	exit 1
fi

# search for all rar files
news="tempnews.log"
find $watchFolder -path $ignore_directory -prune -o -iname \*.rar -print > $news

# iterate through list checking for new items
extracted="extracted.log"
for file in $(cat $news); do
  found=0
  for ex in $(cat $extracted); do
	if [ $file == $ex ]; then
	  found=1
	  break
	fi
  done
  if [ $found = 0 ]; then
    unrar e -o- $file $outDir
    #echo "$file"
  fi
done

# make sure tempfile not empty so as to not overwrite
# extract log in event of connection issues, errors, etc.
if [ -s $news ]; then
	mv $news $extracted
fi

