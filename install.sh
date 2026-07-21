#!/usr/bin/env bash
# devops-terminal — one-shot terminal setup for SRE/DevOps/Platform engineers (macOS)
# install:  bash -c "$(curl -fsSL https://raw.githubusercontent.com/arkashira/devops-terminal/main/install.sh)"
# รันซ้ำได้ (idempotent) — ใช้ update ได้ด้วย
set -euo pipefail

REPO_URL="https://github.com/arkashira/devops-terminal.git"
INSTALL_DIR="$HOME/.devops-terminal"

log()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m ✓\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m !\033[0m %s\n" "$*"; }

[[ "$(uname)" == "Darwin" ]] || { echo "รองรับ macOS เท่านั้น (ตอนนี้)"; exit 1; }

# ---------- Homebrew ----------
if ! command -v brew >/dev/null 2>&1; then
  log "ติดตั้ง Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# ---------- clone / update ตัว repo ----------
if [[ -d "$INSTALL_DIR/.git" ]]; then
  log "อัปเดต devops-terminal..."
  git -C "$INSTALL_DIR" pull --ff-only || warn "pull ไม่สำเร็จ ใช้เวอร์ชันเดิมต่อ"
else
  log "ดาวน์โหลด devops-terminal..."
  git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

# ---------- packages ----------
log "ติดตั้ง packages (ข้ามตัวที่มีแล้ว)..."
FORMULAS=(fzf fd bat eza zoxide atuin starship zsh-autosuggestions zsh-syntax-highlighting
  tmux kubectx k9s stern kubecolor viddy yq jq direnv trivy terraform-docs navi glow)
for f in "${FORMULAS[@]}"; do
  brew list "$f" >/dev/null 2>&1 || brew install "$f"
done
CASKS=(ghostty font-jetbrains-mono-nerd-font)
for c in "${CASKS[@]}"; do
  brew list --cask "$c" >/dev/null 2>&1 || brew install --cask "$c" || warn "ติดตั้ง $c ไม่สำเร็จ (อาจมีอยู่แล้ว)"
done
ok "packages พร้อม"

# ---------- tmux plugins ----------
[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
[[ -d "$HOME/.tmux/kube-tmux" ]]   || git clone --depth 1 https://github.com/jonmosco/kube-tmux "$HOME/.tmux/kube-tmux"

# ---------- link configs (ของเดิมถูก backup เป็น *.pre-devops-terminal) ----------
backup_link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "$dst.pre-devops-terminal"
    warn "backup ของเดิม: $dst.pre-devops-terminal"
  fi
  ln -sfn "$src" "$dst"
}
log "วาง config files..."
backup_link "$INSTALL_DIR/configs/tmux.conf"        "$HOME/.tmux.conf"
backup_link "$INSTALL_DIR/configs/starship.toml"    "$HOME/.config/starship.toml"
backup_link "$INSTALL_DIR/configs/ghostty-config"   "$HOME/.config/ghostty/config"
backup_link "$INSTALL_DIR/shaders/cursor-trail.glsl" "$HOME/.config/ghostty/shaders/cursor-trail.glsl"

CHEAT_DIR="$(navi info cheats-path 2>/dev/null || echo "$HOME/.local/share/navi/cheats")"
mkdir -p "$CHEAT_DIR"
ln -sfn "$INSTALL_DIR/configs/devops.cheat" "$CHEAT_DIR/devops.cheat"
ok "configs พร้อม"

# ---------- zshrc hook ----------
MARKER="# >>> devops-terminal >>>"
if ! grep -qF "$MARKER" "$HOME/.zshrc" 2>/dev/null; then
  log "เพิ่ม hook ใน ~/.zshrc..."
  {
    echo ""
    echo "$MARKER"
    echo "source \"\$HOME/.devops-terminal/configs/zshrc.sh\""
    echo "# <<< devops-terminal <<<"
  } >> "$HOME/.zshrc"
  ok "เพิ่มแล้ว (ของเดิมใน .zshrc ไม่ถูกแตะ)"
else
  ok "hook ใน ~/.zshrc มีอยู่แล้ว"
fi

# ---------- tmux plugins install ----------
log "ติดตั้ง tmux plugins..."
"$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true

# ---------- patch tmux-resurrect (tmux >= 3.7 แทน control chars ด้วย _ ทำ save พัง) ----------
SAVE_SH="$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh"
if [[ -f "$SAVE_SH" ]] && ! grep -q '@=@' "$SAVE_SH"; then
  log "apply patch tmux-resurrect (บั๊ก tmux 3.7)..."
  if git -C "$HOME/.tmux/plugins/tmux-resurrect" apply "$INSTALL_DIR/patches/resurrect-tmux37.patch" 2>/dev/null; then
    ok "patch สำเร็จ"
  else
    warn "patch ไม่เข้า (upstream อาจแก้แล้ว หรือโค้ดเปลี่ยน) — ข้าม"
  fi
fi

# ---------- atuin: import history เดิม ----------
command -v atuin >/dev/null 2>&1 && atuin import auto >/dev/null 2>&1 || true

# ---------- optional: Kiro CLI MCP (ถ้ามี kiro-cli) ----------
if command -v kiro-cli >/dev/null 2>&1; then
  kiro-cli mcp add --name aws-knowledge --url "https://knowledge-mcp.global.api.aws" --scope global >/dev/null 2>&1 || true
  ok "เพิ่ม aws-knowledge MCP ให้ kiro-cli แล้ว"
fi

echo ""
printf "\033[1;32m🎉 devops-terminal ติดตั้งเสร็จ!\033[0m\n"
echo ""
echo "ขั้นต่อไป:"
echo "  1. เปิด terminal ใหม่ (หรือ source ~/.zshrc)"
echo "  2. พิม 'keys' ดู cheat sheet ปุ่มลัดทั้งหมด"
echo "  3. เปิดแอป Ghostty (แนะนำใช้เป็น terminal หลัก) — กด Cmd+\` จากแอปไหนก็ได้ = Quick Terminal"
echo "  4. (แนะนำ) AI ใน terminal: ติดตั้ง Kiro CLI (aws.amazon.com/q/developer/) แล้ว kiro-cli login"
echo "     เสร็จแล้วรัน kiro-cli integrations install dotfiles && kiro-cli inline disable"
echo "  5. auto AWS profile ตามโฟลเดอร์: แก้ AWS_DIR_PROFILES ใน ~/.devops-terminal/configs/zshrc.sh"
echo ""
