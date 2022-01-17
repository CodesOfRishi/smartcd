# Feature: Print version information.

SMARTCD_VERSION="$( git --git-dir="${SMARTCD_ROOT}"/.git describe --tags --match "r*.[[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]]" )" \
	&& export SMARTCD_VERSION
export SMARTCD_VERSION_OPT=${SMARTCD_VERSION_OPT-"-v --version"} # option for printing version information

__smartcd::version_info() {
	printf '%s\n' "SmartCd by Rishi K. - ${SMARTCD_VERSION%%-*}"
	printf '%s\n' "The MIT License (MIT)"
	printf '%s\n' "Copyright (c) 2021 Rishi K."
}

__smartcd::warning_info() {
	printf '%s\n' "WARNING: Do not try to clean the log file while piping, as it can clean it without the user's consent!" 1>&2
	printf '%s\n' "To clean the log file run either '${SMARTCD_COMMAND} $( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col_n 1 )' or '${SMARTCD_COMMAND} $( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col_n 2 )'".
}
