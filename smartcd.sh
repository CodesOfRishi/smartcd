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

	export SMARTCD_COMMAND=${SMARTCD_COMMAND:-"cd"} # command name to use smartcd
	export SMARTCD_SELECT_ONE=${SMARTCD_SELECT_ONE:-"0"}
}

__smartcd__() {

	source "${SMARTCD_ROOT}"/tools/find-utilities.sh

	# ---------------------------------------------------------------------------------------------------------------------

	validate_parameters() {
		local parameters=$*
		parameters=$( printf '%s\n' "${parameters}" | awk '{$1=$1;print}' )

		local arg1 && arg1=$( printf '%s\n' "${parameters}" | __smartcd::col1 )
		local arg2 && arg2=$( printf '%s\n' "${parameters}" | awk '{$1=""; print $0}' | awk '{$1=$1;print}' )

		if [[ ${arg1} = "${SMARTCD_HIST_OPT}" ]]; then
			__smartcd::hist_dir "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_PARENT_DIR_OPT}" ]]; then
			__smartcd::parent_dir "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_LAST_DIR_OPT}" ]]; then
			__smartcd::last_dir "${arg2}"
		elif [[ $( printf '%s\n' "${SMARTCD_BASE_DIR_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_BASE_DIR_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			__smartcd::base_dir "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_GIT_ROOT_OPT}" ]]; then
			__smartcd::git_root_dir
		elif [[ $( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_CLEAN_LOG_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			[[ -n ${piped_value} ]] && __smartcd::warning_info && return 1
			__smartcd::clean_log
		elif [[ $( printf '%s\n' "${SMARTCD_VERSION_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_VERSION_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			__smartcd::version_info
		else
			parameters=$( printf '%s\n' "${parameters}" | sed "s|^~|${HOME}|" )
			__smartcd::sub_dir_hop "${parameters}"
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
		
		source "${SMARTCD_ROOT}"/tools/fzf-utilities.sh
		source "${SMARTCD_ROOT}"/tools/other-utilities.sh

		# source features
		for _feats in "${SMARTCD_ROOT}"/feats/*.sh; do
			source "${_feats}"
		done

		alias "${SMARTCD_COMMAND}"="__smartcd__"

		# source key bindings for __smartcd::select_base function
		if ps -p $$ | ${smartcd_grep} -i --quiet 'zsh$'; then 
			source "${SMARTCD_ROOT}"/key-bindings/base-key-binding.zsh
		elif ps -p $$ | ${smartcd_grep} -i --quiet 'bash$'; then 
			source "${SMARTCD_ROOT}"/key-bindings/base-key-binding.bash; 
			source "${SMARTCD_ROOT}"/completion/completion.bash
		fi
	fi
else 
	printf '%s\n' "Can't use SmartCd: fzf not found !" 1>&2
fi
