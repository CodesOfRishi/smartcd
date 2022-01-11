# Feature: Search & traverse recently visited direcetories.

source "${SMARTCD_ROOT}"/tools/other-utilities.sh

export SMARTCD_HIST_SIZE=${SMARTCD_HIST_SIZE:-"50"}
export SMARTCD_HIST_OPT=${SMARTCD_HIST_OPT-"--"} # option for searching & traversing to recently visited directories

# log file
SMARTCD_RECENT_DIR_LOG="${SMARTCD_CONFIG_DIR}/smartcd_recent_dir.log" # stores last 50 unique visited absolute paths

__smartcd::recent_dir_hop() {
	if [[ ! -s ${SMARTCD_RECENT_DIR_LOG} ]]; then
		printf '%s\n' "No any visited directory in record !!" 1>&2
		return 1
	else
		local query=$*
		local fzf_header && fzf_header="SmartCd: Recently visited directories"
		local selected_entry && selected_entry=$( < "${SMARTCD_RECENT_DIR_LOG}" __smartcd::run_fzf "${query}" )
		__smartcd::validate_selected_entry
	fi
}

# generate logs of recently visited dirs
generate_recent_dir_log() { 
	[[ -f ${SMARTCD_RECENT_DIR_LOG} ]] || touch "${SMARTCD_RECENT_DIR_LOG}"

	local tmp_log && tmp_log=$( mktemp ) # temporary file
	printf '%s\n' "${PWD}" >| "${tmp_log}"
	cat "${SMARTCD_RECENT_DIR_LOG}" >> "${tmp_log}"
	awk '!seen[$0]++' "${tmp_log}" >| "${SMARTCD_RECENT_DIR_LOG}" # remove duplicates
	rm -f "${tmp_log}"
	sed -i $(( SMARTCD_HIST_SIZE + 1 ))',$ d' "${SMARTCD_RECENT_DIR_LOG}" # remove lines from line no. 51 to end. (keep only last 50 unique visited paths)
}
