# the following is a modification of the ohMyZsh half-life theme (https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/half-life.zsh-theme)
# which shortens the users prompt when in a repository with a vcs 
#
# prompt style and colors based on Steve Losh's Prose theme:
# https://github.com/sjl/oh-my-zsh/blob/master/themes/prose.zsh-theme
#
# vcs_info modifications from Bart Trojanowski's zsh prompt:
# http://www.jukie.net/bart/blog/pimping-out-zsh-prompt
#
# git untracked files modification from Brian Carper:
# https://briancarper.net/blog/570/git-info-in-your-zsh-prompt


# use extended color palette if available
# note: reset_color seems to be automatically set
if [[ $TERM = (*256color|*rxvt*) ]]; then
  turquoise="%F{81}"
  orange="%F{166}"
  purple="%F{135}"
  hotpink="%F{161}"
  limegreen="%F{118}"
else
  turquoise="%F{cyan}"
  orange="%F{yellow}"
  purple="%F{magenta}"
  hotpink="%F{red}"
  limegreen="%F{green}"
fi

# load in vcs_info to provide version control system info
autoload -Uz vcs_info
# zstyle ':vcs_info:*+*:*' debug true # uncomment to print debug info

# enable VCS systems you use
zstyle ':vcs_info:*' enable git svn

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
zstyle ':vcs_info:*:prompt:*' check-for-changes true

# set formats (https://github.com/zsh-users/zsh/blob/master/Functions/VCS_Info/VCS_INFO_formats)
# %b - branchname
# %u - unstagedstr (see below)
# %c - stagedstr (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
# %S - path in the repository
PR_RST="%{${reset_color}%}"
FMT_BRANCH=" on ${turquoise}%b%u%c${PR_RST}"
FMT_ACTION=" performing a ${limegreen}%a${PR_RST}"
FMT_UNSTAGED="${orange} ●"
FMT_STAGED="${limegreen} ●"

zstyle ':vcs_info:*:prompt:*' unstagedstr   "${FMT_UNSTAGED}"
zstyle ':vcs_info:*:prompt:*' stagedstr     "${FMT_STAGED}"
zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
zstyle ':vcs_info:*:prompt:*' nvcsformats   ""


function steeef_chpwd {
  PR_GIT_UPDATE=1
}

function steeef_preexec {
  case "$2" in
  *git*|*svn*) PR_GIT_UPDATE=1 ;;
  esac
}

function steeef_precmd {
  (( PR_GIT_UPDATE )) || return

  # check for untracked files or updated submodules, since vcs_info doesn't
  if [[ -n "$(git ls-files --other --exclude-standard 2>/dev/null)" ]]; then
    PR_GIT_UPDATE=1
    FMT_BRANCH="${PM_RST} on ${turquoise}%b%u%c${hotpink} ●${PR_RST}"
  else
    FMT_BRANCH="${PM_RST} on ${turquoise}%b%u%c${PR_RST}"
  fi

  # preps for vcs_info call on provided format strings, stores in vcs_info_msg_<n>_
  zstyle ':vcs_info:*:prompt:*' formats "${FMT_BRANCH}" "%r/%S"

  vcs_info 'prompt'
  PR_GIT_UPDATE=
}

# vcs_info running hooks
PR_GIT_UPDATE=1

autoload -U add-zsh-hook
add-zsh-hook chpwd steeef_chpwd
add-zsh-hook precmd steeef_precmd
add-zsh-hook preexec steeef_preexec

# ruby prompt settings
ZSH_THEME_RUBY_PROMPT_PREFIX="with%F{red} "
ZSH_THEME_RUBY_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_RVM_PROMPT_OPTIONS="v g"

# virtualenv prompt settings
ZSH_THEME_VIRTUALENV_PREFIX=" with%F{red} "
ZSH_THEME_VIRTUALENV_SUFFIX="%{$reset_color%}"

# enable prompt substitutions and set
setopt prompt_subst
THEME_PROMPT="${purple}%n%{$reset_color%} in ${limegreen}%~%{$reset_color%}\$(virtualenv_prompt_info)\$(ruby_prompt_info)\$vcs_info_msg_0_${orange} λ%{$reset_color%} "
PROMPT=$THEME_PROMPT

# update prompt when in direnv "custom prompt" environment
function updatePrompt {
  if [[ -n "${vcs_info_msg_0_}" ]]; then
    CURR_REL_PATH=$(echo "$vcs_info_msg_1_" | sed 's/\/\.$//')
    PROMPT="${purple}$(git config --local user.name || echo "%n")%{$reset_color%} in ${limegreen}${CURR_REL_PATH}%{$reset_color%}\$(virtualenv_prompt_info)\$(ruby_prompt_info)\$vcs_info_msg_0_${orange} λ%{$reset_color%} "
  else
    PROMPT=$THEME_PROMPT
  fi
}

# run check before printing prompt each time
add-zsh-hook precmd updatePrompt
