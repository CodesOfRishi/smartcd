# Feature: Search & traverse recently visited direcetories.
# Feature: Remove invalid paths from the log file.

export SMARTCD_HIST_DIR_OPT=${SMARTCD_HIST_DIR_OPT-"--"} # option for searching & traversing to recently visited directories
export SMARTCD_CLEAN_LOG_OPT=${SMARTCD_CLEAN_LOG_OPT-"-c --clean"} # option for cleanup of log file

# log file
export SMARTCD_HIST_DIR_LOG_SIZE=${SMARTCD_HIST_DIR_LOG_SIZE:-"50"}
SMARTCD_HIST_DIR_LOG="${SMARTCD_CONFIG_DIR}/smartcd_recent_dir.log" # stores last 50 unique visited absolute paths

__smartcd::hist_dir() {
	if [[ ! -s ${SMARTCD_HIST_DIR_LOG} ]]; then
		printf '%s\n' "No any visited directory in record !!" 1>&2
		return 1
	else
		local query=$*
		local fzf_header && fzf_header="SmartCd: Recently visited directories"
		local selected_entry && selected_entry=$( < "${SMARTCD_HIST_DIR_LOG}" __smartcd::run_fzf "${query}" )
		__smartcd::validate_selected_entry
	fi
}

# generate logs of recently visited dirs
generate_recent_dir_log() { 
	[[ -f ${SMARTCD_HIST_DIR_LOG} ]] || touch "${SMARTCD_HIST_DIR_LOG}"

	local tmp_log && tmp_log=$( mktemp ) # temporary file
	printf '%s\n' "${PWD}" >| "${tmp_log}"
	cat "${SMARTCD_HIST_DIR_LOG}" >> "${tmp_log}"
	awk '!seen[$0]++' "${tmp_log}" >| "${SMARTCD_HIST_DIR_LOG}" # remove duplicates
	rm -f "${tmp_log}"
	sed -i $(( SMARTCD_HIST_DIR_LOG_SIZE + 1 ))',$ d' "${SMARTCD_HIST_DIR_LOG}" # remove lines from line no. 51 to end. (keep only last 50 unique visited paths)
}

__smartcd::clean_log() {
	local line_no="1"
	local valid_paths && valid_paths=$( mktemp )

	local colr_red && colr_red=$( tput setaf 9 )
	local colr_reset && colr_reset=$( tput sgr0 )
	printf '%s\n' "Path(s) to remove from log: "
	while [[ ${line_no} -le ${SMARTCD_HIST_DIR_LOG_SIZE} ]]; do
		_path=$( sed -n ${line_no}'p' "${SMARTCD_HIST_DIR_LOG}" )

		if [[ -n ${_path} ]]; then 
			local _cd_error=$( builtin cd "${_path}" 2>&1 1> /dev/null )
			if [[ -z ${_cd_error} ]]; then
				printf '%s\n' "${_path}" >> "${valid_paths}"
			else
				if [[ ${smartcd_current_shell} = "zsh" ]]; then
					_cd_error=${_cd_error##*::}
					_cd_error=${_cd_error#* }
					_cd_error=${_cd_error%:*}
					printf '%s\n' "${_path} ${colr_red}${_cd_error}${colr_reset}"
				else 
					_cd_error=${_cd_error##*:}
					printf '%s\n' "${_path} ${colr_red}${_cd_error}${colr_reset}"
				fi
			fi
		fi
		line_no=$(( line_no + 1 ))
	done
	printf '\n'
	cp -i "${valid_paths}" "${SMARTCD_HIST_DIR_LOG}"
	rm -rf "${valid_paths}"
}
