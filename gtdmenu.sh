#!/bin/sh


GTD_DATA_PATH=${GTD_DATA_PATH:-/home/marcus/wd/scratch/data/}
GTD_EDITOR=${GTD_EDITOR:-gvim}
GTD_MAXNUMLINES=${GTD_MAXNUMLINES:-10}	# Maximum lines displayed by dmenu

# MAYBE: On no tags perhaps er'thing should be listed?
# TODO: Factor projects_menu and tags_menu.

gtd_tags() {
	find $GTD_DATA_PATH -name "*" -type f -exec sed -n 's/\([A-Za-z0-9 ]*\)|| \(.*\)/\2/p' {} \; | sed 's/ /\n/g' | sort | uniq   
}

gtd_projects() {
	find $GTD_DATA_PATH -name "*" -type f | sort
}

projects_menu() {
	projects=`gtd_projects`				# List projects.
	numlines=`echo "$projects" | wc -l` # numlines required for dmenu.

	if (( numlines > GTD_MAXNUMLINES ))	# Cap numlines at $NUMLINES.
	then
		numlines=$GTD_MAXNUMLINES
	fi

	echo "$projects" |
		if file=`dmenu -l $numlines ${1+"$@"}`
		then									# dmenu returned success!
												# Extract filename and go edit.
		so=`echo $file | sed 's|\(A-Za-z0-9/]*\):.*|\1|'`
		vimstring="$GTD_DATA_PATH`basename $so`"
		
		$GTD_EDITOR $vimstring
	fi
}


tags_menu() {
	tag=`gtd_tags | dmenu ${1+"$@"}`		    # Send all available tags to
												# dmenu.
	if [ -z "$tag" ]							# tag empty string?
	then exit									#      Ok, there are no tags,
	fi											#	   exit.


	items=`grep -n $tag /home/marcus/wd/scratch/data/*`	# Find matching items.
	numlines=`echo "$items" | wc -l`					# numlines for dmenu.

	if (( numlines > GTD_MAXNUMLINES )) # Cap numlines at $NUMLINES. 
	then
		numlines=$GTD_MAXNUMLINES
	fi

	echo "$items" | 
		if file=`dmenu -l $numlines ${1+"$@"}`
		then									# dmenu returned success!
												# Extract the filename and line.
			so=`echo $file | sed 's|\([A-Za-z0-9/]*\):\([0-9]*\):.*|\1 +\2|'`
	
			read f n <<< "$so"
		
			# Kludge for removing trailing newline if no linenumber was
			# available for $so. 
			vimstring="$GTD_DATA_PATH`basename $f` $n" 
			vimstring=`echo $vimstring | sed 's/[ ]*$//'`

			$GTD_EDITOR $vimstring 
	fi
}

case "$1" in
	-p	) projects_menu;;
	*	) tags_menu;;
esac



