# SmartCd - A Mnemonist `cd` Command

## Description

A `cd` command with an improved usability feature, which can remember last 20 unique visited paths in your filesystem, and you can also fuzzy search any of these last visited paths and automatically change to that particular directory location.

## Usage

`cd --` will present you with a list of last 20 unique paths you visited. You can fuzzy search the list and select anyone to change location to that path automatically.

## Requirements

- [Zsh](https://www.zsh.org/)
- [Fzf](https://github.com/junegunn/fzf) (you must have `fzf` already configured or at least know how to configure it)

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

`Smartcd` stores logs in `$SMARTCD_DIR` location, which defaults to `~/.config/.smartcd`. To change location of the log file, export `SMARTCD_DIR` with your desired location of the log file.

## Inspiration

[enhancd](https://github.com/b4b4r07/enhancd)

## [LICENSE](https://github.com/CodesOfRishi/smartcd/blob/main/LICENSE)

The MIT License (MIT)

Copyright (c) 2021 Rishi K.
