# SmartCd - A Mnemonist `cd` Command

## Description

A `cd` command with an improved usability feature, which can remember last 20 unique visited paths in your filesystem, and you can also fuzzy search any of these last visited paths and automatically change to that particular directory location.

## Usage

`cd --` will present you with a list of last 20 unique paths you visited. You can fuzzy search the list and select anyone to change location to that path automatically.

![](E:\_myspace\smartCd.gif)

## Why SmartCd

Initially, I tried `enhancd` which is a very good alternative for the inbuilt `cd` command, but the features of `enhancd` were more than enough for me and also I had to change my familiarity and regular habit with using some of the options or arguments that are often used with the inbuilt `cd` command, just to familiarize and adapt with the tool.

I wanted to keep `cd` as close to its native implementation, and at the same time increase its usability. The `--` option with the `cd` command was of no particular use to me, so I just provided an extra functionality to that option.

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

## To Do

- [ ] Users must be able to configure the number of unique last visited paths `smartcd` should remember.

## Inspiration

[enhancd](https://github.com/b4b4r07/enhancd)

## [LICENSE](https://github.com/CodesOfRishi/smartcd/blob/main/LICENSE)

The MIT License (MIT)

Copyright (c) 2021 Rishi K.
