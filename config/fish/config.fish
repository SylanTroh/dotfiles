fish_add_path -g ~/.local/bin

if type -q pyenv
    pyenv init - fish | source
    pyenv virtualenv-init - fish | source
end

for f in ~/.config/fish/functions/local-*.fish
    source $f
end
