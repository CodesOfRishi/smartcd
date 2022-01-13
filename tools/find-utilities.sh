# arguments for find or fd/fdfind command
if [[ ${smartcd_finder} = *fdfind || ${smartcd_finder} = *fd ]]; then
	local find_base_dir_cmd="${smartcd_finder} --hidden --exclude .git/ --type d -I --absolute-path --base-directory \${SMARTCD_BASE_DIR}"
	local find_sub_dir_cmd="${smartcd_finder} --hidden --exclude .git/ --type d -I"
	local find_parent_dir_cmd_args="${smartcd_finder} --exclude .git/ --search-path \${_path} -t d --max-depth=1 -H -I"
	local find_parent_dir_root_cmd_args="${smartcd_finder} --exclude .git/ --search-path / -t d --max-depth=1 -H -I"
else 
	local find_base_dir_cmd="${smartcd_finder} \${SMARTCD_BASE_DIR} -type d ! -path '*/\.git/*' 2> /dev/null | ${smartcd_grep} -v '\.git$'"
	local find_sub_dir_cmd="${smartcd_finder} . -type d ! -path '*/\.git/*' 2> /dev/null | ${smartcd_grep} -v '\.git$'"
	local find_parent_dir_cmd_args="${smartcd_finder} \${_path} -maxdepth 1 -type d ! -path '*/\.git/*' 2> /dev/null"
	local find_parent_dir_root_cmd_args="${smartcd_finder} / -maxdepth 1 -type d ! -path '*/\.git/*' 2> /dev/null"
fi
