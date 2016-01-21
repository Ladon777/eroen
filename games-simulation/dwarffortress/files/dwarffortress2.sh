#!/bin/sh

gamesdir=/opt/dwarffortress-@@SLOT@@
install="$HOME/.dwarffortress-@@SLOT@@"

do_install() {
	cp -rn "$gamesdir"/data "$install"/
	# DF gets unhappy when this is out of sync
	cp -f "$gamesdir"/data/index "$install"/data/
	cp -rsn "$gamesdir"/* "$install"/
}

if [[ -d "$install" ]]; then
	# delete dangling symlinks
	find -L "$install/" -type l -delete
	# ignore "are the same file" errors
	do_install 2>/dev/null
else
	mkdir "$install" || exit
	do_install || exit
fi

cd "$install" || exit
exec ./libs/Dwarf_Fortress "$@"
