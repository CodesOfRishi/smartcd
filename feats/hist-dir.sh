# Feature: Search & traverse recently visited direcetories.

export SMARTCD_HIST_SIZE=${SMARTCD_HIST_SIZE:-"50"}
export SMARTCD_HIST_OPT=${SMARTCD_HIST_OPT-"--"} # option for searching & traversing to recently visited directories

# log file
local recent_dir_log="${SMARTCD_CONFIG_DIR}/smartcd_recent_dir.log" # stores last 50 unique visited absolute paths

__smartcd::recent_dir_hop() {
	if [[ ! -s ${recent_dir_log} ]]; then
		printf '%s\n' "No any visited directory in record !!" 1>&2
		return 1
	else
		local query=$*
		local fzf_header && fzf_header="SmartCd: Recently visited directories"
		local selected_entry && selected_entry=$( < "${recent_dir_log}" __smartcd::run_fzf "${query}" )
		__smartcd::validate_selected_entry
	fi
}

# generate logs of recently visited dirs
generate_recent_dir_log() { 
	[[ -f ${recent_dir_log} ]] || touch "${recent_dir_log}"

	local tmp_log && tmp_log=$( mktemp ) # temporary file
	printf '%s\n' "${PWD}" >| "${tmp_log}"
	cat "${recent_dir_log}" >> "${tmp_log}"
	awk '!seen[$0]++' "${tmp_log}" >| "${recent_dir_log}" # remove duplicates
	rm -f "${tmp_log}"
	sed -i $(( SMARTCD_HIST_SIZE + 1 ))',$ d' "${recent_dir_log}" # remove lines from line no. 51 to end. (keep only last 50 unique visited paths)
}
