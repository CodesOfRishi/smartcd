# Feature: Print version information.

export SMARTCD_VERSION="v3.3.0"

__smartcd::version_info() {
	printf '%s\n' "SmartCd by Rishi K. - ${SMARTCD_VERSION}"
	printf '%s\n' "The MIT License (MIT)"
	printf '%s\n' "Copyright (c) 2021 Rishi K."
}
