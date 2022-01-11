# configure & validate SMARTCD_FZF_PREVIEW_CMD env
__smartcd::fzf_preview() {
	if [[ $( whereis -b exa | __smartcd::col2 ) = *exa ]]; then
		export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-"exa -TaF -I '.git' --icons --group-directories-first --git-ignore --colour=always"}
	elif [[ $( whereis -b tree | __smartcd::col2 ) = *tree ]]; then
		export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-"tree -I '.git' -C -a"}
	else export SMARTCD_FZF_PREVIEW_CMD=${SMARTCD_FZF_PREVIEW_CMD:-""}; fi
}

# run fzf command
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
