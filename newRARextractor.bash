#!/bin/bash
# unrar new files from a watched directory

# directory variables
extract_from_directory="./"	# must have trailing slash: "/path/to/extract_from_directory/"
extract_to_directory="./"	# must NOT have trailing slash: "/path/to/extract_to_directory"
ignore_directory=""

# optionally store these variables in a separate file
# move to working directory
cd $(dirname "${BASH_SOURCE[0]}")
if [ -f "credentials_local.bash" ]; then
  source "credentials_local.bash"
fi

# requires unrar
if ! $(command -v unrar >/dev/null 2>&1); then
  echo "Error: unrar not installed. Aborting."
  exit 1
fi

# validate folders exist
if [[ ! -d "$extract_from_directory" ]] || [[ ! -d "$extract_to_directory" ]]; then
  echo "Error: invalid extract_from_directory or extract_to_directory. Check source code. Aborting."
  exit 1
fi

# if ignore directory is not empty, then filter
if [ -n "$ignore_directory" ]; then
  ignore_directory="-path $ignore_directory -prune -o"
fi

# search for all rar files
news="tempnews.log"
find $extract_from_directory $ignore_directory -iname \*.rar -print > $news

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
    unrar e -o- $file $extract_to_directory
    #echo "$file"
  fi
done

# make sure tempfile not empty so as to not overwrite
# extract log in event of connection issues, errors, etc.
if [ -s $news ]; then
  mv $news $extracted
fi
