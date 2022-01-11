# Feature: Search & traverse sub-directories

source "${SMARTCD_ROOT}"/tools/other-utilities.sh

__smartcd::sub_dir_hop() {
	local path_argument=$*

	local tmp_file && tmp_file=$( mktemp )
	builtin cd ${path_argument} 2>> "${tmp_file}"
	local exit_status=$?
	local err_msg && err_msg=$( tail -n 1 "${tmp_file}" )
	rm -rf "${tmp_file}"

	if [[ ${exit_status} -ne 0 ]]; then 
		if [[ $( printf '%s\n' "${err_msg}" | tr "[:upper:]" "[:lower:]" ) = *"no such file or directory"* ]]; then
			local fzf_header && fzf_header="SmartCd: Sub-directories"
			local selected_entry && selected_entry=$( eval "${find_sub_dir_cmd_args}" | __smartcd::run_fzf "${path_argument}" )
			__smartcd::validate_selected_entry
		else
			printf '%s\n' "${err_msg}" 1>&2
			return 1
		fi
	else
		generate_recent_dir_log
	fi
}
