# Feature: Print version information.

export SMARTCD_VERSION="v4.0.0"
export SMARTCD_VERSION_OPT=${SMARTCD_VERSION_OPT-"-v --version"} # option for printing version information

__smartcd::version_info() {
	printf '%s\n' "SmartCd by Rishi K. - ${SMARTCD_VERSION}"
	printf '%s\n' "The MIT License (MIT)"
	printf '%s\n' "Copyright (c) 2021 Rishi K."
}

__smartcd::warning_info() {
	printf '%s\n' "WARNING: Do not try to clean the log file while piping, as it can clean it without the user's consent!" 1>&2
	printf '%s\n' "If you want to clean the log file, then run '${SMARTCD_COMMAND} ($( printf '%s\n' "${SMARTCD_CLEANUP_OPT}" | __smartcd::col1 ) | $( printf '%s\n' "${SMARTCD_CLEANUP_OPT}" | __smartcd::col2 ))'" 1>&2
}
