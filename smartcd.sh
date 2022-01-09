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

__smartcd::run_fzf() {
	local query=$*
	local select_one
	[[ ${SMARTCD_SELECT_ONE} -eq 1 ]] && select_one="--select-1"

	validate_fzf_preview_cmd
	if [[ -z ${SMARTCD_FZF_PREVIEW_CMD} ]]; then
		fzf ${select_one} --exit-0 --query="${query}"
	else
		fzf ${select_one} --exit-0 --query="${query}" --preview "${SMARTCD_FZF_PREVIEW_CMD} {}"
	fi
}

__smartcd__() {
	# location for smartcd to store log
	export SMARTCD_CONFIG_DIR=${SMARTCD_CONFIG_DIR:-"$HOME/.config/.smartcd"}
	[[ -d ${SMARTCD_CONFIG_DIR} ]] || mkdir -p "${SMARTCD_CONFIG_DIR}"

	# no. of unique recently visited directories smartcd to remember
	export SMARTCD_HIST_SIZE=${SMARTCD_HIST_SIZE:-"50"}
	export SMARTCD_SELECT_ONE=${SMARTCD_SELECT_ONE:-"0"}
	export SMARTCD_BASE_PARENT=${SMARTCD_BASE_PARENT:-"${HOME}"}
	export SMARTCD_VERSION="v3.3.0"

	# options customizations
	export SMARTCD_BASE_PARENT_OPT=${SMARTCD_BASE_PARENT_OPT-"-b --base"} # option for searching & traversing w.r.t. a base directory
	export SMARTCD_LAST_DIR_OPT=${SMARTCD_LAST_DIR_OPT-"-"} # option for moving to $OLDPWD
	export SMARTCD_CLEANUP_OPT=${SMARTCD_CLEANUP_OPT-"-c --clean"} # option for cleanup of log file
	export SMARTCD_PARENT_DIR_OPT=${SMARTCD_PARENT_DIR_OPT-".."} # option for searching & traversing to parent-directories
	export SMARTCD_HIST_OPT=${SMARTCD_HIST_OPT-"--"} # option for searching & traversing to recently visited directories
	export SMARTCD_GIT_ROOT_OPT=${SMARTCD_GIT_ROOT_OPT-"."} # option for traversing to root of the git repo
	export SMARTCD_VERSION_OPT=${SMARTCD_VERSION_OPT-"-v --version"} # option for printing version information

	# log files
	local recent_dir_log="${SMARTCD_CONFIG_DIR}/smartcd_recent_dir.log" # stores last 50 unique visited absolute paths

	# arguments for find or fd/fdfind command
	if [[ ${smartcd_finder} = *fdfind || ${smartcd_finder} = *fd ]]; then
		local find_base_dir_cmd_args="${smartcd_finder} --hidden --exclude .git/ --type d -I --absolute-path --base-directory \${SMARTCD_BASE_PARENT}"
		local find_sub_dir_cmd_args="${smartcd_finder} --hidden --exclude .git/ --type d -I"
		local find_parent_dir_cmd_args="${smartcd_finder} --exclude .git/ --search-path \${_path} -t d --max-depth=1 -H -I"
		local find_parent_dir_root_cmd_args="${smartcd_finder} --exclude .git/ --search-path / -t d --max-depth=1 -H -I"
	else 
		local find_base_dir_cmd_args="${smartcd_finder} \${SMARTCD_BASE_PARENT} -type d ! -path '*/\.git/*' 2>&- | ${smartcd_grep} -v '\.git$'"
		local find_sub_dir_cmd_args="${smartcd_finder} . -type d ! -path '*/\.git/*' 2>&- | ${smartcd_grep} -v '\.git$'"
		local find_parent_dir_cmd_args="${smartcd_finder} \${_path} -maxdepth 1 -type d ! -path '*/\.git/*' 2>&-"
		local find_parent_dir_root_cmd_args="${smartcd_finder} / -maxdepth 1 -type d ! -path '*/\.git/*' 2>&-"
	fi

	# ---------------------------------------------------------------------------------------------------------------------

	# configure & validate SMARTCD_FZF_PREVIEW_CMD env
	validate_fzf_preview_cmd() {
		if [[ $( whereis -b exa | __smartcd::col2 ) = *exa ]]; then
			export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-"exa -TaF -I '.git' --icons --group-directories-first --git-ignore --colour=always"}
		elif [[ $( whereis -b tree | __smartcd::col2 ) = *tree ]]; then
			export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-"tree -I '.git' -C -a"}
		else export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-""}; fi
	}


	# generate logs of recently visited dirs
	generate_recent_dir_log() { 
		[[ -f ${recent_dir_log} ]] || touch "${recent_dir_log}"

		local tmp_log && tmp_log=$( mktemp ) # temporary file
		printf '%s\n' "${PWD}" >| "${tmp_log}"
		cat "${recent_dir_log}" >> "${tmp_log}"
		awk '!seen[$0]++' "${tmp_log}" >| "${recent_dir_log}" # remove duplicates
		rm -f "${tmp_log}"
		sed -i $(( SMARTCD_HIST_SIZE + 1 ))',$ d' "${recent_dir_log}" # remove lines from line no. 51 to end. (keep only last 50 unique visited paths)
	}

	# feature
	sub_dir_hop() {
		local path_argument=$*

		local tmp_file && tmp_file=$( mktemp )
		builtin cd ${path_argument} 2>> "${tmp_file}"
		local exit_status=$?
		local err_msg && err_msg=$( tail -n 1 "${tmp_file}" )
		rm -rf "${tmp_file}"

		if [[ ${exit_status} -ne 0 ]]; then 
			if [[ $( printf '%s\n' "${err_msg}" | tr "[:upper:]" "[:lower:]" ) = *"no such file or directory"* ]]; then
				local selected_entry && selected_entry=$( eval "${find_sub_dir_cmd_args}" | __smartcd::run_fzf "${path_argument}" )
				__smartcd::validate_selected_entry
			else
				printf '%s\n' "${err_msg}" 1>&2
				return 1
			fi
		else
			generate_recent_dir_log
		fi
	}

	# feature
	recent_dir_hop() {
		if [[ ! -s ${recent_dir_log} ]]; then
			printf '%s\n' "No any visited directory in record !!" 1>&2
			return 1
		else
			local query=$*
			local selected_entry && selected_entry=$( < "${recent_dir_log}" __smartcd::run_fzf "${query}" )
			__smartcd::validate_selected_entry
		fi
	}

	# feature
	parent_dir_hop() {
		if [[ -z $1 ]]; then
			builtin cd .. && generate_recent_dir_log
			return
		fi

		find_parent_dir_paths() {
			_path=${PWD%/*}
			while [[ -n ${_path} ]]; do
				eval "${find_parent_dir_cmd_args}"
				_path=${_path%/*}
			done
			[[ ${PWD} != "/" ]] && eval "${find_parent_dir_root_cmd_args}"
		}

		local query=$*
		local selected_entry && selected_entry=$( find_parent_dir_paths | __smartcd::run_fzf "${query}" )
		__smartcd::validate_selected_entry
	}

	# feature
	git_root_dir_hop() {
		local git_root_dir && git_root_dir=$( git rev-parse --show-toplevel )

		if [[ -z ${git_root_dir} ]]; then
			return 1
		elif [[ ${git_root_dir} != "${PWD}" ]]; then 
			builtin cd "${git_root_dir}" && generate_recent_dir_log && \
				if [[ -z ${piped_value} ]]; then printf '%s\n' "${PWD}"; fi
		fi
	}

	# feature
	base_parent_cd() {
		local path_argument=$*
		local selected_entry && selected_entry=$( eval "${find_base_dir_cmd_args}" | __smartcd::run_fzf "${path_argument}" )
		__smartcd::validate_selected_entry
	}

	# feature
	last_dir_hop() {
		builtin cd "${OLDPWD}" && generate_recent_dir_log
	}

	# cleanup
	cleanup_log() {
		local line_no="1"
		local valid_paths && valid_paths=$( mktemp )

		printf '%s\n' "Paths to remove: "
		while [[ ${line_no} -le ${SMARTCD_HIST_SIZE} ]]; do
			_path=$( sed -n ${line_no}'p' "${recent_dir_log}" )

			if [[ -d ${_path} ]]; then printf '%s\n' "${_path}" >> "${valid_paths}"
			elif [[ -n ${_path} ]]; then printf '%s\n' "${_path}"; fi
			line_no=$(( line_no + 1 ))
		done
		printf '\n'
		cp -i "${valid_paths}" "${recent_dir_log}"
		rm -rf "${valid_paths}"
	}

	version_info() {
		printf '%s\n' "SmartCd by Rishi K. - ${SMARTCD_VERSION}"
		printf '%s\n' "The MIT License (MIT)"
		printf '%s\n' "Copyright (c) 2021 Rishi K."
	}

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
			recent_dir_hop "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_PARENT_DIR_OPT}" ]]; then
			parent_dir_hop "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_LAST_DIR_OPT}" ]]; then
			last_dir_hop "${arg2}"
		elif [[ $( printf '%s\n' "${SMARTCD_BASE_PARENT_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_BASE_PARENT_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			base_parent_cd "${arg2}"
		elif [[ ${arg1} = "${SMARTCD_GIT_ROOT_OPT}" ]]; then
			git_root_dir_hop
		elif [[ $( printf '%s\n' "${SMARTCD_CLEANUP_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_CLEANUP_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			[[ -n ${piped_value} ]] && warning_info && return 1
			cleanup_log
		elif [[ $( printf '%s\n' "${SMARTCD_VERSION_OPT}" | __smartcd::col1 ) = "${arg1}" || \
			$( printf '%s\n' "${SMARTCD_VERSION_OPT}" | __smartcd::col2 ) = "${arg1}" ]]; then
			version_info
		else
			parameters=$( printf '%s\n' "${parameters}" | sed "s|^~|${HOME}|" )
			sub_dir_hop "${parameters}"
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
		export SMARTCD_COMMAND=${SMARTCD_COMMAND:-"cd"} # command name to use smartcd
		alias "${SMARTCD_COMMAND}"="__smartcd__"
	fi
else 
	printf '%s\n' "Can't use SmartCd: fzf not found !" 1>&2
fi
