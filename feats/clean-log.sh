# Feature: Remove invalid paths from the log file.

__smartcd::cleanup_log() {
	local line_no="1"
	local valid_paths && valid_paths=$( mktemp )

	printf '%s\n' "Paths to remove: "
	while [[ ${line_no} -le ${SMARTCD_HIST_SIZE} ]]; do
		_path=$( sed -n ${line_no}'p' "${recent_dir_log}" )

		if [[ -d ${_path} ]]; then printf '%s\n' "${_path}" >> "${valid_paths}"
		elif [[ -n ${_path} ]]; then printf '%s\n' "${_path}"; fi
		line_no=$(( line_no + 1 ))
	done
	printf '\n'
	cp -i "${valid_paths}" "${recent_dir_log}"
	rm -rf "${valid_paths}"
}
