#!/usr/bin/env bash

# ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗ ██████╗██████╗ 
# ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
# ███████╗██╔████╔██║███████║██████╔╝   ██║   ██║     ██║  ██║
# ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║     ██║  ██║
# ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ╚██████╗██████╔╝
# ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═════╝ Rishi K. (https://github.com/CodesOfRishi)

__smartcd__() {
	# location for smartcd to store log
	export SMARTCD_CONFIG_DIR=${SMARTCD_CONFIG_DIR:-"$HOME/.config/.smartcd"}
	[[ -d ${SMARTCD_CONFIG_DIR} ]] || mkdir -p ${SMARTCD_CONFIG_DIR}

	# no. of unique recently visited directories smartcd to remember
	export SMARTCD_HIST_SIZE=${SMARTCD_HIST_SIZE:-"50"}
	export SMARTCD_VERSION="v1.5.0"

	# options customizations
	export SMARTCD_CLEANUP_OPT=${SMARTCD_CLEANUP_OPT:-"--cleanup"} # option for cleanup of log file
	export SMARTCD_PARENT_DIR_OPT=${SMARTCD_PARENT_DIR_OPT:-".."} # option for searching & traversing to parent-directories
	export SMARTCD_HIST_OPT=${SMARTCD_HIST_OPT:-"--"} # option for searching & traversing to recently visited directories
	export SMARTCD_GIT_ROOT_OPT=${SMARTCD_GIT_ROOT_OPT:-"."} # option for traversing to root of the git repo
	export SMARTCD_VERSION_OPT=${SMARTCD_VERSION_OPT:-"--version"} # option for printing version information

	# log files
	local recent_dir_log="${SMARTCD_CONFIG_DIR}/smartcd_recent_dir.log" # stores last 50 unique visited absolute paths

	# arguments for find or fd/fdfind command
	if [[ ${smartcd_finder} = *fdfind || ${smartcd_finder} = *fd ]]; then
		local find_sub_dir_cmd_args="${smartcd_finder} --hidden --exclude .git/ --type d -I"
		local find_parent_dir_cmd_args="${smartcd_finder} --exclude .git/ --search-path \${_path} -t d --max-depth=1 -H -I"
		local find_parent_dir_root_cmd_args="${smartcd_finder} --exclude .git/ --search-path / -t d --max-depth=1 -H -I"
	else 
		local find_sub_dir_cmd_args="${smartcd_finder} . -type d ! -path '*/\.git/*' | grep -v '\.git$'"
		local find_parent_dir_cmd_args="${smartcd_finder} \${_path} -maxdepth 1 -type d ! -path '*/\.git/*'"
		local find_parent_dir_root_cmd_args="${smartcd_finder} / -maxdepth 1 -type d ! -path '*/\.git/*'"
	fi

	# ---------------------------------------------------------------------------------------------------------------------

	# configure & validate SMARTCD_REC_LISTING_CMD env
	validate_rec_listing_cmd() {
		if [[ $( whereis -b exa | awk '{print $2}' ) = *exa ]]; then
			export SMARTCD_REC_LISTING_CMD=${SMARTCD_REC_LISTING_CMD:-"exa -TaF -I '.git' --icons --group-directories-first --git-ignore --colour=always"}
		elif [[ $( whereis -b tree | awk '{print $2}' ) = *tree ]]; then
			export SMARTCD_REC_LISTING_CMD=${SMARTCD_REC_LISTING_CMD:-"tree -C"}
		else export SMARTCD_REC_LISTING_CMD=${SMARTCD_REC_LISTING_CMD:-""}; fi
	}

	run_fzf_command() {
		local query=$@
		validate_rec_listing_cmd
		if [[ ${SMARTCD_REC_LISTING_CMD} = "" ]]; then
			fzf --exit-0 --query="${query}"
		else
			fzf --exit-0 --query="${query}" --preview "${SMARTCD_REC_LISTING_CMD} {}"
		fi
	}

	# generate logs of recently visited dirs
	generate_recent_dir_log() { 
		[[ -f ${recent_dir_log} ]] || touch ${recent_dir_log}

		local tmp_log=$( mktemp ) # temporary file
		echo ${PWD} > ${tmp_log}
		cat ${recent_dir_log} >> ${tmp_log}
		awk '!seen[$0]++' ${tmp_log} > ${recent_dir_log} # remove duplicates
		rm -f ${tmp_log}
		sed -i $(( ${SMARTCD_HIST_SIZE} + 1 ))',$ d' ${recent_dir_log} # remove lines from line no. 51 to end. (keep only last 50 unique visited paths)
	}

	# feature
	sub_dir_hop() {
		local path_argument=$@
		builtin cd ${path_argument} 2> /dev/null
		if [[ ! $? -eq 0 ]]; then # the directory is not in any of cdpath values
			local selected_entry=($( eval ${find_sub_dir_cmd_args} | run_fzf_command ${path_argument} ))

			if [[ ${selected_entry} = "" ]]; then
				>&2 echo "No directory found or selected!"
			else
				builtin cd ${selected_entry} && generate_recent_dir_log && echo ${PWD}
			fi
		else
			generate_recent_dir_log
		fi
	}

	# feature
	recent_visited_dirs() {
		if [[ ! -s ${recent_dir_log} ]]; then
			>&2 echo "No any visited directory in record !!"
		else
			local query=$@
			local selected_entry=($( cat ${recent_dir_log} | run_fzf_command ${query} ))

			if [[ ${selected_entry} = "" ]]; then
				>&2 echo "No directory found or selected!"
			else
				builtin cd ${selected_entry} && generate_recent_dir_log && echo ${PWD}
			fi
		fi
	}

	# feature
	parent_dir_hop() {
		if [[ $1 = "" ]]; then
			builtin cd .. && generate_recent_dir_log
			return
		fi

		find_parent_dir_paths() {
			_path=${PWD%/*}
			while [[ ${_path} != "" ]]; do
				eval ${find_parent_dir_cmd_args}
				_path=${_path%/*}
			done
			[[ ${PWD} != "/" ]] && eval ${find_parent_dir_root_cmd_args}
		}

		local query=$@
		local selected_entry=($( find_parent_dir_paths | run_fzf_command ${query} ))

		if [[ ${selected_entry} = "" ]]; then
			>&2 echo "No directory found or selected!"
		else
			builtin cd ${selected_entry} && generate_recent_dir_log && echo ${PWD}
		fi
	}

	# feature
	goto_git_repo_root() {
		local git_repo_root_dir=$( git rev-parse --show-toplevel )
		if [[ ${git_repo_root_dir} != "" && ${git_repo_root_dir} != ${PWD} ]]; then 
			builtin cd ${git_repo_root_dir} && generate_recent_dir_log && echo ${PWD}
		fi
	}

	# cleanup
	cleanup_log() {
		local line_no="1"
		local valid_paths=$( mktemp )
		local invalid_paths=$( mktemp )

		while [[ ${line_no} -le ${SMARTCD_HIST_SIZE} ]]; do
			_path=$( sed -n $line_no'p' ${recent_dir_log} )

			if [[ -d ${_path} ]]; then echo ${_path} >> ${valid_paths}
			else echo ${_path} >> ${invalid_paths}; fi
			line_no=$(( ${line_no} + 1 ))
		done
		cp -i ${valid_paths} ${recent_dir_log}
		rm -rf ${valid_paths}

		sed -i '/^$/d' ${invalid_paths} # remove empty/blank lines
		[[ -s ${invalid_paths} ]] && echo "\nThe following directories got deleted from log:" && cat ${invalid_paths}
		rm -rf ${invalid_paths}
	}

	# ---------------------------------------------------------------------------------------------------------------------
	
	if [[ $1 == "${SMARTCD_PARENT_DIR_OPT}" ]]; then
		parent_dir_hop ${@:2}
	elif [[ $1 == "${SMARTCD_HIST_OPT}" ]]; then
		recent_visited_dirs ${@:2}
	elif [[ $1 == "${SMARTCD_GIT_ROOT_OPT}" ]]; then
		goto_git_repo_root
	elif [[ $1 == "${SMARTCD_CLEANUP_OPT}" ]]; then
		cleanup_log
	elif [[ $1 == "${SMARTCD_VERSION_OPT}" ]]; then
		echo "SmartCd by Rishi K. - ${SMARTCD_VERSION}"
		echo "The MIT License (MIT)"
		echo "Copyright (c) 2021 Rishi K."
	else
		sub_dir_hop $@
	fi
}

# validate if both fzf & fd/fdfind & find are available or not
if [[ $( whereis -b fzf | awk '{print $2}' ) = *fzf ]]; then
	if [[ $( whereis -b fdfind | awk '{print $2}' ) = *fdfind ]]; then
		smartcd_finder="fdfind"
	elif [[ $( whereis -b fd | awk '{print $2}' ) = *fd ]]; then
		smartcd_finder="fd"
	elif [[ $( whereis -b find | awk '{print $2}' ) = *find ]]; then
		smartcd_finder="find"
	else
		>&2 echo "Can't use SmartCd: fd/fdfind or find not found !"
	fi

	if [[ smartcd_finder != "" ]]; then
		export SMARTCD_COMMAND=${SMARTCD_COMMAND:-"cd"} # command name to use smartcd
		alias $SMARTCD_COMMAND="__smartcd__"
	fi
else 
	>&2 echo "Can't use SmartCd: fzf not found !"
fi
