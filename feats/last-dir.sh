# Feature: Traverse to $OLDPWD.

export SMARTCD_LAST_DIR_OPT=${SMARTCD_LAST_DIR_OPT-"-"} # option for moving to $OLDPWD

__smartcd::last_dir_hop() {
	builtin cd "${OLDPWD}" && generate_recent_dir_log
}
