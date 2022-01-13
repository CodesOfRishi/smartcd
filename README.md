<div align="center">

# SmartCd

A `cd` command with improved and extended usability features to quickly navigate your Linux filesystem.

[Features](#features) •
[Requirements](#requirements) •
[Installation](#installation) •
[Zsh Completion](#zsh-completion) •
[Configurations](#configurations) •
[Other Info](#other-info) •
[Known Caveats](#known-caveats)

</div>

## Features

- If you're in a git repository and deeply embedded within directories, you can directly traverse to the root of the git repository.

  **Synopsis:** `cd .`

- Often when you're deeply embedded within directories, you may want to be able to search and traverse with respect to a particular directory. For example, many users may often feel the need of searching and traversing within their `$HOME` directory irrespective of what their current working directory is.<br>By default, `smartcd` will use `$HOME` as base. User can provide multiple base paths as well (check out `SMARTCD_BASE_PATHS` & `SMARTCD_BASE_DIR_KEYBIND`).

  **Synopsis:** `cd (-b | --base) [string ...]`

- `smartcd` can remember the last 50 (default) unique recently visited directory locations, where you can Fuzzy search and automatically traverse to the selected one.

  **Synopsis:** `cd -- [string ...]`

  <img src="https://i.imgur.com/UqfGpLw.gif">

- If the provided argument is not in your `$CDPATH`, then `smartcd` will present you with a list of all the *sub-directories* that matched the argument, where you can Fuzzy search & directly traverse to the selected path.

  **Synopsis:** `cd [string ...]`

  <img src="https://i.imgur.com/xVDkHD7.gif">

- `smartcd` can search *parent-directories* based on the argument string provided. It will list all parent directories that matched the argument string, where you can fuzzy search and automatically traverse to the selected path.

  **Synopsis:** `cd .. [string ...]`

  <img src="https://i.imgur.com/rgkVR6v.gif">

- You can pipe options, (with or without) arguments and as well as multiple directory paths stored in a file to `smartcd`.

  **NOTE**: Since v3.2.0, you can also use `cd` with options & arguments along with piping, simultaneously.
  For example,

  ```bash
   echo ri \!git \'lua | cd -- \'color
   cat $HOME/_testing/rough/dir_paths.txt | cd "bin 'dot"
  ```

  <img src="https://i.imgur.com/gy3LPnq.gif">

### Other Features
- Remove invalid paths from log.

  ```bash
  cd (-c | --clean)
  ```

- Print version information.

  ```bash
  cd (-v | --version)
  # or
  echo $SMARTCD_VERSION
  ```


## Why SmartCd

Initially, I tried `enhancd` which is a very good alternative for the inbuilt `cd` command, but the features of `enhancd` were more than enough for me and also I had to change my familiarity and regular habit with using some of the default options or arguments that are often used with the inbuilt `cd` command, just to familiarize and adapt with the tool.

I started by making `smartcd` remember the last 20 unique visited paths using the `--` option. I wanted to keep `cd` as close to its native implementation, and at the same time increase its usability. The `--` option with the `cd` command was of no particular use to me, so I just provided an extra functionality to that option.

## Requirements

- [Fzf](https://github.com/junegunn/fzf)

Tested on [Zsh](https://www.zsh.org/) & [Bash](https://www.gnu.org/software/bash/).

### Optional requirements but recommended

- [Fd](https://github.com/sharkdp/fd)
- [Ripgrep](https://github.com/BurntSushi/ripgrep)
- [Exa](https://the.exa.website/) or [Tree](https://linux.die.net/man/1/tree)
  - Fzf will use the current line from the filter as the argument for `exa` or `tree`, and will show the result in a split/preview window of the filter.
  - `smartcd` has inbuilt support for `exa` and `tree`, i.e., just install either `exa` or `tree`, and `smartcd` will handle the rest.
  - Otherwise, if you want to use any other tool, you need to export `SMARTCD_FZF_PREVIEW_CMD` env with your desired command (with options).
  - Even if you want to use `exa` or `tree` with different options other than the default ones, you can export `SMARTCD_FZF_PREVIEW_CMD` env specifying the command with your desired options.


## Installation

### Manual Installation

1. Clone the repository.

   ```bash
   git clone --depth 1 https://github.com/CodesOfRishi/smartcd.git
   ```
   
2. Source the `smartcd.sh` script in your shell configuration file (`.bashrc` and/or `.zshrc`).

   ```bash
   source path/to/smartcd/smartcd.sh
   ```

   Where `path/to/smartcd/smartcd.sh` is the path to the `smartcd.sh` script in the smartcd repository.

3. Open a new shell or reload your shell configuration file.

### [Zinit](https://github.com/zdharma-continuum/zinit)

1. Add the below code in your `.zshrc` (~~`.bashrc`~~).

   ```bash
   zinit ice depth=1
   zinit light "CodesOfRishi/smartcd"
   ```

2. Open a new shell or reload your shell configuration file.

### [Sheldon](https://sheldon.cli.rs/)

1. Add the plugin to Sheldon config file.

   ```bash
   sheldon add smartcd --github CodesOfRishi/smartcd
   ```

2. Open a new shell or reload your shell configuration file.

## Zsh Completion

- Add the below code after calling `compinit` in your `.zshrc`.

  ```bash
  compdef __smartcd__=cd
  ```

  This will enable completion for SmartCd same as of built-in `cd` command.

- If you also want hidden directories completion for SmartCd, you need to enable GLOB_DOTS option.

  ```bash
  setopt globdots
  ```

Lastly, open a new shell or reload your shell configuration file.

## Configurations

<details>
<summary><strong><code>SMARTCD_CONFIG_DIR</code></strong></summary>
<code>smartcd</code> stores logs in this location, which defaults to <code>~/.config/.smartcd</code>. To change location of the log file, export <code>SMARTCD_CONFIG_DIR</code> with your desired location.
</details>

<details>
<summary><strong><code>SMARTCD_SELECT_ONE</code></strong></summary>
If only 1 matching path is found and if the env is set to
<ul>
<li><code>1</code> then <code>smartcd</code> will directly traverse to the only matched directory path.</li>
<li><code>0</code> then <code>smartcd</code> will bring the interactive <code>fzf</code> filter before travering to the path.</li>
</ul>
This defaults to <code>0</code>.
</details>

<details>
<summary><strong><code>SMARTCD_FZF_PREVIEW_CMD</code></strong></summary> 
Command (with options) to use with current line as argument from the <code>fzf</code> filter to show its result in <code>fzf</code>'s split/preview window.
<ul>
<li>For <code>exa</code>, it defaults to <code>exa -TaF -I '.git' --icons --group-directories-first --git-ignore --colour=always</code>.</li>
<li>For <Code>tree</Code>, it defaults to <Code>tree -I '.git' -C -a</Code>.</li>
</ul>
</details>

<details>
<summary><strong><code>SMARTCD_HIST_DIR_LOG_SIZE</code></strong></summary> 
Set number of unique recently visited directory paths <code>smartcd</code> should remember. This defaults to 50.
</details>

<details>
<summary><strong><code>SMARTCD_COMMAND</code></strong></summary> 
To use a custom command name for using smartcd, export <code>SMARTCD_COMMAND</code> env with your desired command name. This defaults to <code>cd</code>.
</details>

<details>
<summary><strong><code>SMARTCD_BASE_DIR_OPT</code></strong></summary> 
To use a different option for searching & traversing w.r.t. a particular base directory, export <code>SMARTCD_BASE_DIR_OPT</code> with your desired options with <i>spaces</i>. SmartCd will validate only the first 2 options provided in the env. This defaults to <code>"-b --base"</code>.
</details>

<details>
<summary><strong><code>SMARTCD_PARENT_DIR_OPT</code></strong></summary> 
To use a different option name for searching & traversing to parent-directories, export <code>SMARTCD_PARENT_DIR_OPT</code> with your desired option. This defaults to <code>..</code>.
</details>

<details>
<summary><strong><code>SMARTCD_HIST_DIR_OPT</code></strong></summary> 
To use a different option name for searching & traversing to recently visited directories, export <code>SMARTCD_HIST_DIR_OPT</code> with your desired option. This defaults to <code>--</code>.
</details>

<details>
<summary><strong><code>SMARTCD_LAST_DIR_OPT</code></strong></summary> 
To use a different option for traversing to last visited working directory, export <code>SMARTCD_LAST_DIR_OPT</code> with your desired option. This defaults to <code>-</code>.
</details>

<details>
<summary><strong><code>SMARTCD_GIT_ROOT_OPT</code></strong></summary> 
To use a different option name for traversing to root of a git repository, export <code>SMARTCD_GIT_ROOT_OPT</code> with your desired option. This defaults to <code>.</code>.
</details>

<details>
<summary><strong><code>SMARTCD_CLEANUP_OPT</code></strong></summary> 
To use a different option name for removing invalid paths from log, export <code>SMARTCD_CLEANUP_OPT</code> with your desired options with <i>spaces</i>. SmartCd will validate only the first 2 options provided in the env. This defaults to <code>"-c --clean"</code>.
</details>

<details>
<summary><strong><code>SMARTCD_VERSION_OPT</code></strong></summary> 
To use a different option name to print version information, export <code>SMARTCD_VERSION_OPT</code> with your desired options with <i>spaces</i>. SmartCd will validate only the first 2 options provided in the env. This defaults to <code>"-v --version"</code>.
</details>

## Other Info

**What if the user configures the same options for multiple features?** 

SmartCd gives priority in the following order:<br>
`SMARTCD_HIST_OPT` > `SMARTCD_PARENT_DIR_OPT` > `SMARTCD_LAST_DIR_OPT` > `SMARTCD_BASE_PARENT_OPT` > `SMARTCD_GIT_ROOT_OPT` > `SMARTCD_CLEANUP_OP` > `SMARTCD_VERSION_OPT` 

## Known Caveats

- `cd .` won't work if you're in `.git/` directory of a git repository.
- `cd .` will follow up any symbolic links. For e.g., if you're in `~/my-proj/foo/bar` and `~/my-proj` is symbolic linked to `~/src/my-proj`, then `cd .` command will move you to `~/src/my-proj`.
- The piping feature only works with `Zsh`, because in `Bash` every command in a pipeline is executed as a separate process (i.e., in a subshell).

## Inspiration

[enhancd](https://github.com/b4b4r07/enhancd)

## [LICENSE](https://github.com/CodesOfRishi/smartcd/blob/main/LICENSE)

The MIT License (MIT)

Copyright (c) 2021 Rishi K.
