
# workaround for urxvt vertical prompt placement
if [[ `ps ho command $(ps ho ppid $$)` == 'urxvt' ]]; then
   clear
 fi



# uncomment to measure statup time of plugins (also uncomment last line)
# zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi
#

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/usr/share/oh-my-zsh/

# load theme
#source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# load private zsh stuff
if [[ -r ~/.zshrc_private ]]; then
  source ~/.zshrc_private
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="minimal"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
export NVM_LAZY=1
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  docker
  npm
  yarn
  node # usage: node-docs fs
  nvm
  extract
  httpie
  z # usage: z dotfiles (quick dir access)
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

source ~/.cache/wal/colors.sh


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias pokemon='pokemon-colorscripts'

alias ts-node='ts-node --compiler-options "{ \"experimentalDecorators\": true }"'

alias pyload='node ~/projects/typescript-starter-server/src/pyload-cli/index.js'

alias t=todo.sh
alias todo=todo.sh
#alias df=dfc
alias youtube=mpsyt
alias y2mp3="youtube-dl --extract-audio --audio-format mp3"
alias y2mp4="youtube-dl -i -f mp4"
alias photo="sxiv"
alias foto="sxiv"
alias image="sxiv"
alias video="mpv"
alias play="mpv"

alias file2cb="xclip -sel c <"

alias week='date +%V'


alias reload-fstab='systemctl daemon-reload'

alias entpacke='unar -d'
# alias extract='unar -d' use extract zsh plugin

alias pdfmerge='pdfunite'
alias mergepdf='pdfunite'

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shortcuts
alias dl="cd ~/Downloads"
alias p="cd ~/projects"
alias g="git"
alias df="dfc"


# Fix ssh in kitty
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"


export PATH=~/.local/bin:$PATH


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# uncomment to measure statup time of plugins (also uncomment first line)
#zprof

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

eval $RUN_ZSH_CMD

export EDITOR=vim
   
export DEVKITPRO=/opt/devkitpro    
export DEVKITARM=/opt/devkitpro/devkitARM    
export DEVKITPPC=/opt/devkitpro/devkitPPC

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk


eval "$(starship init zsh)"
