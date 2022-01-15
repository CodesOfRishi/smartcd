# Feature: Search & traverse parent directories.

export SMARTCD_PARENT_DIR_OPT=${SMARTCD_PARENT_DIR_OPT-".."} # option for searching & traversing to parent-directories

__smartcd::parent_dir() {
	if [[ -z $1 ]]; then
		builtin cd .. && generate_recent_dir_log
		return
	fi

	__smartcd::find_parent_dir() {
		_path=${PWD%/*}
		while [[ -n ${_path} ]]; do
			eval "${find_parent_dir_cmd}"
			_path=${_path%/*}
		done
		[[ ${PWD} != "/" ]] && eval "${find_root_dir_cmd}"
	}

	local query=$*
	local fzf_header && fzf_header="SmartCd: Parent directories"
	local selected_entry && selected_entry=$( __smartcd::find_parent_dir | __smartcd::run_fzf "${query}" )
	__smartcd::validate_selected_entry
}
