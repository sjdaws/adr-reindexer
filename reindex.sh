#!/usr/bin/env bash

cd "$GITHUB_WORKSPACE" || exit 2

# Get adr directory
adrdir=$("/adr-tools/_adr_dir")

# Abort if this isn't a valid adr directory
if [ ! -d "$adrdir" ]; then
	echo "ADR directory is invalid or not found, has it been initialised correctly using 'adr init'?"
	exit 1
fi

# Remove traliing slash if it exists, this will break the regex further down
adrdir=${adrdir%/}

# Get the next id based on what is currently in target branch
maxid=$(git ls-tree --name-only $INPUT_TARGETBRANCH $adrdir/ | sed -e "s/^$adrdir\///" | grep -Eo '^[0-9]+' | sed -e 's/^0*//' | sort -rn | head -1)
nextid=$(($maxid + 1))

# Get files added in the current branch
added=$(git diff --cached --name-only --diff-filter=A --relative=$adrdir $INPUT_TARGETBRANCH | sort -n)

echo ""

if [ -z "$added" ]; then
	echo "Nothing to do, exiting"
	exit 0
fi

echo -e "Checking numbers on:\n$added"

reindexed=0
for file in $added; do
	# Only action on files with a number prefix
	currentid=$(echo $file | grep -Eo '^[0-9]+' | sed -e 's/^0*//')
	if [ -z "$currentid" ]; then
		continue
	fi

	# If the id matches, carry on
	if [ "$currentid" -eq "$nextid" ]; then
		nextid=$(($nextid + 1))
		continue
	fi

	prefix=$(printf "%04d" $nextid)
	suffix=$(echo $file | sed -e 's/^[0-9]*//')
	
	echo "Renumbering $file to $prefix$suffix"
	mv $adrdir/$file $adrdir/$prefix$suffix
	
	nextid=$(($nextid + 1))
	reindexed=$(($reindexed + 1))
done

# Update TOC
/adr-tools/adr generate toc | sed "s/Architecture Decision Records/$INPUT_TOCTITLE/" > $adrdir/index.md

echo "::set-output name=reindexed::$reindexed"

echo "Done!"
exit 0