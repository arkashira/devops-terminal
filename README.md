# devops-terminal

Terminal setup ครบเซ็ตสำหรับ **SRE / DevOps / DevSecOps / Platform / Cloud Engineer** (macOS) — ติดตั้งจบในคำสั่งเดียว เร็ว ไม่หน่วง (shell startup ~0.07s) รวมเครื่องมือ 50+ ตัวที่จูนให้ทำงานร่วมกันแล้ว

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/arkashira/devops-terminal/main/install.sh)"
```

- รันซ้ำได้ตลอด = อัปเดตตัวเอง (idempotent)
- ของเดิมใน `~/.zshrc` ไม่ถูกแตะ — เพิ่ม `source` แค่บรรทัดเดียว
- config เดิมถูก backup เป็น `*.pre-devops-terminal` ก่อนเสมอ
- ทุก feature มี guard: เครื่องไหนไม่มี tool ตัวไหน ส่วนนั้นข้ามเอง ไม่พัง

---

## ✨ Features

| หมวด | ได้อะไร |
|---|---|
| 🔍 **fzf ทุกจุดสัมผัส** | `Tab` = dropdown เลือกด้วยลูกศรทุกคำสั่ง (fzf-tab + completion จริงของ kubectl/helm/aws/terraform/stern/gh), history, ไฟล์, โฟลเดอร์, snippets |
| ☸️ **Kubernetes** | k9s, stern, kubectx/kubens, kubecolor, krew (+neat/tree/node-shell), kubent, popeye, helm, kustomize, argocd, ฟังก์ชัน fzf เลือก pod |
| ☁️ **Cloud/AWS** | `saws` สลับ profile, auto-switch profile ตามโฟลเดอร์, granted (SSO multi-account), eksctl, session-manager-plugin, steampipe (SQL over AWS), infracost |
| 🛡 **DevSecOps** | trivy (image/IaC/secret scan), sops+age (secret ใน git), terraform-docs, tflint-ระดับ trivy config |
| 🖥 **tmux** | resurrect+continuum (session อมตะ), extrakto, sync panes, k9s/AI popup, sesh (session สำเร็จรูป), tmux-fzf, fzf-url + **patch บั๊ก tmux 3.7×resurrect อัตโนมัติ** |
| 👻 **Ghostty** | Quick Terminal (global hotkey), prompt jump แบบ Warp blocks, OSC52, paste protection, scrollback 50MB, จำ window ข้าม restart, cursor trail shader |
| 🤖 **AI (optional)** | Kiro CLI: dropdown autocomplete, `ask`, `whyfail`, `Alt+T` แปลภาษาคนเป็นคำสั่ง, chat + MCP (aws-knowledge, kubernetes) |
| 🔬 **Debug/Incident** | lnav, fx, jless, xh, trippy, gping, doggo, hyperfine, watchexec, btop |
| ⚡ **QoL** | starship (git/k8s/aws context), autosuggestions, syntax highlighting, autocorrect, zoxide, atuin, eza, bat, fd, lazygit+delta, yazi, ntfy (แจ้งมือถือ), mise, just |

---

## ⌨️ Keybindings & Commands ทั้งหมด

### Quick wins
| ปุ่ม/คำสั่ง | ทำอะไร |
|---|---|
| `Tab` | **fzf-tab dropdown** — เลือกด้วยลูกศร+พิมกรอง ทุกคำสั่ง กด `/` เจาะโฟลเดอร์ต่อ มี preview |
| `Esc Esc` | เติม/ถอด `sudo` (บรรทัดว่าง = หยิบคำสั่งก่อนหน้า) |
| `Ctrl+Z` | สลับเข้า/ออกโปรแกรมที่พักไว้ (vim/k9s) |
| `→` / `Ctrl+E` / `Alt+F` | รับ ghost text ทั้งหมด / ทีละคำ |
| พิมคำสั่งผิด | autocorrect ถาม `correct 'kubctl' to 'kubectl'?` |
| `keys` | เปิด cheat sheet |
| `nt <คำสั่ง>` | รันเสร็จแจ้งเข้ามือถือผ่าน ntfy (`nt terraform apply`) |

### ค้นหา / นำทาง
| ปุ่ม | ทำอะไร |
|---|---|
| `Ctrl+R` | ค้น history (atuin — กรองตาม dir/exit code) |
| `Ctrl+T` | ค้นไฟล์ + preview |
| `Alt+C` | fuzzy cd |
| `Ctrl+G` | navi — คลัง snippet devops (aws/k8s/tf/trivy) |
| `z <คำ>` / `zi` | zoxide — เด้งไป dir ที่ไปบ่อย |
| `y` | yazi file manager — ออกแล้ว cd ตาม |

### Kubernetes / Cloud
| คำสั่ง | ทำอะไร |
|---|---|
| `saws` | สลับ AWS profile (fzf dropdown) |
| `kubectx` / `kubens` | สลับ cluster / namespace |
| `fkl` / `fke` / `fkd` / `fkpf` | fzf เลือก pod → logs / shell / describe / port-forward |
| `stern <pattern> -n <ns>` | tail log หลาย pod พร้อมกัน |
| `k` | kubectl มีสี (kubecolor) |
| `watch kubectl get pods` | viddy — ไฮไลท์ diff |
| `kubectl neat / tree / node-shell` | ล้าง yaml / ownership tree / shell เข้า node |
| `kubent` | สแกน deprecated API ก่อนอัปเกรด cluster |
| `popeye` | ตรวจสุขภาพ cluster + ให้เกรด |
| `assume` | granted — สลับ AWS SSO role (token ใน keychain ต่ออายุเอง) |
| `aws ssm start-session --target <id>` | เข้า EC2 ไม่ต้อง SSH/bastion |
| `steampipe query "select ..."` | query AWS ด้วย SQL |
| `infracost breakdown --path .` | terraform นี้กี่บาท/เดือน |

### tmux (prefix = `Ctrl+b`)
| ปุ่ม | ทำอะไร |
|---|---|
| `prefix Tab` | extrakto — หยิบ token จากจอ (pod/IP/hash) |
| `prefix s` | sesh — สลับ/สร้าง session สำเร็จรูป (fzf) |
| `prefix i` / `prefix k` / `prefix t` | popup: AI chat / k9s / scratch shell |
| `prefix S` | sync panes (มี ⚠ SYNC เตือน) |
| `prefix F` / `prefix u` | เมนูจัดการทุกอย่าง / เปิด URL บนจอ |
| `prefix \|` / `prefix -` | split แนวตั้ง / แนวนอน |
| `Alt+ลูกศร` / `Shift+←→` | ย้าย pane / สลับ window (ไม่ต้อง prefix) |
| `prefix [` แล้ว `v`,`y` | copy แบบ vim เข้า clipboard |
| `prefix Ctrl+s` / `Ctrl+r` | save / restore session (autosave 15 นาที) |
| `prefix I` / `prefix r` | ติดตั้ง plugins / reload config |

### Ghostty
| ปุ่ม | ทำอะไร |
|---|---|
| `` Cmd+` `` (จากแอปไหนก็ได้) | Quick Terminal หล่นจากขอบบน |
| `Cmd+↑/↓` | กระโดดระหว่าง prompt (Warp blocks) |
| `Cmd+D` / `Cmd+Shift+D` / `Cmd+Alt+ลูกศร` / `Cmd+Shift+Enter` | split ขวา/ล่าง/ย้าย/zoom |
| `Cmd+Shift+J` | เท scrollback ลงไฟล์เปิดดู |
| `Shift+Enter` | ขึ้นบรรทัดใหม่ไม่ส่งคำสั่ง (AI chat) |

### Git / Docker / Debug
| คำสั่ง | ทำอะไร |
|---|---|
| `lg` | lazygit — git TUI ครบจบ |
| `git diff` | delta — diff สวย กด `n`/`N` ข้ามไฟล์ |
| `lazydocker` / `dive <image>` / `btop` | docker TUI / ส่องชั้น image / monitor |
| `lnav <dir>` | log หลายไฟล์ merge ตามเวลา + query SQL |
| `fx` / `jless` | ส่อง JSON โต้ตอบ / pager |
| `xh get <url>` | curl ยุคใหม่ |
| `trippy <host>` / `gping` / `doggo` | network TUI |
| `hyperfine 'cmd'` | benchmark |
| `watchexec -e tf 'terraform validate'` | รันซ้ำเมื่อไฟล์เปลี่ยน |
| `trivy image/config/fs` | สแกน vuln / misconfig / secret |
| `sops -e secrets.yaml` | เข้ารหัส secret เก็บใน git |

### AI (Kiro CLI)
| คำสั่ง | ทำอะไร |
|---|---|
| `ask <คำถาม>` | ถาม AI ในจอ (read-only) |
| `whyfail` | AI อธิบายว่าคำสั่งเมื่อกี้พังเพราะอะไร |
| `Alt+T` | แปลงข้อความบนบรรทัดเป็นคำสั่งจริง |
| `kiro-cli chat` | AI agent + MCP (aws-knowledge, kubernetes) |
| พิม `aws` / `git` / `kubectl` | dropdown autocomplete เด้งเอง |

---

## 🔧 Setup เพิ่มเติม (optional)

**AI (Kiro CLI)** — ฟรีด้วย AWS Builder ID:
```sh
brew install --cask kiro-cli
kiro-cli login
kiro-cli integrations install dotfiles input-method
```

**ntfy แจ้งเข้ามือถือ** — ลงแอป ntfy (iOS/Android) → subscribe topic ลับของคุณ → ใน `~/.zshrc`:
```sh
export NTFY_TOPIC="my-secret-topic-xxxx"
```

**granted (AWS SSO)** — `granted sso populate --sso-start-url https://<org>.awsapps.com/start --sso-region <region>` แล้วใช้ `assume`

**atuin sync ข้ามเครื่อง** — `atuin register -u <user> -e <email>` แล้ว `atuin sync` (เข้ารหัส E2E, key อยู่ที่ `~/.local/share/atuin/key` — เก็บให้ดี)

**sesh session สำเร็จรูป** — สร้าง `~/.config/sesh/sesh.toml`:
```toml
[[session]]
name = "ops"
path = "~/work"
startup_command = "k9s"
```

**auto AWS profile ตามโฟลเดอร์** — แก้ `AWS_DIR_PROFILES` ใน `~/.devops-terminal/configs/zshrc.sh`

---

## ⚠️ Known issues + วิธีแก้

- **tmux 3.7 ทำ resurrect พัง** ("Tmux resurrect file not found!" ตลอด) — tmux 3.7 แทน control chars ใน format ด้วย `_` → installer นี้ apply patch ให้อัตโนมัติ ถ้า update plugin แล้วพัง รัน install.sh ซ้ำ
- **Kiro dropdown โชว์แต่กดเลือกไม่ได้** หลังแอป self-update — สิทธิ์ macOS ค้างกับไบนารีเก่า: System Settings → Privacy & Security → Accessibility และ Input Monitoring → **ลบ Kiro CLI ออก (−) แล้วเพิ่มใหม่ (+)** (toggle เฉยๆ ไม่พอ) → restart แอป
- **ไอคอนเป็น `?`** — terminal ยังไม่ใช้ Nerd Font: Ghostty จัดให้แล้ว / Terminal.app หรือ VS Code/Cursor ตั้ง font เป็น `JetBrainsMono Nerd Font Mono`

## 📁 โครงสร้าง

```
install.sh                      # ตัวติดตั้ง (idempotent — รันซ้ำ = update)
configs/zshrc.sh                # zsh enhancements ทั้งหมด (source จาก ~/.zshrc)
configs/tmux.conf               # tmux + plugins + ops keybinds
configs/ghostty-config          # Ghostty ฉบับเต็ม
configs/starship.toml           # prompt (git/k8s/aws/tf context)
configs/devops.cheat            # navi snippets (Ctrl+G)
configs/terminal-cheatsheet.md  # เปิดด้วยคำสั่ง `keys`
shaders/cursor-trail.glsl       # Ghostty cursor effect
patches/resurrect-tmux37.patch  # fix บั๊ก tmux 3.7 × resurrect
```
