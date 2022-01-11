# Feature: Search & traverse parent directories.

__smartcd::parent_dir_hop() {
	if [[ -z $1 ]]; then
		builtin cd .. && generate_recent_dir_log
		return
	fi

	find_parent_dir_paths() {
		_path=${PWD%/*}
		while [[ -n ${_path} ]]; do
			eval "${find_parent_dir_cmd_args}"
			_path=${_path%/*}
		done
		[[ ${PWD} != "/" ]] && eval "${find_parent_dir_root_cmd_args}"
	}

	local query=$*
	local fzf_header && fzf_header="SmartCd: Parent directories"
	local selected_entry && selected_entry=$( find_parent_dir_paths | __smartcd::run_fzf "${query}" )
	__smartcd::validate_selected_entry
}
