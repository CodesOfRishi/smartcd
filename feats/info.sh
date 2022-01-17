# Feature: Print version information.

SMARTCD_VERSION="$( git --git-dir="${SMARTCD_ROOT}"/.git describe --tags --match "r*.[[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]]" )" \
	&& export SMARTCD_VERSION
export SMARTCD_VERSION_OPT=${SMARTCD_VERSION_OPT-"-v --version"} # option for printing version information

__smartcd::version_info() {
	local colr87 && colr87=$( tput setaf 87 )
	local colr_reset && colr_reset=$( tput sgr 0 )

	printf '%s\n' "SmartCd by Rishi K. - ${colr87}${SMARTCD_VERSION%%-*}${colr_reset}"
	printf '%s\n' "The MIT License (MIT)"
	printf '%s\n' "Copyright (c) 2021 Rishi K."
}

__smartcd::warning_info() {
	local colr118 && colr118=$( tput setaf 118 )
	local colr178 && colr178=$( tput setaf 178 )
	local colr_reset && colr_reset=$( tput sgr 0 )

	printf '%s\n' "${colr178}WARNING:${colr_reset} Do not try to clean the log file while piping, as it can clean it without the user's consent!" 1>&2
	printf '%s\n' "To clean the log file run either '${colr118}${SMARTCD_COMMAND} $( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col_n 1 )${colr_reset}' or '${colr118}${SMARTCD_COMMAND} $( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col_n 2 )${colr_reset}'".
}

__smartcd::base_dir_info() {
	printf '%s\n' "ERROR: SMARTCD_BASE_PATHS env seems to be empty!" 1>&2
	printf '%s\n' "INFO: SMARTCD_BASE_PATHS env is an array which requires at least one valid path for base directory search & traversal." 1>&2
}
