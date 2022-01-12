# Zsh key binding for __smartcd::select_base() function.

__smartcd::select_base-widget() {
	zle push-line
	BUFFER="__smartcd::select_base"
	zle accept-line
}

zle -N __smartcd::select_base-widget

bindkey "${SMARTCD_BASE_DIR_KEYBIND}" __smartcd::select_base-widget
