# SmartCd - A Mnemonist `cd` Command

## Description

A `cd` command with improved and extended usability features to quickly navigate your Linux filesystem.

## Features

- If you're in a git repository and deeply embedded within directories, you can directly traverse to the root of the git repository.

  **Syntax:** `cd .`

- By default `smartcd` can remember the last 50 unique visited directory locations, where you can Fuzzy search and automatically traverse to the selected one.

  **Syntax:** `cd -- [string ...]`

  <img src="https://i.imgur.com/a5Ddvif.gif">
  
- If the provided argument is not in your `$CDPATH`, then `smartcd` will present you with a list of all the *sub-directories* that matched the argument, where you can Fuzzy search & directly traverse to the selected path.

  **Syntax:** `cd [string ...]`

  <img src="https://i.imgur.com/fVbZjcI.gif">
  
- `smartcd` can also search *parent-directories* based on the argument string provided. It will list all parent directories that matched the argument string, where you can fuzzy search and automatically traverse to the selected path.

  **Syntax:** `cd .. [string ...]`

  <img src="https://i.imgur.com/eR9veZ0.gif">
  
- You can pipe options, (with or without) arguments and as well as multiple directory paths to `smartcd`.

  <img src="https://i.imgur.com/E9KBJmr.gif">

### Other Features
- Remove invalid paths from log using `--clean` option.

  ```bash
  cd --clean
  ```

- Use `--version` option to print version information.

  ```bash
  cd --version
  # or
  echo $SMARTCD_VERSION
  ```


## Why SmartCd

Initially, I tried `enhancd` which is a very good alternative for the inbuilt `cd` command, but the features of `enhancd` were more than enough for me and also I had to change my familiarity and regular habit with using some of the options or arguments that are often used with the inbuilt `cd` command, just to familiarize and adapt with the tool.

I started by making `smartcd` remember the last 20 unique visited paths using the `--` option. I wanted to keep `cd` as close to its native implementation, and at the same time increase its usability. The `--` option with the `cd` command was of no particular use to me, so I just provided an extra functionality to that option.

## Requirements

