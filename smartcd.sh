#!/usr/bin/env bash

# ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗ ██████╗██████╗ 
# ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
# ███████╗██╔████╔██║███████║██████╔╝   ██║   ██║     ██║  ██║
# ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║     ██║  ██║
# ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ╚██████╗██████╔╝
# ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═════╝ Rishi K. (https://github.com/CodesOfRishi)

# utility
__smartcd::col1() {
	awk '{print $1}'
}

# utility
__smartcd::col2() {
	awk '{print $2}'
}

# Environment variables
__smartcd::envs() {

	# Root directory of the SmartCd project
	if ps -p $$ | ${smartcd_grep} -i --quiet 'zsh$'; then 
		SMARTCD_ROOT="$( dirname "${(%):-%x}" )"
	elif ps -p $$ | ${smartcd_grep} -i --quiet 'bash$'; then 
		SMARTCD_ROOT="$( dirname "${BASH_SOURCE[0]}" )"; 
	fi
	export SMARTCD_ROOT

	# location for smartcd to store log
	export SMARTCD_CONFIG_DIR=${SMARTCD_CONFIG_DIR:-"${HOME}/.config/.smartcd"}
	[[ -d ${SMARTCD_CONFIG_DIR} ]] || mkdir -p "${SMARTCD_CONFIG_DIR}"

	# array containing Multiple paths for base directory search & traversal
	[[ -z ${SMARTCD_BASE_PATHS} ]] && export SMARTCD_BASE_PATHS=( "${HOME}" ) 

	# Needs to be configured twice; once before calling __smartcd__() & another within __smartcd__()
	export SMARTCD_BASE_DIR=${SMARTCD_BASE_PATHS[*]:0:1} # by default always set to the 1st element of $SMARTCD_BASE_PATHS

	export SMARTCD_COMMAND=${SMARTCD_COMMAND:-"cd"} # command name to use smartcd
	export SMARTCD_HIST_SIZE=${SMARTCD_HIST_SIZE:-"50"}
	export SMARTCD_SELECT_ONE=${SMARTCD_SELECT_ONE:-"0"}
	export SMARTCD_VERSION="v3.3.0"

	# options customizations
	export SMARTCD_BASE_DIR_OPT=${SMARTCD_BASE_DIR_OPT-"-b --base"} # option for searching & traversing w.r.t. a base directory
	export SMARTCD_LAST_DIR_OPT=${SMARTCD_LAST_DIR_OPT-"-"} # option for moving to $OLDPWD
	export SMARTCD_CLEANUP_OPT=${SMARTCD_CLEANUP_OPT-"-c --clean"} # option for cleanup of log file
	export SMARTCD_PARENT_DIR_OPT=${SMARTCD_PARENT_DIR_OPT-".."} # option for searching & traversing to parent-directories
	export SMARTCD_HIST_OPT=${SMARTCD_HIST_OPT-"--"} # option for searching & traversing to recently visited directories
	export SMARTCD_GIT_ROOT_OPT=${SMARTCD_GIT_ROOT_OPT-"."} # option for traversing to root of the git repo
	export SMARTCD_VERSION_OPT=${SMARTCD_VERSION_OPT-"-v --version"} # option for printing version information
}


# validate selected_entry
__smartcd::validate_selected_entry() {
	if [[ -z ${selected_entry} ]]; then
		printf '%s\n' "No directory found or selected!" 1>&2
		return 1
	else
		builtin cd "${selected_entry}" && generate_recent_dir_log && \
			if [[ -z ${piped_value} ]]; then printf '%s\n' "${PWD}"; fi
	fi
}

# configure & validate SMARTCD_FZF_PREVIEW_CMD env
__smartcd::fzf_preview() {
	if [[ $( whereis -b exa | __smartcd::col2 ) = *exa ]]; then
		export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-"exa -TaF -I '.git' --icons --group-directories-first --git-ignore --colour=always"}
	elif [[ $( whereis -b tree | __smartcd::col2 ) = *tree ]]; then
		export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-"tree -I '.git' -C -a"}
	else export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-""}; fi
}

__smartcd::run_fzf() {
	local query=$*
	local select_one
	[[ ${SMARTCD_SELECT_ONE} -eq 1 ]] && select_one="--select-1"

	__smartcd::fzf_preview
	if [[ -z ${SMARTCD_FZF_PREVIEW_CMD} ]]; then
		fzf ${select_one} --header "${fzf_header}" --exit-0 --query="${query}"
	else
		fzf ${select_one} --header "${fzf_header}" --exit-0 --query="${query}" --preview "${SMARTCD_FZF_PREVIEW_CMD} {}"
	fi
}

# Features
# --------

__smartcd::last_dir_hop() {
	builtin cd "${OLDPWD}" && generate_recent_dir_log
}

__smartcd::version_info() {
	printf '%s\n' "SmartCd by Rishi K. - ${SMARTCD_VERSION}"
	printf '%s\n' "The MIT License (MIT)"
	printf '%s\n' "Copyright (c) 2021 Rishi K."
}

