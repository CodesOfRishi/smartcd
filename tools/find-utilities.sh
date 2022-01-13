# arguments for find or fd/fdfind command
if [[ ${SMARTCD_FINDER} = *fdfind || ${SMARTCD_FINDER} = *fd ]]; then
	local find_base_dir_cmd="${SMARTCD_FINDER} --hidden --exclude .git/ --type d -I --absolute-path --base-directory \${SMARTCD_BASE_DIR}"
	local find_sub_dir_cmd="${SMARTCD_FINDER} --hidden --exclude .git/ --type d -I"
	local find_parent_dir_cmd="${SMARTCD_FINDER} --exclude .git/ --search-path \${_path} -t d --max-depth=1 -H -I"
	local find_root_dir_cmd="${SMARTCD_FINDER} --exclude .git/ --search-path / -t d --max-depth=1 -H -I"
else 
	local find_base_dir_cmd="${SMARTCD_FINDER} \${SMARTCD_BASE_DIR} -type d ! -path '*/\.git/*' 2> /dev/null | ${SMARTCD_GREP} -v '\.git$'"
	local find_sub_dir_cmd="${SMARTCD_FINDER} . -type d ! -path '*/\.git/*' 2> /dev/null | ${SMARTCD_GREP} -v '\.git$'"
	local find_parent_dir_cmd="${SMARTCD_FINDER} \${_path} -maxdepth 1 -type d ! -path '*/\.git/*' 2> /dev/null"
	local find_root_dir_cmd="${SMARTCD_FINDER} / -maxdepth 1 -type d ! -path '*/\.git/*' 2> /dev/null"
fi
