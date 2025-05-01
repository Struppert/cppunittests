FROM archlinux:latest

# Argumente für Benutzerrechte und GitHub Token
ARG HOST_UID=1000
ARG HOST_GID=1000
ARG GITHUB_TOKEN

# Systemaktualisierung und Installation von Basis-Paketen (inkl. cppcheck)
RUN pacman -Syyu --noconfirm && \
  pacman -S --noconfirm base-devel git sudo curl openssh cppcheck && \

  # Benutzer "vscode" anlegen und Rechte setzen
  useradd -m vscode && \
  echo "vscode ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vscode && \
  echo "vscode:password" | chpasswd && \
  groupmod -g ${HOST_GID} vscode && \
  usermod -u ${HOST_UID} -g ${HOST_GID} vscode && \

  # gosu installieren
  curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.16/gosu-amd64" && \
  chmod +x /usr/local/bin/gosu


# 📦 als vscode: Mirror fixen & paru installieren
USER vscode
WORKDIR /home/vscode

RUN sudo sed -i '1i Server = https://mirror.netcologne.de/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist && \
  git clone https://aur.archlinux.org/paru.git && \
  cd paru && makepkg -si --noconfirm && \
  cd .. && rm -rf paru

# 📦 Pakete installieren mit Retry
RUN paru -Syu --noconfirm --skipreview \
  clang gcc ccache gperftools luarocks nodejs python rust boost \
  cmake conan vcpkg ninja gdb valgrind rust-analyzer-git \
  python-pip npm fish github-cli github-copilot-cli \
  ast-grep bat btop exa fd fzf lazygit ripgrep starship tokei unzip viu wget xclip xsel wl-clipboard zoxide \
  bash-completion fish zellij \
  ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd zig-nightly-bin \
  neovim-nightly \
  chafa imagemagick ueberzugpp yazi \
  rm -rf ~/.cache/paru

# 📦 Python-Tools (per pip)
RUN pip install --break-system-packages --no-cache-dir \
  pynvim black isort flake8 lizard radon vulture pylint

# 📎 clangd Link setzen
RUN sudo ln -sf /usr/bin/clangd /usr/local/bin/clangd

# 🔐 Root: SSH vorbereiten
USER root
RUN rm -f /etc/ssh/ssh_host_* && ssh-keygen -A && \
  systemctl enable sshd && \
  mkdir -p /run/systemd && chmod 0755 /run/systemd && \
  systemd-machine-id-setup && \
  cp /usr/lib/os-release /etc/os-release && \
  ln -sf /dev/null /etc/systemd/system/proc-sys-fs-binfmt_misc.automount && \
  ln -sf /dev/null /etc/systemd/system/sys-kernel-debug.mount && \
  ln -sf /dev/null /etc/systemd/system/sys-kernel-tracing.mount && \
  ln -sf /dev/null /etc/systemd/system/sys-kernel-config.mount && \
  pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/*

# 🧠 Benutzer zurück für Config-Zeug
USER vscode
WORKDIR /workspace
RUN git clone --branch devcontainer https://github.com/Struppert/nvim ~/.config/nvim

# dieser Block versucht die Plugins zur containerzeit zu installieren. Es scheitert aber wegen den Rueckfragen von 
# Codeium und Copilot; hier wird dann eine Bedingung zum verzweigen benoetigt.
#RUN git clone --branch devcontainer https://${GITHUB_TOKEN}@github.com/Struppert/nvim ~/.config/nvim && \
#  chown -R vscode:vscode ~/.config/nvim && \
#  nvim --headless "+Lazy! sync" +qa \
#  nvim --headless "+MasonInstallAll" +qa

RUN mkdir -p /home/vscode/.config/fish

USER root
COPY --chown=vscode:vscode .devcontainer/starship.toml /home/vscode/.config/starship.toml

# Fish-Konfiguration kopieren
COPY --chown=vscode:vscode .devcontainer/config.fish /home/vscode/.config/fish/config.fish

# 🛠 Shell-Init + Aliase
RUN mkdir -p /home/vscode/.config && \
  echo 'eval "$(starship init bash)"' >> /home/vscode/.bashrc && \
  echo '[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion' >> /home/vscode/.bashrc && \
  echo 'eval "$(zoxide init bash)"' >> /home/vscode/.bashrc && \
  echo 'export WAYLAND_DISPLAY=/run/wayland-0' >> /home/vscode/.bashrc && \
  echo '' >> /home/vscode/.bashrc && \
  echo '# exa aliases' >> /home/vscode/.bashrc && \
  echo 'alias ls="exa"' >> /home/vscode/.bashrc && \
  echo 'alias ll="exa -lh --icons"' >> /home/vscode/.bashrc && \
  echo 'alias la="exa -lha --icons"' >> /home/vscode/.bashrc && \
  echo 'alias lt="exa -T --icons"' >> /home/vscode/.bashrc && \
  echo 'alias lsd="exa -lh --sort=modified --icons"' >> /home/vscode/.bashrc && \
  echo 'alias ldirs="exa -lh --group-directories-first --icons | grep \"^d\""' >> /home/vscode/.bashrc && \
  echo 'alias llong="exa -l --git --group-directories-first --icons"' >> /home/vscode/.bashrc && \
  echo 'alias ltree="exa -T -L 2 --icons"' >> /home/vscode/.bashrc && \
  echo 'alias ..="cd .."' >> /home/vscode/.bashrc && \
  echo 'alias ...="cd ../.."' >> /home/vscode/.bashrc && \
  echo 'alias ....="cd ../../.."' >> /home/vscode/.bashrc && \
  echo '' >> /home/vscode/.bashrc && \
  echo '# yazi: file manager with cd on quit' >> /home/vscode/.bashrc && \
  echo 'function y() {' >> /home/vscode/.bashrc && \
  echo '  local tmp="$(mktemp)"' >> /home/vscode/.bashrc && \
  echo '  yazi "$@" --cwd-file="$tmp"' >> /home/vscode/.bashrc && \
  echo '  if [ -f "$tmp" ]; then' >> /home/vscode/.bashrc && \
  echo '    local dir=$(cat "$tmp")' >> /home/vscode/.bashrc && \
  echo '    rm -f "$tmp"' >> /home/vscode/.bashrc && \
  echo '    if [ -d "$dir" ]; then cd "$dir"; fi' >> /home/vscode/.bashrc && \
  echo '  fi' >> /home/vscode/.bashrc && \
  echo '}' >> /home/vscode/.bashrc && \
  echo '' >> /home/vscode/.bashrc && \
  echo '# rg aliases for C++ & Python' >> /home/vscode/.bashrc && \
  echo 'alias rg="rg --color=always --heading --line-number"' >> /home/vscode/.bashrc && \
  echo 'alias rgpy="rg --type py"' >> /home/vscode/.bashrc && \
  echo 'alias rgcpp="rg -g \"*.cpp\" -g \"*.hpp\" -g \"*.h\" -g \"*.cc\""' >> /home/vscode/.bashrc && \
  echo 'alias rgtodo="rg -i \"TODO|FIXME\" --type py --type cpp"' >> /home/vscode/.bashrc

# Fish zur Liste der gültigen Shells hinzufügen
RUN echo "/usr/bin/fish" >> /etc/shells

# Standardshell für den Benutzer vscode auf Fish setzen
RUN chsh -s /usr/bin/fish vscode

# Entrypoint-Skript hinzufügen und ausführbar machen
COPY .devcontainer/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Standard Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/lib/systemd/systemd"]
