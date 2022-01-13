# utility
__smartcd::col1() {
	awk '{print $1}'
}

# utility
__smartcd::col2() {
	awk '{print $2}'
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
