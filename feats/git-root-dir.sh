# Features: Move to the root directory of a git repository

__smartcd::git_root_dir_hop() {
	local git_root_dir && git_root_dir=$( git rev-parse --show-toplevel )

	if [[ -z ${git_root_dir} ]]; then
		return 1
	elif [[ ${git_root_dir} != "${PWD}" ]]; then 
		builtin cd "${git_root_dir}" && generate_recent_dir_log && \
			if [[ -z ${piped_value} ]]; then printf '%s\n' "${PWD}"; fi
	fi
}
