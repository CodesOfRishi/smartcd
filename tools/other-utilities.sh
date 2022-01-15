__smartcd::col_n() {
	local OLD_IFS=${IFS}

	# IFS value contains a space, a tab & a new-line character
	# >  ^I$
	# > $
	IFS=" 	
	"
	local col=$1
	local count=1

	local _line
	read -r _line

	local _opt
	if [[ ${smartcd_current_shell} = "bash" ]]; then
		for _opt in ${_line}; do
			if [[ ${count} -eq "${col}" ]]; then
				printf '%s\n' "${_opt}"
				break
			fi
			count=$(( count + 1))

		done
	elif [[ ${smartcd_current_shell} = "zsh" ]]; then
		for _opt in ${=_line}; do
			if [[ ${count} -eq "${col}" ]]; then
				printf '%s\n' "${_opt}"
				break
			fi
			count=$(( count + 1))

		done
	fi

	IFS=${OLD_IFS}
}

# validate selected_entry
__smartcd::validate_selected_entry() {
	if [[ -z ${selected_entry} ]]; then
		printf '%s\n' "No directory found or selected!" 1>&2
		return 1
	else
		builtin cd "${selected_entry}" && generate_recent_dir_log && \
			if [[ -z ${piped_value} ]]; then printf '%s\n' "${PWD}"; fi
	fi
}
