#!/usr/bin/env bash
PS_DARWIN_CHAR=''
PS_LINUX_CHAR='$'
THEME_PROMPT_SEPARATOR=""

SHELL_SSH_CHAR="⌁ "
SHELL_THEME_PROMPT_COLOR="\[$(tput setab 12)\]"
SHELL_SSH_THEME_PROMPT_COLOR="\[$(tput setab 12)\]"

VIRTUALENV_CHAR="ⓔ "
VIRTUALENV_THEME_PROMPT_COLOR="\[$(tput setab 12)\]"

SCM_NONE_CHAR=""
SCM_GIT_CHAR="⎇  "
SCM_GIT_BEHIND_CHAR="⇣"
SCM_GIT_AHEAD_CHAR="⇡"

GIT_THEME_PROMPT_DIRTY=" +"
GIT_THEME_PROMPT_CLEAN=" ○"
GIT_THEME_PROMPT_CLEAN_COLOR="\[$(tput setab 5)\]"
GIT_THEME_PROMPT_DIRTY_COLOR="\[$(tput setab 11)\]"
GIT_THEME_PROMPT_STAGED_COLOR="\[$(tput setab 3)\]"
GIT_THEME_PROMPT_UNTRACKED_COLOR="\[$(tput setab 6)\]"

SCM_THEME_PROMPT_CLEAN="✓"
SCM_THEME_PROMPT_DIRTY="✗"
SCM_THEME_PROMPT_COLOR="\[$(tput setaf 15)\]"
SCM_THEME_PROMPT_CLEAN_COLOR="\[$(tput setab 2)\]"
SCM_THEME_PROMPT_DIRTY_COLOR="\[$(tput setab 1)\]"

CWD_THEME_PROMPT_COLOR="\[$(tput setab 14)\]"

LAST_STATUS_THEME_PROMPT_COLOR="\[$(tput setab 12)\]"

function set_rgb_color {
    if [[ "${1}" != "-" ]]; then
        fg="38;5;${1}"
    fi
    if [[ "${2}" != "-" ]]; then
        bg="48;5;${2}"
        [[ -n "${fg}" ]] && bg=";${bg}"
    fi
    echo -e "\[\033[${fg}${bg}m\]"
}

function powerline_shell_prompt {
    if [[ -n "${SSH_CLIENT}" ]]; then
        SHELL_PROMPT="${SCM_THEME_PROMPT_COLOR}${SHELL_SSH_THEME_PROMPT_COLOR} ${SHELL_SSH_CHAR}\u@\h ${normal}"
        LAST_THEME_COLOR=${SHELL_SSH_THEME_PROMPT_COLOR}
    else
        SHELL_PROMPT="${SCM_THEME_PROMPT_COLOR}${SHELL_THEME_PROMPT_COLOR} \u ${normal}"
        LAST_THEME_COLOR=${SHELL_THEME_PROMPT_COLOR}
    fi
}

function powerline_virtualenv_prompt {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        virtualenv=$(basename "$VIRTUAL_ENV")
        VIRTUALENV_PROMPT="${SCM_THEME_PROMPT_COLOR}${VIRTUALENV_THEME_PROMPT_COLOR}${normal} ${VIRTUALENV_CHAR}$virtualenv ${normal}"
        LAST_THEME_COLOR=${VIRTUALENV_THEME_PROMPT_COLOR}
    else
        VIRTUALENV_PROMPT=""
    fi
}

function powerline_scm_prompt {
    scm_prompt_vars
    local git_status_output
    git_status_output=$(git status 2> /dev/null )

    if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
        if [[ "${SCM_DIRTY}" -eq 1 ]]; then
            if [ -n "$(echo $git_status_output | grep 'Changes not staged')" ]; then
                SCM_PROMPT="${SCM_THEME_PROMPT_COLOR}${GIT_THEME_PROMPT_DIRTY_COLOR}"
            elif [ -n "$(echo $git_status_output | grep 'Changes to be committed')" ]; then
                SCM_PROMPT="\[$(tput setaf 11)\]${GIT_THEME_PROMPT_STAGED_COLOR}"
            elif [ -n "$(echo $git_status_output | grep 'Untracked files')" ]; then
                SCM_PROMPT="${SCM_THEME_PROMPT_COLOR}${GIT_THEME_PROMPT_UNTRACKED_COLOR}"
            else
                SCM_PROMPT="${SCM_THEME_PROMPT_COLOR}${GIT_THEME_PROMPT_DIRTY_COLOR}"
            fi
        else
            SCM_PROMPT="${SCM_THEME_PROMPT_COLOR}${GIT_THEME_PROMPT_CLEAN_COLOR}"
        fi
        [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]] && SCM_PROMPT+=" ${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}${SCM_GIT_BEHIND}${SCM_GIT_AHEAD}${SCM_GIT_STASH}"
        SCM_PROMPT="${normal}${SCM_PROMPT} ${normal}"
        LAST_THEME_COLOR=${SCM_THEME_PROMPT_COLOR}
    else
        SCM_PROMPT=""
    fi
}

function powerline_cwd_prompt {
    CWD_PROMPT="${SCM_THEME_PROMPT_COLOR}${CWD_THEME_PROMPT_COLOR} \w ${normal}"
    LAST_THEME_COLOR=${CWD_THEME_PROMPT_COLOR}
}

function powerline_platform {
    if [ $(uname) = "Darwin" ]; then
        PLATFORM_CHAR=$PS_DARWIN_CHAR
    else
        PLATFORM_CHAR=$PS_LINUX_CHAR
    fi
}

function powerline_last_status_prompt {
    if [[ "$1" -eq 0 ]]; then
        LAST_STATUS_PROMPT="${SCM_THEME_PROMPT_COLOR}${SCM_THEME_PROMPT_CLEAN_COLOR} ${SCM_THEME_PROMPT_CLEAN} ${normal}"
    else
        LAST_STATUS_PROMPT="${SCM_THEME_PROMPT_COLOR}${SCM_THEME_PROMPT_DIRTY_COLOR} ${SCM_THEME_PROMPT_DIRTY} ${normal}"
    fi
}

function powerline_prompt_command() {
    local LAST_STATUS="$?"

    powerline_shell_prompt
    powerline_virtualenv_prompt
    powerline_scm_prompt
    powerline_cwd_prompt
    powerline_platform
    powerline_last_status_prompt LAST_STATUS

    PS1="${SHELL_PROMPT}${VIRTUALENV_PROMPT}${CWD_PROMPT}${SCM_PROMPT}${LAST_STATUS_PROMPT}\n${PLATFORM_CHAR} "
}

PROMPT_COMMAND=powerline_prompt_command

