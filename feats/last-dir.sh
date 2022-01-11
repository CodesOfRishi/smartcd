# Feature: Traverse to $OLDPWD.

__smartcd::last_dir_hop() {
	builtin cd "${OLDPWD}" && generate_recent_dir_log
}
