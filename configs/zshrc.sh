# ============================================================
# devops-terminal — zsh enhancements for SRE/DevOps/Platform engineers
# https://github.com/arkashira/devops-terminal
# Loaded from ~/.zshrc — ทุกส่วนมี guard ถ้าเครื่องไม่มี tool นั้นจะข้ามเอง
# ============================================================

# หา homebrew prefix แบบ dynamic (Apple Silicon = /opt/homebrew, Intel = /usr/local)
if [[ -n "$HOMEBREW_PREFIX" ]]; then BREW_PREFIX="$HOMEBREW_PREFIX"
elif [[ -d /opt/homebrew ]]; then BREW_PREFIX=/opt/homebrew
else BREW_PREFIX=/usr/local; fi

# ---------- nvm lazy-load (ถ้ามี nvm) ----------
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  _nvm_bins=("$NVM_DIR"/versions/node/*/bin(/Nn))
  [[ ${#_nvm_bins[@]} -gt 0 ]] && export PATH="${_nvm_bins[-1]}:$PATH"
  unset _nvm_bins
  nvm() { unfunction nvm; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; nvm "$@" }
fi

# ---------- AWS profile switching ----------
# saws — เลือก AWS profile จาก dropdown (fzf)
saws() {
  local profile profiles
  profiles=$(grep -hE '^\[' "$HOME/.aws/config" "$HOME/.aws/credentials" 2>/dev/null \
    | sed -E 's/^\[profile //; s/^\[//; s/\]$//' | sort -u)
  if [[ -z "$profiles" ]]; then
    echo "saws: no AWS profiles found in ~/.aws/config or ~/.aws/credentials" >&2
    return 1
  fi
  if command -v fzf >/dev/null 2>&1; then
    profile=$(echo "$profiles" | fzf --height=~40% --reverse \
      --prompt='AWS profile > ' --header="current: ${AWS_PROFILE:-none}")
  else
    echo "Select AWS profile (current: ${AWS_PROFILE:-none}):"
    select profile in ${(f)profiles}; do break; done
  fi
  [[ -z "$profile" ]] && return
  export AWS_PROFILE="$profile" AWS_DEFAULT_PROFILE="$profile"
  echo "Switched to AWS Profile: $profile"
}

# พิมชื่อ profile ตรงๆ เพื่อสลับได้เลย (เช่น พิม `myprofile`)
for profile in $(grep -hE '^\[' "$HOME/.aws/config" "$HOME/.aws/credentials" 2>/dev/null \
    | sed -E 's/^\[profile //; s/^\[//; s/\]$//' | sort -u); do
  alias "$profile"="export AWS_PROFILE=\"$profile\" AWS_DEFAULT_PROFILE=\"$profile\" && echo \"Switched to AWS Profile: $profile\""
done
unset profile
alias awsclear='unset AWS_PROFILE AWS_DEFAULT_PROFILE && echo "Cleared AWS Profile environment variables."'

# ---------- auto AWS profile ตามโฟลเดอร์ ----------
# ใส่ mapping ของคุณเอง: "path" profile  (ไม่ต้องวางไฟล์อะไรในโปรเจกต์)
typeset -gA AWS_DIR_PROFILES=(
  # "$HOME/work/project-a" profile-a
  # "$HOME/work/project-b" profile-b
)
typeset -g _AWS_DIR_PREV="" _AWS_DIR_ACTIVE=""
_aws_profile_by_dir() {
  local dir want=""
  for dir in ${(k)AWS_DIR_PROFILES}; do
    [[ "$PWD/" == "$dir/"* ]] && { want=$AWS_DIR_PROFILES[$dir]; break; }
  done
  if [[ -n "$want" ]]; then
    if [[ "$_AWS_DIR_ACTIVE" != "$want" ]]; then
      [[ -z "$_AWS_DIR_ACTIVE" ]] && _AWS_DIR_PREV="$AWS_PROFILE"
      _AWS_DIR_ACTIVE="$want"
      export AWS_PROFILE="$want" AWS_DEFAULT_PROFILE="$want"
    fi
  elif [[ -n "$_AWS_DIR_ACTIVE" ]]; then
    _AWS_DIR_ACTIVE=""
    if [[ -n "$_AWS_DIR_PREV" ]]; then
      export AWS_PROFILE="$_AWS_DIR_PREV" AWS_DEFAULT_PROFILE="$_AWS_DIR_PREV"
    else
      unset AWS_PROFILE AWS_DEFAULT_PROFILE
    fi
  fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd _aws_profile_by_dir
_aws_profile_by_dir

# ---------- fzf full integration ----------
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS='--height=~60% --layout=reverse --border --info=inline'
  export FZF_TMUX_OPTS='-p 80%,60%'
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    _fzf_compgen_path() { fd --hidden --follow --exclude .git . "$1" }
    _fzf_compgen_dir() { fd --type d --hidden --follow --exclude .git . "$1" }
  fi
  command -v bat >/dev/null 2>&1 && \
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  export FZF_ALT_C_OPTS="--preview 'ls -la {} | head -50'"
fi

# ---------- prompt / นำทาง / history ----------
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v atuin   >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"
command -v direnv  >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v navi    >/dev/null 2>&1 && eval "$(navi widget zsh)"

# ---------- modern CLI aliases ----------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto'
  alias ll='eza -la --icons=auto --git'
  alias la='eza -a --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
fi
command -v viddy >/dev/null 2>&1 && alias watch='viddy'
# krew — kubectl plugins
[[ -d "$HOME/.krew/bin" ]] && export PATH="$HOME/.krew/bin:$PATH"
# lazygit
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'
# yazi — ออกแล้ว cd ตาม dir ที่เปิดค้าง
if command -v yazi >/dev/null 2>&1; then
  y() { local tmp="$(mktemp)"; yazi --cwd-file="$tmp" "$@"; local d="$(cat "$tmp")"; rm -f "$tmp"; [[ -n $d && $d != $PWD ]] && cd "$d" }
fi
# granted — สลับ AWS SSO role (ต้อง source เลยเป็น alias)
command -v granted >/dev/null 2>&1 && alias assume='. assume'
if command -v kubecolor >/dev/null 2>&1; then
  alias kubectl='kubecolor'
  alias k='kubecolor'
fi
alias keys='glow -p ~/.devops-terminal/configs/terminal-cheatsheet.md'

# ---------- k8s fzf helpers ----------
_fzf_pick_pod() {
  command kubectl get pods --all-namespaces --no-headers 2>/dev/null \
    | fzf --height=~60% --reverse --prompt='pod > ' --header='NAMESPACE  POD' \
    | awk '{print $1, $2}'
}
fkl()  { local p=($(_fzf_pick_pod)); [[ -n "$p" ]] && command kubectl logs -f -n $p[1] $p[2] }
fke()  { local p=($(_fzf_pick_pod)); [[ -n "$p" ]] && command kubectl exec -it -n $p[1] $p[2] -- sh -c 'command -v bash >/dev/null && exec bash || exec sh' }
fkd()  { local p=($(_fzf_pick_pod)); [[ -n "$p" ]] && command kubectl describe pod -n $p[1] $p[2] | bat -l yaml }
fkpf() { local p=($(_fzf_pick_pod)); [[ -z "$p" ]] && return; local ports; read "ports?local:remote (e.g. 8080:80): "; command kubectl port-forward -n $p[1] $p[2] $ports }

# ---------- AI helpers (ต้องมี kiro-cli + login แล้ว) ----------
if command -v kiro-cli >/dev/null 2>&1; then
  # ask <คำถาม> — ถาม AI ตอบในจอ (read-only)
  ask() { kiro-cli chat --no-interactive --trust-tools= "$*" }
  # whyfail — ให้ AI อธิบายว่าคำสั่งล่าสุดพังเพราะอะไร
  whyfail() {
    local code=$?
    local last=$(fc -ln -2 -2 2>/dev/null)
    ask "This zsh command failed (exit code $code) on macOS: ${last} — explain the likely cause and fix, concisely"
  }
  # Alt+T — แปลงข้อความบนบรรทัดเป็นคำสั่งจริงด้วย AI
  _kiro_translate_widget() {
    [[ -z $BUFFER ]] && return
    BUFFER="kiro-cli translate ${(q)BUFFER}"
    zle accept-line
  }
  zle -N _kiro_translate_widget
  bindkey '^[t' _kiro_translate_widget
fi

# ---------- QoL widgets ----------
# Esc Esc = เติม/ถอด sudo หน้าคำสั่ง
_toggle_sudo() {
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
  if [[ $BUFFER == sudo\ * ]]; then LBUFFER="${LBUFFER#sudo }"
  else LBUFFER="sudo $LBUFFER"; fi
}
zle -N _toggle_sudo
bindkey '\e\e' _toggle_sudo

# Ctrl+Z = สลับเข้า/ออกโปรแกรมที่ suspend ไว้
_fancy_ctrl_z() {
  if [[ -z $BUFFER && -n $(jobs) ]]; then BUFFER='fg'; zle accept-line
  else zle push-input; fi
}
zle -N _fancy_ctrl_z
bindkey '^Z' _fancy_ctrl_z

# ---------- autocorrect ----------
setopt correct
CORRECT_IGNORE='[._]*'

# ---------- fzf-tab: Tab = dropdown เลือกด้วยลูกศร (ทุกคำสั่ง ทุก terminal รวม tmux) ----------
fpath=("$HOME/.zsh/completions" "$BREW_PREFIX/share/zsh/site-functions" $fpath)
autoload -Uz compinit
for _d in "$HOME"/.zcompdump(N.mh+24); do compinit; break; done
compinit -C
unset _d
autoload -Uz bashcompinit && bashcompinit
command -v aws_completer >/dev/null 2>&1 && complete -C aws_completer aws
command -v terraform >/dev/null 2>&1 && complete -o nospace -C terraform terraform
if [[ -f "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"
  zstyle ':completion:*' menu no
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':fzf-tab:*' fzf-flags --height=~60%
  # กด / เจาะเข้าโฟลเดอร์ชั้นถัดไปต่อเลย
  zstyle ':fzf-tab:*' continuous-trigger '/'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=auto --color=always $realpath 2>/dev/null'
  # ใน tmux เด้งเป็น popup กลางจอ
  [[ -n $TMUX ]] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi

# ---------- suggestions + syntax highlighting (ต้องอยู่ท้ายสุด) ----------
[[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
