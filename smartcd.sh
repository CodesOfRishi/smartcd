#!/usr/bin/env bash

# ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗ ██████╗██████╗ 
# ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
# ███████╗██╔████╔██║███████║██████╔╝   ██║   ██║     ██║  ██║
# ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║     ██║  ██║
# ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ╚██████╗██████╔╝
# ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═════╝ Rishi K. (https://github.com/CodesOfRishi)

# Environment variables
__smartcd::envs() {

	# Root directory of the SmartCd project
	if [[ ${smartcd_current_shell} = "zsh" ]]; then 
		SMARTCD_ROOT="$( dirname "${(%):-%x}" )"
	elif [[ ${smartcd_current_shell} = "bash" ]]; then 
		SMARTCD_ROOT="$( dirname "${BASH_SOURCE[0]}" )"; 
	fi
	export SMARTCD_ROOT

	# location for smartcd to store log
	export SMARTCD_CONFIG_DIR=${SMARTCD_CONFIG_DIR:-"${HOME}/.config/.smartcd"}
	[[ -d ${SMARTCD_CONFIG_DIR} ]] || mkdir -p "${SMARTCD_CONFIG_DIR}"

	export SMARTCD_COMMAND=${SMARTCD_COMMAND:-"cd"} # command name to use smartcd
	export SMARTCD_SELECT_ONE=${SMARTCD_SELECT_ONE:-"0"}
	export SMARTCD_EXACT_SEARCH=${SMARTCD_EXACT_SEARCH:-"0"}
}

__smartcd__() {

	source "${SMARTCD_ROOT}"/tools/find-utilities.sh

	# ---------------------------------------------------------------------------------------------------------------------

	validate_parameters() {
		local parameters=$*
		parameters=$( printf '%s\n' "${parameters}" | awk '{$1=$1;print}' )

		local arg1 && arg1=$( printf '%s\n' "${parameters}" | __smartcd::col_n 1 )
		local arg2 && arg2=$( printf '%s\n' "${parameters}" | awk '{$1=""; print $0}' | awk '{$1=$1;print}' )

		if [[ ${arg1} = "${SMARTCD_HIST_DIR_OPT}" ]]; then
			__smartcd::hist_dir "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_PARENT_DIR_OPT}" ]]; then
			__smartcd::parent_dir "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_LAST_DIR_OPT}" ]]; then
			__smartcd::last_dir "${arg2}"
		elif [[ $( printf '%s\n' "${SMARTCD_BASE_DIR_OPT}" | __smartcd::col_n 1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_BASE_DIR_OPT}" | __smartcd::col_n 2 ) = "${arg1}" ]]; then
			__smartcd::base_dir "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_GIT_ROOT_OPT}" ]]; then
			__smartcd::git_root_dir
		elif [[ $( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col_n 1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col_n 2 ) = "${arg1}" ]]; then
			[[ -n ${piped_value} ]] && __smartcd::warning_info && return 1
			__smartcd::clean_log
		elif [[ $( printf '%s\n' "${SMARTCD_VERSION_OPT}" | __smartcd::col_n 1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_VERSION_OPT}" | __smartcd::col_n 2 ) = "${arg1}" ]]; then
			__smartcd::version_info
		else
			parameters=$( printf '%s\n' "${parameters}" | sed "s|^~|${HOME}|" )
			__smartcd::sub_dir "${parameters}"
		fi
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

__smartcd::exec_exist() {
	local _executable=$1
	if [[ ${smartcd_current_shell} = "zsh" ]]; then
		whence -p "${_executable}" &> /dev/null
	elif [[ ${smartcd_current_shell} = "bash" ]]; then
		type -P "${_executable}" &> /dev/null
	fi
}

# Determine the current shell
# do NOT export smartcd_current_shell (must not be an environment variable)
if ps -p $$ | grep --quiet 'zsh$'; then
	smartcd_current_shell="zsh"
elif ps -p $$ | grep --quiet 'bash$'; then
	smartcd_current_shell="bash"
else 
	printf '%s\n' "Current shell doesn't seems to be either Bash or Zsh" 1>&2
	unset -f __smartcd::envs
	unset -f __smartcd::exec_exist
	unset -f __smartcd__
	return 1
fi

# validate if fzf available or not
if __smartcd::exec_exist fzf; then
	# validate fd/fdfind & find
	if __smartcd::exec_exist fdfind; then
		export SMARTCD_FINDER=${SMARTCD_FIND:-"fdfind"}
	elif __smartcd::exec_exist fd; then
		export SMARTCD_FINDER=${SMARTCD_FINDER:-"fd"}
	elif __smartcd::exec_exist fd; then
		export SMARTCD_FINDER=${SMARTCD_FINDER:-"find"}
	else
		printf '%s\n' "Can't use SmartCd: fd/fdfind or find not found !" 1>&2
	fi

	# validate rg and grep
	if __smartcd::exec_exist rg; then
		export SMARTCD_GREP=${SMARTCD_GREP:-"rg"}
	elif __smartcd::exec_exist grep; then
		export SMARTCD_GREP=${SMARTCD_GREP:-"grep"} 
	else
		printf '%s\n' "Can't use SmartCd: rg or grep not found !" 1>&2
	fi

	if [[ -n ${SMARTCD_FINDER} && -n ${SMARTCD_GREP} ]]; then
		__smartcd::envs
		
		# source fzf & other utilities
		source "${SMARTCD_ROOT}"/tools/fzf-utilities.sh
		source "${SMARTCD_ROOT}"/tools/other-utilities.sh

		# source features
		for _feat in "${SMARTCD_ROOT}"/feats/*.sh; do
			source "${_feat}"
		done
		unset _feat

		alias "${SMARTCD_COMMAND}"="__smartcd__"

		# source key bindings for __smartcd::select_base function
		if [[ ${smartcd_current_shell} = "zsh" ]]; then 
			typeset -f compinit > /dev/null && compdef __smartcd__=cd # completion for zsh
			source "${SMARTCD_ROOT}"/key-bindings/base-key-binding.zsh
		elif [[ ${smartcd_current_shell} = "bash" ]]; then 
			complete -A directory "${SMARTCD_COMMAND}" # completion for bash
			source "${SMARTCD_ROOT}"/key-bindings/base-key-binding.bash; 
		fi
	else
		unset smartcd_current_shell
		unset SMARTCD_FIND
		unset SMARTCD_GREP
		unset -f __smartcd::envs
		unset -f __smartcd::exec_exist
		unset -f __smartcd__
		return 1
	fi
else 
	printf '%s\n' "Can't use SmartCd: fzf not found !" 1>&2
	unset smartcd_current_shell
	unset -f __smartcd::envs
	unset -f __smartcd::exec_exist
	unset -f __smartcd__
	return 1
fi
