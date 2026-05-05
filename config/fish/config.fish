
# Created by `pipx` on 2025-04-23 06:45:07
set PATH $PATH /home/breeze/.local/bin

pyenv init - fish | source

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/breeze/.lmstudio/bin
# End of LM Studio CLI section


# llama-conf
set -gx PATH "$HOME/Projects/llama-conf:$PATH"

# Source fish integration
source "$HOME/Projects/llama-conf/fish-conf.d/llama-conf.fish"

# Source local (non-git-tracked) functions
for f in ~/.config/fish/functions/local-*.fish
    source $f
end
