# Feature: Base directory search & traversal.

source "${SMARTCD_ROOT}"/tools/other-utilities.sh

# Array containing Multiple paths for base directory search & traversal
[[ -z ${SMARTCD_BASE_PATHS} ]] && export SMARTCD_BASE_PATHS=( "${HOME}" ) 

# Needs to be configured twice; once before calling __smartcd__() & another within __smartcd__()
export SMARTCD_BASE_DIR=${SMARTCD_BASE_PATHS[*]:0:1} # by default always set to the 1st element of $SMARTCD_BASE_PATHS

# Option name
export SMARTCD_BASE_DIR_OPT=${SMARTCD_BASE_DIR_OPT-"-b --base"} # option for searching & traversing w.r.t. a base directory

__smartcd::select_base() {
	local fzf_header && fzf_header="Smartcd: Select a base path"
	local selected_entry \
		&& selected_entry=$( for _path in "${SMARTCD_BASE_PATHS[@]}"; do printf '%s\n' "${_path}"; done | __smartcd::run_fzf )

	if [[ -z ${selected_entry} ]]; then
		printf '%s\n' "No directory selected!" 1>&2
		return 1 
	elif [[ ! -d ${selected_entry} ]]; then
		printf '%s\n' "Invalid directory path!" 1>&2
		return 1
	else
		export SMARTCD_BASE_DIR="${selected_entry}"
		export smartcd_manual_base_selected='1'
		printf '%s\n' "SmartCd: Base path: ${SMARTCD_BASE_DIR}"
	fi
}

__smartcd::base_parent_cd() {
	if [[ -z ${SMARTCD_BASE_PATHS[*]} ]]; then
		printf '%s\n' "ERROR: SMARTCD_BASE_PATHS env seems to be empty!" 1>&2
		printf '%s\n' "INFO: SMARTCD_BASE_PATHS env is an array which requires at least one valid path for base directory search & traversal." 1>&2
		return 1
	fi

	# Needs to be configured twice; once before calling __smartcd__() & another within __smartcd__()
	# by default always set to the 1st element of $SMARTCD_BASE_PATHS
	[[ ${smartcd_manual_base_selected} -ne 1 ]] && export SMARTCD_BASE_DIR=${SMARTCD_BASE_PATHS[*]:0:1} 

	local path_argument=$*
	local fzf_header && fzf_header="SmartCd: [${SMARTCD_BASE_DIR}]'s sub-directories"
	local selected_entry && selected_entry=$( eval "${find_base_dir_cmd_args}" | __smartcd::run_fzf "${path_argument}" )
	__smartcd::validate_selected_entry
}
