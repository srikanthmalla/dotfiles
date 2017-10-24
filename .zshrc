alias download_music="sudo youtube-dl --no-check-certificate --extract-audio --audio-format mp3 "
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"

plugins=(git)
plugins=(zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh
source ~/dotfiles/keybindings.sh

