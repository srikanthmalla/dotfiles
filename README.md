# dotfiles
clone the repo to $HOME

``git clone https://github.com/srikanthmalla/dotfiles ~/``

clone oh-my-zsh

``git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh``

edit ~/.zshrc as below

``source ~/dotfiles/.zshrc``

If you are using zshell for first time, change shell from bash to zsh

``chsh -s /bin/zsh``

edit ~/.vimrc as below

``source ~/dotfiles/.vimrc``

Zsh-autoSuggestions plugin:

``git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions``

to change suggested color to light-blue (you can edit this file):

``cp ~/dotfiles/zsh-autosuggestions-config.zsh ~/.oh-my-zsh/custom/zsh-autosuggestions-config.zsh``

Also, you can edit keybindings.sh, depending on your need (ctrl+g git auto add+commit+push)
