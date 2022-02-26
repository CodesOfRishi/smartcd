# Feature: Piping

__smartcd::read_pipe() {
	while read -r _line; do
		printf '%s\n' "${_line}"
	done
}