- [Fzf](https://github.com/junegunn/fzf)

Tested on [Zsh](https://www.zsh.org/) & [Bash](https://www.gnu.org/software/bash/).

### Optional requirements but recommended

- [Fd](https://github.com/sharkdp/fd)
- [Ripgrep](https://github.com/BurntSushi/ripgrep)
- [Exa](https://the.exa.website/) or [Tree](https://linux.die.net/man/1/tree)
  - Fzf will use the current line from the filter as the argument for `exa` or `tree`, and will show the result in a split window of the filter.
  - `smartcd` has inbuilt support for `exa` and `tree`, i.e., just install either `exa` or `tree`, and `smartcd` will handle the rest.
  - Otherwise, if you want to use any other tool, you need to export `SMARTCD_REC_LISTING_CMD` env with your desired command (with options).
  - Even if you want to use `exa` or `tree` with different options other than the default ones, you can export `SMARTCD_REC_LISTING_CMD` env specifying the command with your desired options.


## Installation

### Manual Installation

1. Download the `smartcd.sh` script.

   ```bash
   # using curl
   curl -O https://raw.githubusercontent.com/CodesOfRishi/smartcd/main/smartcd.sh
   # OR using wget
   wget https://raw.githubusercontent.com/CodesOfRishi/smartcd/main/smartcd.sh
   ```

2. Just put the below code in your shell configuration file (`.bashrc` and/or `.zshrc`).

   ```bash
   source path/to/smartcd.sh
   ```

   Where `path/to/smartcd.sh` is the path to the `smartcd.sh` script.

   Or you can also source it using a plugin manager. For E.g., if using [sheldon](https://github.com/rossmacarthur/sheldon) shell plugin manager, you can run,

   ```bash
   sheldon add smartcd --github CodesOfRishi/smartcd
   ```

3. Open a new shell or reload your shell configuration file.

### Using Homebrew

Currently has `v2.1.1`.

```bash
brew tap CodesOfRishi/smartcd
brew install smartcd
echo "source \$( whereis -b smartcd.sh | awk '{print \$2}' )" >> $HOME/.bashrc # or $HOME/.zshrc if using Zsh
```

This will also install the required dependencies, but you may have to install the optional dependencies yourself.

```bash
brew upgrade smartcd # to upgrade smartcd
```


## Configurations
<details>
<summary><strong><code>SMARTCD_CONFIG_DIR</code></strong></summary>
<code>smartcd</code> stores logs in this location, which defaults to <code>~/.config/.smartcd</code>. To change location of the log file, export <code>SMARTCD_CONFIG_DIR</code> with your desired location.
</details>

<details>
<summary><strong><code>SMARTCD_REC_LISTING_CMD</code></strong></summary> 
Command (with options) to use for recursive directory listing in tree format in <code>fzf</code> preview. If you want to use any other command export it with your desired command (with options).
</details>

<details>
<summary><strong><code>SMARTCD_HIST_SIZE</code></strong></summary> 
Set number of unique recently visited directory paths <code>smartcd</code> should remember. This defaults to 50.
</details>

<details>
<summary><strong><code>SMARTCD_COMMAND</code></strong></summary> 
To use a custom command name for using smartcd, export <code>SMARTCD_COMMAND</code> env with your desired command name. This defaults to <code>cd</code>.
</details>

<details>
<summary><strong><code>SMARTCD_PARENT_DIR_OPT</code></strong></summary> 
To use a different option name for searching & traversing to parent-directories, export <code>SMARTCD_PARENT_DIR_OPT</code> with your desired name for the option. This defaults to <code>..</code>.
</details>

<details>
<summary><strong><code>SMARTCD_HIST_OPT</code></strong></summary> 
To use a different option name for searching & traversing to recently visited directories, export <code>SMARTCD_HIST_OPT</code> with your desired name for the option. This defaults to <code>--</code>.
</details>

<details>
<summary><strong><code>SMARTCD_GIT_ROOT_OPT</code></strong></summary> 
To use a different option name for traversing to root of a git repository, export <code>SMARTCD_GIT_ROOT_OPT</code> with your desired name for the option. This defaults to <code>.</code>.
</details>

<details>
<summary><strong><code>SMARTCD_CLEANUP_OPT</code></strong></summary> 
To use a different option name for removing invalid paths from log, export <code>SMARTCD_CLEANUP_OPT</code> with your desired option name. This defaults to <code>--clean</code>.
</details>

<details>
<summary><strong><code>SMARTCD_VERSION_OPT</code></strong></summary> 
To use a different option name to print version information, export <code>SMARTCD_VERSION_OPT</code> with your desired option name. This defaults to <code>--version</code>.
</details>

## Other Info

`smartcd` will now search results from directories that would otherwise be ignored by

- `.gitignore`
- `.git/info/exclude`
- The global gitignore configuration (by default `$HOME/.config/git/ignore`)
- `.ignore`
- [`.fdignore`](https://github.com/sharkdp/fd#excluding-specific-files-or-directories) (if using `fd`)
- The global [fd ignore file](https://github.com/sharkdp/fd#excluding-specific-files-or-directories) (usually `$HOME/.config/fd/ignore`) (if using `fd`)

## Known Caveats

- `cd .` won't work if you're in `.git/` directory of a git repository.
- `cd .` will follow up any symbolic links. For e.g., if you're in `~/my-proj/foo/bar` and `~/my-proj` is symbolic linked to `~/src/my-proj`, then `cd .` command will move you to `~/src/my-proj`.
- The piping feature only works with `Zsh`, because in `Bash` every command in a pipeline is executed as a separate process (i.e., in a subshell).

## Inspiration

[enhancd](https://github.com/b4b4r07/enhancd)

## [LICENSE](https://github.com/CodesOfRishi/smartcd/blob/main/LICENSE)

The MIT License (MIT)

Copyright (c) 2021 Rishi K.
