## Description

This script will make a git fetch and git pull for a git branch while keeping the branches of work

## INFORMATIONS

There are two modes, auto and manual mode.
- When auto mode is enabled, it pull the main workflow in this order:
    - trb-*-release-*
    - release-*
If none of the branches are found, it pull master.
- When the manual mode is active, the program pull the specified branch when activating the manual mode (see option below)

## Getting started

First, [install GR] (https://github.com/mixu/gr)

Next, clone git-pull on the root of your projects

Finally, run the following command:

    ./git-pull
    
## Usage

Usage:

    ./git-pull <options>

## Options

To switch to auto mode : `./git-pull -auto`

to switch to manual mode : `./git-pull -manual:name_of_branch_to_pull`

To display all available options : `--help`
