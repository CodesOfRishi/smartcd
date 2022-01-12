# Bash key binding for __smartcd::select_base() function.

if [[ $- =~ i ]]; then 
	bind -x '"'"${SMARTCD_BASE_DIR_KEYBIND}"'":"__smartcd::select_base"'
fi
