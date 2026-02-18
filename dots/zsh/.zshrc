# Needed for powerlevel instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Completition insensitiveness
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"

# update automatically without asking every day
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 1

# Auto correct the inputed command
ENABLE_CORRECTION="true"

# History timestamp
HIST_STAMPS="yyyy-mm-dd %H:%M:%S"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Loading of Oh-my-zsh framework
source $ZSH/oh-my-zsh.sh

# Automatically source all *.zsh files in home folder
for file in $(find ~ -name ".*.zsh"); do
  source "$file"
done
