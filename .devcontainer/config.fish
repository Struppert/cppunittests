# ~/.config/fish/config.fish

# 🛠 Prompt & Tools initialisieren
starship init fish | source
zoxide init fish | source

# 🧭 PATH erweitern
set -gx VCPKG_ROOT $HOME/vcpkg
set -gx PATH $VCPKG_ROOT $HOME/bin/nvim/bin $PATH

# 🔐 GitHub Token
set -gx GITHUB_TOKEN asdfghjk

# 📝 Editor
set -gx EDITOR nvim

# 📁 eza-Aliase (wenn verfügbar)
if type -q eza
    abbr -a ls eza
    abbr -a ll 'eza -lh --icons'
    abbr -a la 'eza -lha --icons'
    abbr -a lt 'eza -T --icons'
    abbr -a lsd 'eza -lh --sort=modified --icons'
    abbr -a ldirs 'eza -lh --group-directories-first --icons | grep "^d"'
    abbr -a llong 'eza -l --git --group-directories-first --icons'
    abbr -a ltree 'eza -T -L 2 --icons'
else
    abbr -a ls 'ls --color=auto'
    abbr -a ll 'ls -lhA'
end

# 🔍 rg-Aliase
abbr -a rg 'rg --color=always --heading --line-number'
abbr -a rgpy 'rg --type py'
abbr -a rgcpp 'rg -g "*.cpp" -g "*.hpp" -g "*.h" -g "*.cc"'
abbr -a rgtodo 'rg -i "TODO|FIXME" --type py --type cpp'

# 📂 fzf + nvim
function ff
    rg --files | fzf | read -l file && nvim "$file"
end

function fzfgrep
    rg --column --line-number . | fzf | awk -F: '{print $1":"$2}' | read -l file && nvim "$file"
end

# 🧭 Schnellnavigation
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'

# 📝 nvim-Aliase
abbr -a vi nvim
abbr -a svi 'sudo nvim'
abbr -a vis 'nvim "+set si"'
abbr -a edit nvim

# 🐙 Git-Aliase
abbr -a gs 'git status'
abbr -a gc 'git commit'
abbr -a ga 'git add .'
abbr -a gco 'git checkout'
abbr -a gl 'git log --oneline --graph --decorate'
abbr -a gb 'git branch -v'
abbr -a gpr 'git pull --rebase'

# 🐤 yazi-Funktion: Verzeichniswechsel nach Beenden
function y
    set tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi --cwd-file="$tmp"
    if test -f "$tmp"
        set dir (cat "$tmp")
        rm -f "$tmp"
        if test -d "$dir" -a "$dir" != "$PWD"
            cd "$dir"
        end
    end
end

# 🐚 Begrüßung deaktivieren
set fish_greeting ""
