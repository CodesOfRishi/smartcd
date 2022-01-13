# Feature: Search & traverse sub-directories

__smartcd::sub_dir_hop() {
	local path_argument=$*

	# builtin cd errors to ignore for Sub-Dir feature
	ignore_cd_errors=(
		"no such file or directory"
		"too many arguments"
	)

	local tmp_file && tmp_file=$( mktemp )
	builtin cd ${path_argument} 2>> "${tmp_file}"
	local exit_status=$?
	local err_msg && err_msg=$( tail -n 1 "${tmp_file}" )
	rm -rf "${tmp_file}"

	if [[ ${exit_status} -ne 0 ]]; then 
		local curr_err && curr_err=$( printf '%s\n' "${err_msg}" | tr "[:upper:]" "[:lower:]" )

		for _cd_error in "${ignore_cd_errors[@]}"; do
			if [[ ${curr_err} = *"${_cd_error}"* ]]; then
				local fzf_header && fzf_header="SmartCd: Sub-directories"
				local selected_entry && selected_entry=$( eval "${find_sub_dir_cmd}" | __smartcd::run_fzf "${path_argument}" )
				__smartcd::validate_selected_entry
				return $?
			fi
		done

		printf '%s\n' "${err_msg}" 1>&2
		return 1
	else
		generate_recent_dir_log
	fi
}
