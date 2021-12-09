#!/usr/bin/env bash

# ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗ ██████╗██████╗ 
# ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
# ███████╗██╔████╔██║███████║██████╔╝   ██║   ██║     ██║  ██║
# ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║     ██║  ██║
# ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ╚██████╗██████╔╝
# ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═════╝ Rishi K. (https://github.com/CodesOfRishi)

__smartcd__() {
	# configure SMARTCD_CONFIG_DIR env
	if [[ -v SMARTCD_CONFIG_DIR ]]; then
		if [[ ! -d ${SMARTCD_CONFIG_DIR} ]]; then
			>&2 echo "The ${SMARTCD_CONFIG_DIR} doesn't exist!!"
			echo "Configuring SMARTCD_CONFIG_DIR to ${HOME}/.config/.smartcd"

			export SMARTCD_CONFIG_DIR=${HOME}/.config/.smartcd
			[[ -d ${SMARTCD_CONFIG_DIR} ]] || mkdir -p ${SMARTCD_CONFIG_DIR}
		fi
	else 
		export SMARTCD_CONFIG_DIR=${HOME}/.config/.smartcd
		[[ -d ${SMARTCD_CONFIG_DIR} ]] || mkdir -p ${SMARTCD_CONFIG_DIR}
	fi

	# log files
	local recent_dir_log="${SMARTCD_CONFIG_DIR}/smartcd.log" # stores last 50 unique visited absolute paths
	local error_log="${SMARTCD_CONFIG_DIR}/smartcd_error.log" # stores error log
	local parent_dir_log="${SMARTCD_CONFIG_DIR}/smartcd_parent_dir.log" # stores parent directories's absolute paths

	# ---------------------------------------------------------------------------------------------------------------------

	# configure & validate REC_LISTING_CMD env
	validate_rec_listing_cmd() {
		if [[ -v REC_LISTING_CMD ]]; then
			if [[ ${REC_LISTING_CMD} != exa* && ${REC_LISTING_CMD} != tree* ]]; then
				export REC_LISTING_CMD
			elif [[ ${REC_LISTING_CMD} = exa* ]]; then
				if [[ $( whereis -b exa | awk '{print $2}' ) = *exa ]]; then export REC_LISTING_CMD;
				elif [[ $( whereis -b tree | awk '{print $2}' ) = *tree ]]; then export REC_LISTING_CMD="tree -C";
				else export REC_LISTING_CMD=""; fi
			elif [[ ${REC_LISTING_CMD} = tree* ]]; then
				if [[ $( whereis -b tree | awk '{print $2}' ) = *tree ]]; then export REC_LISTING_CMD
				elif [[ $( whereis -b exa | awk '{print $2}') = *exa ]]; then export REC_LISTING_CMD="exa -TaF -I '.git' --icons --group-directories-first --git-ignore --colour=always"
				else export REC_LISTING_CMD=""; fi
			fi
		else
			if [[ $( whereis -b exa | awk '{print $2}' ) = *exa ]]; then export REC_LISTING_CMD="exa -TaF -I '.git' --icons --group-directories-first --git-ignore --colour=always"
			elif [[ $( whereis -b tree | awk '{print $2}' ) = *tree ]]; then export REC_LISTING_CMD="tree -C";
			else export REC_LISTING_CMD=""; fi
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
		sed -i '51,$ d' ${recent_dir_log} # remove lines from line no. 51 to end. (keep only last 50 unique visited paths)
	}

	# feature
	sub_dir_hop() {
		builtin cd $1 2> ${error_log}
		if [[ ! $? -eq 0 ]]; then # the directory is not in any of cdpath values
			local selected_entry=""
			validate_rec_listing_cmd
			if [[ ${REC_LISTING_CMD} == "" ]]; then
				selected_entry=($(fd --hidden --exclude .git/ --type d -i -F $1 | fzf --exit-0))
			else
				selected_entry=($(fd --hidden --exclude .git/ --type d -i -F $1 | fzf --exit-0 --preview "${REC_LISTING_CMD} {}"))
			fi

			if [[ ${selected_entry} = "" ]]; then
				>&2 echo "No directory found or selected!"
			else
				builtin cd ${selected_entry} && generate_recent_dir_log
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
			local selected_entry=""
			validate_rec_listing_cmd
			if [[ ${REC_LISTING_CMD} == "" ]]; then
				selected_entry=($(cat ${recent_dir_log} | fzf --query=$1))
			else 
				selected_entry=($(cat ${recent_dir_log} | fzf --query=$1 --preview "${REC_LISTING_CMD} {}"))
			fi

			[[ ${selected_entry} != "" ]] && builtin cd ${selected_entry} && generate_recent_dir_log
		fi
	}

	# feature
	parent_dir_hop() {
		_path=${PWD%/*}
		[[ -f ${parent_dir_log} ]] && truncate -s 0 ${parent_dir_log}

		while [[ ${_path} != "" ]]; do
			fd --search-path ${_path} -t d --max-depth=1 -i -H -F $1 >> ${parent_dir_log}
			_path=${_path%/*}
		done

		if [[ ! -s ${parent_dir_log} ]]; then
			>&2 echo "No matching parent-directory found!"
		else
			local selected_entry=""
			validate_rec_listing_cmd
			if [[ ${REC_LISTING_CMD} = "" ]]; then
				selected_entry=($(cat ${parent_dir_log} | fzf))
			else
				selected_entry=($(cat ${parent_dir_log} | fzf --preview "${REC_LISTING_CMD} {}"))
			fi
			[[ ${selected_entry} != "" ]] && builtin cd ${selected_entry} && generate_recent_dir_log
		fi
	}

	# ---------------------------------------------------------------------------------------------------------------------
	
	if [[ $# -eq 2 && $1 == '..' ]]; then
		parent_dir_hop $2
	elif [[ $1 != '--' ]]; then
		sub_dir_hop $1
	else
		recent_visited_dirs $2
	fi
}

# validate if both fzf & fd are available or not
if [[ $( whereis -b fzf | awk '{print $2}' ) = *fzf && $( whereis -b fd | awk '{print $2}' ) = *fd ]]; then
	alias cd="__smartcd__"
else
	[[ $( whereis -b fzf | awk '{print $2}' ) != *fzf ]] && >&2 echo "Can't use SmartCd: fzf not found !"
	[[ $( whereis -b fd | awk '{print $2}' ) != *fd ]] && >&2 echo "Can't use SmartCd: fd not found !"
fi
