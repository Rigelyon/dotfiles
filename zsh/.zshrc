
## --- 1. Environment & Path ---
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH" 
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux64/bin"

export "MICRO_TRUECOLOR=1"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

## --- 2. Oh-My-Zsh ---
export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=( 
    git
    dnf
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

## --- 3. History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

## --- 4. Completion Styling ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

## --- 5. Tool Initializations ---
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"
. "$HOME/.local/share/../bin/env"

# fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

## --- 6. Aliases ---
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
# alias cat='bat'
alias curl='curlie'
alias ssh='kitty +kitten ssh'

alias mc='micro'
alias edit='micro'
alias py='python3'
alias sp='thoth'
alias note=''
alias fetch='fastfetch'

alias ttyclock='tty-clock -B -C 6'
alias zoom='QT_QUICK_CONTROLS_STYLE=Basic zoom'

alias lk='lk --icons'
alias lf='lk --icons --fuzzy'

alias lzp='DOCKER_HOST=unix://$(podman info -f "{{.Host.RemoteSocket.Path}}") lazydocker'
alias spotx-install='bash <(curl -sSL https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/main/spotx.sh)'
alias start-ssh='sudo mkdir -p /run/sshd && sudo /usr/sbin/sshd -p 2424'

## --- 7. Functions ---
# Walk dir exit
function lk {
  cd "$(walk "$@")"
}

# Yazi dir exit
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Warp toggle switch
warp() {
    if [ "$1" = "toggle" ]; then
        warp-cli status | grep -q "Connected" && (warp-cli disconnect && echo "Changed to disconnected") || (warp-cli connect && echo "Changed to connected")
    else
        warp-cli status
    fi
}

## --- 8. Transient Prompt Hooks ---
autoload -Uz add-zsh-hook
add-zsh-hook precmd transient-prompt-precmd

TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"
TRANSIENT_RPROMPT="${PROMPT// prompt / prompt --profile rtransient }"

function transient-prompt-precmd {
    TRAPINT() { transient-prompt; return $(( 128 + $1 )) }
    SAVED_PROMPT="$(eval "printf '%s' \"${TRANSIENT_PROMPT}\"")"
    SAVED_RPROMPT="$(eval "printf '%s' \"${TRANSIENT_RPROMPT}\"")"
}

autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-finish transient-prompt

function transient-prompt() {
    PROMPT="$SAVED_PROMPT" RPROMPT="$SAVED_RPROMPT" zle .reset-prompt
}


# Added by Antigravity CLI installer
export PATH="/home/rigelyon/.local/bin:$PATH"

# pnpm
export PNPM_HOME="/home/rigelyon/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# opencode
export PATH=/home/rigelyon/.opencode/bin:$PATH
