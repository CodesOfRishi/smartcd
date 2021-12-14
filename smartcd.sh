#!/usr/bin/env bash

# ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗ ██████╗██████╗ 
# ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
# ███████╗██╔████╔██║███████║██████╔╝   ██║   ██║     ██║  ██║
# ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║     ██║  ██║
# ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ╚██████╗██████╔╝
# ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═════╝ Rishi K. (https://github.com/CodesOfRishi)

__smartcd__() {
	# configure SMARTCD_CONFIG_DIR env
	export SMARTCD_CONFIG_DIR=${SMARTCD_CONFIG_DIR:-"$HOME/.config/.smartcd"}
	[[ -d ${SMARTCD_CONFIG_DIR} ]] || mkdir -p ${SMARTCD_CONFIG_DIR}

	# log files
	local recent_dir_log="${SMARTCD_CONFIG_DIR}/smartcd_recent_dir.log" # stores last 50 unique visited absolute paths

	# ---------------------------------------------------------------------------------------------------------------------

	# configure & validate SMARTCD_REC_LISTING_CMD env
	validate_rec_listing_cmd() {
		if [[ $( whereis -b exa | awk '{print $2}' ) = *exa ]]; then
			export SMARTCD_REC_LISTING_CMD=${SMARTCD_REC_LISTING_CMD:-"exa -TaF -I '.git' --icons --group-directories-first --git-ignore --colour=always"}
		elif [[ $( whereis -b tree | awk '{print $2}' ) = *tree ]]; then
			export SMARTCD_REC_LISTING_CMD=${SMARTCD_REC_LISTING_CMD:-"tree -C"}
		else export SMARTCD_REC_LISTING_CMD=${SMARTCD_REC_LISTING_CMD:-""}; fi
	}

	# generate logs of recently visited dirs
	generate_recent_dir_log() { 
		export SMARTCD_HIST_SIZE=${SMARTCD_HIST_SIZE:-"50"}
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
			local selected_entry=""
			validate_rec_listing_cmd
			if [[ ${SMARTCD_REC_LISTING_CMD} == "" ]]; then
				selected_entry=($(fd --hidden --exclude .git/ --type d -i -F | fzf --exit-0 --query="${path_argument}"))
			else
				selected_entry=($(fd --hidden --exclude .git/ --type d -i -F | fzf --exit-0 --query="${path_argument}" --preview "${SMARTCD_REC_LISTING_CMD} {}"))
			fi

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
			local selected_entry=""
			validate_rec_listing_cmd
			if [[ ${SMARTCD_REC_LISTING_CMD} == "" ]]; then
				selected_entry=($(cat ${recent_dir_log} | fzf --exit-0 --query="${query}"))
			else 
				selected_entry=($(cat ${recent_dir_log} | fzf --exit-0 --query="${query}" --preview "${SMARTCD_REC_LISTING_CMD} {}"))
			fi

			if [[ ${selected_entry} = "" ]]; then
				>&2 echo "No directory found or selected!"
			else
				builtin cd ${selected_entry} && generate_recent_dir_log && echo ${PWD}
			fi
		fi
	}

	# feature
	parent_dir_hop() {
		local parent_dir_log=$( mktemp ) # temporary file to store parent directories's absolute paths

		_path=${PWD%/*}
		while [[ ${_path} != "" ]]; do
			fd --exclude .git/ --search-path ${_path} -t d --max-depth=1 -i -H -F >> ${parent_dir_log}
			_path=${_path%/*}
		done

		if [[ ! -s ${parent_dir_log} ]]; then
			>&2 echo "No matching parent-directory found!"
		else
			local query=$@
			local selected_entry=""
			validate_rec_listing_cmd
			if [[ ${SMARTCD_REC_LISTING_CMD} = "" ]]; then
				selected_entry=($(cat ${parent_dir_log} | fzf --exit-0 --query="${query}"))
			else
				selected_entry=($(cat ${parent_dir_log} | fzf --exit-0 --query="${query}" --preview "${SMARTCD_REC_LISTING_CMD} {}"))
			fi

			if [[ ${selected_entry} = "" ]]; then
				>&2 echo "No directory found or selected!"
			else
				builtin cd ${selected_entry} && generate_recent_dir_log && echo ${PWD}
			fi
		fi
		rm -f ${parent_dir_log}
	}

	# feature
	goto_git_repo_root() {
		local git_repo_root_dir=$( git rev-parse --show-toplevel )
		if [[ ${git_repo_root_dir} != "" && ${git_repo_root_dir} != ${PWD} ]]; then 
			builtin cd ${git_repo_root_dir} && generate_recent_dir_log && echo ${PWD}
		fi
	}

	# ---------------------------------------------------------------------------------------------------------------------
	
	if [[ $1 == '..' ]]; then
		parent_dir_hop ${@:2}
	elif [[ $1 == '--' ]]; then
		recent_visited_dirs ${@:2}
	elif [[ $1 == '.' ]]; then
		goto_git_repo_root
	else
		sub_dir_hop $@
	fi
}

# validate if both fzf & fd are available or not
if [[ $( whereis -b fzf | awk '{print $2}' ) = *fzf && $( whereis -b fd | awk '{print $2}' ) = *fd ]]; then
	export SMARTCD_COMMAND=${SMARTCD_COMMAND:-"cd"}
	alias $SMARTCD_COMMAND="__smartcd__"
else
	[[ $( whereis -b fzf | awk '{print $2}' ) != *fzf ]] && >&2 echo "Can't use SmartCd: fzf not found !"
	[[ $( whereis -b fd | awk '{print $2}' ) != *fd ]] && >&2 echo "Can't use SmartCd: fd not found !"
fi
