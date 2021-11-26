# SmartCd - A Mnemonist `cd` Command

## Description

A `cd` command with an improved usability feature, which can remember last 20 unique visited paths in your filesystem, you can also fuzzy search any of these last visited paths and automatically change to that particular path.

## Usage

`cd --` will present you with a list of last 20 unique paths you visited. You will be able to fuzzy search and go into anyone of the directory path from the list.

## Requirements

- [Zsh](https://www.zsh.org/)
- [Fzf](https://github.com/junegunn/fzf) (you must have `fzf` already configured or at least know how to configure `fzf`)

### Optional requirements (anyone) but recommended

- [Exa](https://github.com/ogham/exa)
- Tree

## Installation

1. Clone this repository

2. Just put the below code in your `.zshrc` (Zsh configuration file) after `FZF` configurations.

   ```zsh
   source path/to/smartcd
   ```

   Where `path/to/smartcd` is the path to the `smartcd` script.

3. Open a new Zsh shell.

## Log File Info

`Smartcd` stores logs in `$SMARTCD_DIR` location. To change location of the log file, export `SMARTCD_DIR` with your desired location of the log file.
