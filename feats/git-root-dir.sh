# Features: Move to the root directory of a git repository

export SMARTCD_GIT_ROOT_OPT=${SMARTCD_GIT_ROOT_OPT-"."} # option for traversing to root of the git repo

__smartcd::git_root_dir() {
	local git_root_dir && git_root_dir=$( git rev-parse --show-toplevel )

	if [[ -z ${git_root_dir} ]]; then
		return 1
	elif [[ ${git_root_dir} != "${PWD}" ]]; then 
		builtin cd "${git_root_dir}" && generate_recent_dir_log && \
			if [[ -z ${piped_value} ]]; then printf '%s\n' "${PWD}"; fi
	fi
}