__smartcd__() {

	# log files
	local recent_dir_log="${SMARTCD_CONFIG_DIR}/smartcd_recent_dir.log" # stores last 50 unique visited absolute paths

	# arguments for find or fd/fdfind command
	if [[ ${smartcd_finder} = *fdfind || ${smartcd_finder} = *fd ]]; then
		local find_base_dir_cmd_args="${smartcd_finder} --hidden --exclude .git/ --type d -I --absolute-path --base-directory \${SMARTCD_BASE_DIR}"
		local find_sub_dir_cmd_args="${smartcd_finder} --hidden --exclude .git/ --type d -I"
		local find_parent_dir_cmd_args="${smartcd_finder} --exclude .git/ --search-path \${_path} -t d --max-depth=1 -H -I"
		local find_parent_dir_root_cmd_args="${smartcd_finder} --exclude .git/ --search-path / -t d --max-depth=1 -H -I"
	else 
		local find_base_dir_cmd_args="${smartcd_finder} \${SMARTCD_BASE_DIR} -type d ! -path '*/\.git/*' 2>&- | ${smartcd_grep} -v '\.git$'"
		local find_sub_dir_cmd_args="${smartcd_finder} . -type d ! -path '*/\.git/*' 2>&- | ${smartcd_grep} -v '\.git$'"
		local find_parent_dir_cmd_args="${smartcd_finder} \${_path} -maxdepth 1 -type d ! -path '*/\.git/*' 2>&-"
		local find_parent_dir_root_cmd_args="${smartcd_finder} / -maxdepth 1 -type d ! -path '*/\.git/*' 2>&-"
	fi

	# ---------------------------------------------------------------------------------------------------------------------

	warning_info() {
		printf '%s\n' "WARNING: Do not try to clean the log file while piping, as it can clean it without the user's consent!" 1>&2
		printf '%s\n' "If you want to clean the log file, then run '${SMARTCD_COMMAND} ${SMARTCD_CLEANUP_OPT}'" 1>&2
	}

	# ---------------------------------------------------------------------------------------------------------------------

	validate_parameters() {
		local parameters=$*
		parameters=$( printf '%s\n' "${parameters}" | awk '{$1=$1;print}' )

		local arg1 && arg1=$( printf '%s\n' "${parameters}" | __smartcd::col1 )
		local arg2 && arg2=$( printf '%s\n' "${parameters}" | awk '{$1=""; print $0}' | awk '{$1=$1;print}' )

		if [[ ${arg1} = "${SMARTCD_HIST_OPT}" ]]; then
			__smartcd::recent_dir_hop "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_PARENT_DIR_OPT}" ]]; then
			__smartcd::parent_dir_hop "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_LAST_DIR_OPT}" ]]; then
			__smartcd::last_dir_hop "${arg2}"
		elif [[ $( printf '%s\n' "${SMARTCD_BASE_DIR_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_BASE_DIR_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			__smartcd::base_parent_cd "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_GIT_ROOT_OPT}" ]]; then
			__smartcd::git_root_dir_hop
		elif [[ $( printf '%s\n' "${SMARTCD_CLEANUP_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_CLEANUP_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			[[ -n ${piped_value} ]] && warning_info && return 1
			__smartcd::cleanup_log
		elif [[ $( printf '%s\n' "${SMARTCD_VERSION_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_VERSION_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			__smartcd::version_info
		else
			parameters=$( printf '%s\n' "${parameters}" | sed "s|^~|${HOME}|" )
			__smartcd::sub_dir_hop "${parameters}"
		fi
	}

	read_pipe() {
		while read -r _line; do
			printf '%s\n' "${_line}"
		done
	}

	# ---------------------------------------------------------------------------------------------------------------------

	if [[ ! -t 0 ]]; then
		local piped_value && piped_value=$( read_pipe | fzf --select-1 --exit-0 )
		if [[ -z ${piped_value} ]]; then
			printf '%s\n' "Nothing piped to smartcd!"
			return 1
		fi
	fi

	validate_parameters "$@" "${piped_value}"
}

# validate if both fzf & fd/fdfind & find are available or not
if [[ $( whereis -b fzf | __smartcd::col2 ) = *fzf ]]; then
	# validate fd/fdfind & find
	if [[ $( whereis -b fdfind | __smartcd::col2 ) = *fdfind ]]; then
		smartcd_finder="fdfind"
	elif [[ $( whereis -b fd | __smartcd::col2 ) = *fd ]]; then
		smartcd_finder="fd"
	elif [[ $( whereis -b find | __smartcd::col2 ) = *find ]]; then
		smartcd_finder="find"
	else
		printf '%s\n' "Can't use SmartCd: fd/fdfind or find not found !" 1>&2
	fi

	# validate rg and grep
	if [[ $( whereis -b rg | __smartcd::col2 ) = *rg ]]; then
		smartcd_grep="rg"
	elif [[ $( whereis -b grep | __smartcd::col2 ) = *grep ]]; then
		smartcd_grep="grep"
	else
		printf '%s\n' "Can't use SmartCd: rg or grep not found !" 1>&2
	fi

	if [[ -n ${smartcd_finder} && -n ${smartcd_grep} ]]; then
		__smartcd::envs
		source "${SMARTCD_ROOT}"/feats/base-dir.sh
		source "${SMARTCD_ROOT}"/feats/hist-dir.sh
		source "${SMARTCD_ROOT}"/feats/git-root-dir.sh
		source "${SMARTCD_ROOT}"/feats/sub-dir.sh
		source "${SMARTCD_ROOT}"/feats/parent-dir.sh
		source "${SMARTCD_ROOT}"/feats/clean-log.sh

		alias "${SMARTCD_COMMAND}"="__smartcd__"

		# source key bindings for __smartcd::select_base function
		if ps -p $$ | ${smartcd_grep} -i --quiet 'zsh$'; then source "${SMARTCD_ROOT}"/key-bindings/base-key-binding.zsh
		elif ps -p $$ | ${smartcd_grep} -i --quiet 'bash$'; then source "${SMARTCD_ROOT}"/key-bindings/base-key-binding.bash; fi
	fi
else 
	printf '%s\n' "Can't use SmartCd: fzf not found !" 1>&2
fi
