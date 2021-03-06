# Feature: Print version information.

SMARTCD_VERSION="$( git --git-dir="${SMARTCD_ROOT}"/.git describe --tags --match "r*.[[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]]" 2> /dev/null )" \
	&& export SMARTCD_VERSION
export SMARTCD_VERSION_OPT=${SMARTCD_VERSION_OPT-"-v --version"} # option for printing version information

__smartcd::version_info() {
	local colr87 && colr87='\e[3;38;5;87m'
	local colr_reset && colr_reset='\e[0m'

	[[ -z ${SMARTCD_VERSION} || ${SMARTCD_VERSION} = *"-"* ]] && SMARTCD_VERSION=${SMARTCD_VERSION%%-*}"+beta"
	printf '%b\n' "SmartCd by Rishi K. - ${colr87}${SMARTCD_VERSION}${colr_reset}"
	printf '%s\n' "The MIT License (MIT)"
	printf '%s\n' "Copyright (c) 2021 Rishi K."
}

__smartcd::warning_info() {
	local colr82 && colr82='\e[38;5;82m'
	local colr214 && colr214='\e[38;5;214m'
	local colr_reset && colr_reset='\e[0m'

	printf '%b\n' "${colr214}WARNING:${colr_reset} Do not try to clean the log file while piping, as it can clean it without the user's consent!" 1>&2
	printf '%b\n' "To clean the log file run either '${colr82}${SMARTCD_COMMAND} $( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col_n 1 )${colr_reset}' or '${colr82}${SMARTCD_COMMAND} $( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col_n 2 )${colr_reset}'".
}

__smartcd::base_dir_info() {
	local colr9 && colr9='\e[01;91m'
	local colr34 && colr34='\e[01;34m'
	local colr_reset && colr_reset='\e[0m'

	printf '%b\n' "${colr9}ERROR:${colr_reset} SMARTCD_BASE_PATHS env seems to be empty!" 1>&2
	printf '%b\n' "${colr34}INFO:${colr_reset} SMARTCD_BASE_PATHS env is an array which requires at least one valid path for base directory search & traversal." 1>&2
}
