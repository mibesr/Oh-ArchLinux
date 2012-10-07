# Zsh configuration
# Author: 辻堂アカリ (chiey.qs@gmail.com)
# Date: 2012-10-02

# Base:
export ZSH=$HOME/.zsh
export XMODIFIERS="@im=ibus"
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export LANG=ja_JP.UTF-8

# Auto complete:
autoload -U compinit
compinit

# Color prompt:
autoload -U promptinit
promptinit
#prompt adam2 8bit
e_normal=`echo -e "\033[0;30m"`
e_RED=`echo -e "\033[1;30m"`
e_BLUE=`echo -e "\033[1;36m"`

# KEY binding:
## Command Line stack <Esc-q>
bindkey -e
#bindkey -a 'q' push-line
bindkey "\e[3~" delete-char
zle -N sudo-cmd-line
bindkey "\e\e" sudo-cmd-line

# Options:
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=51200
export SAVEHIST=51200
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt AUTO_LIST
setopt AUTO_MENU
setopt MENU_COMPLETE
export EDITOR="vim"
export BROWSER="firefox"
eval `dircolors -b`
setopt autocd
setopt auto_pushd	# Automictically pushd dir on distack
setopt pushd_ignore_dups
setopt hist_ignore_all_dups
setopt extendedglob
setopt complete_in_word	# Extended path
setopt auto_param_slash	# ディレクトリ名の末の/を自動に書く
setopt nolistbeep
setopt list_packed
setopt list_types
setopt magic_equal_subst	# --prefix=/usr ...
setopt auto_param_keys
setopt brace_ccl	# expand {a-c}
setopt noautoremoveslash
setopt hist_reduce_blanks
setopt inc_append_history
setopt hist_no_store

# back-wordでの単語境界の設定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars "_-./;@"
zstyle ':zle:*' word-style unspecified

# Zstyle:
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin/ /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors di=34 fi=0
#zstyle ':completion:*' list-colors \
	#	'di=;36;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
#zmodload zsh/complist
#export ZLSCOLORS="${LS_COLORS}"
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:-tilde-:*' group-order 'name-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*:descriptions' format $'\e[33m%B-%d%u-%b\e[0m'
zstyle ':completion:*:warnings' format '%B%dには見つかりません.%b'
zstyle ':completion:*.*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*:processes' list=colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au $USER'
setopt completealiases
setopt correct
setopt correct_all
## More style:
##zstyle ':completion:*' expand 'yes'
##zstyle ':completion:*' squeeze-shlashes 'yes'
##zstyle ':completion::complete:*' '\\'

# Default shell configuration
# colors enables us to idenfity color by $fg[red]

# Prompt:
PROMPT='%{%f%k%b%}
%{%K{black}%B%F{green}%}%n%{%B%F{blue}%}@%{%B%F{cyan}%}%m%{%B%F{green}%} %{%b%F{yellow}%K{black}%}%~%{%B%F{green}%}%E%{%f%k%b%}
%{%K{black}%} %#%{%f%k%b%} '
RPROMPT='%{%B%F{cyan}%}%T%{%f%k%b%}'

# Alias:
alias zshconf='vim $HOME/.zshrc'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -hl'
alias la='ls -ahl'
alias l='ls -CF'
alias snetstat='netstat -tunp | grep 'EST''
alias nb='bash /home/QDJ/activedProg.sh'

# Misc:
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# Function:
sudo-cmd-line()
{
	[[ -z $BUFFER ]] && zle up-history
	[[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
	zle end-of-line
}
