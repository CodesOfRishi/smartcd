# Feature: Base directory search & traversal.

# Array containing multiple base paths for Base-Dir feature
[[ -z ${SMARTCD_BASE_PATHS} ]] && export SMARTCD_BASE_PATHS=( "${HOME}" ) 

# Needs to be configured twice; before & after calling of __smartcd__()
export SMARTCD_BASE_DIR=${SMARTCD_BASE_PATHS[*]:0:1} # by default always set to the 1st element of $SMARTCD_BASE_PATHS
export SMARTCD_BASE_DIR_KEYBIND=${SMARTCD_BASE_DIR_KEYBIND-"\\C-k"} # key binding for __smartcd::select_base

# Option for Base-Dir feature
export SMARTCD_BASE_DIR_OPT=${SMARTCD_BASE_DIR_OPT-"-b --base"} 

__smartcd::select_base() {
	[[ -z ${SMARTCD_BASE_PATHS[*]} ]] && __smartcd::base_dir_info && return 1

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

__smartcd::base_dir() {
	[[ -z ${SMARTCD_BASE_PATHS[*]} ]] && __smartcd::base_dir_info && return 1

	# Needs to be configured twice; before & after calling of __smartcd__()
	# by default always set to the 1st element of $SMARTCD_BASE_PATHS array
	[[ ${smartcd_manual_base_selected} -ne 1 ]] && export SMARTCD_BASE_DIR=${SMARTCD_BASE_PATHS[*]:0:1} 

	local path_argument=$*
	local fzf_header && fzf_header="SmartCd: [${SMARTCD_BASE_DIR}]'s sub-directories"
	local selected_entry && selected_entry=$( eval "${find_base_dir_cmd}" | __smartcd::run_fzf "${path_argument}" )
	__smartcd::validate_selected_entry
}
