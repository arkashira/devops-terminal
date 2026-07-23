# devops-terminal

Terminal setup ครบเซ็ตสำหรับ SRE / DevOps / DevSecOps / Platform Engineer (macOS) — ติดตั้งจบในคำสั่งเดียว เร็ว ไม่หน่วง (shell startup ~0.06s)

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/arkashira/devops-terminal/main/install.sh)"
```

รันซ้ำได้ตลอด = update ตัวเอง / ของเดิมใน `~/.zshrc` ไม่ถูกแตะ (แค่เพิ่ม source บรรทัดเดียว) / config เดิมถูก backup เป็น `*.pre-devops-terminal`

## ได้อะไรบ้าง

**🔍 fzf ทุกจุดสัมผัส** — **`Tab` = fzf-tab dropdown** (เลือกด้วยลูกศร ทุกคำสั่งพร้อม completion จริงของ kubectl/helm/aws/terraform/stern/gh, กด `/` เจาะโฟลเดอร์ต่อ, popup กลางจอใน tmux), `Ctrl+R` history (atuin), `Ctrl+T` ไฟล์+preview, `Alt+C` cd, `Ctrl+G` คลังคำสั่ง devops (navi), `z` กระโดด dir (zoxide)

**☸️ Kubernetes/AWS** — `saws` สลับ AWS profile แบบ dropdown, `kubectx`/`kubens`, `fkl`/`fke`/`fkd`/`fkpf` เลือก pod แล้ว log/shell/describe/port-forward, `stern` tail log หลาย pod, kubecolor, viddy, k8s context โชว์บน tmux status bar + starship prompt กันยิงผิดคลัสเตอร์, auto-switch AWS profile ตามโฟลเดอร์ (`AWS_DIR_PROFILES`)

**🖥 tmux ชุดเต็ม** — resurrect+continuum (session รอดข้าม reboot, autosave 15 นาที), extrakto (`prefix+Tab` หยิบ token จากจอ), sync panes (`prefix+S`), k9s popup (`prefix+k`), tmux-fzf, fzf-url + **patch บั๊ก tmux 3.7 ที่ทำ resurrect พัง** ให้อัตโนมัติ

**👻 Ghostty** — Quick Terminal (`` Cmd+` `` จากแอปไหนก็ได้), prompt jump (`Cmd+↑/↓` แบบ blocks ของ Warp), OSC52 (copy จาก ssh/tmux กลับ clipboard ได้), paste protection, scrollback 50MB, จำ window ข้าม restart, cursor trail shader

**⚡ QoL** — starship prompt (git/k8s/aws/terraform context), autosuggestions + syntax highlighting, autocorrect, `Esc Esc` เติม sudo, `Ctrl+Z` สลับ fg, eza, bat, `keys` เปิด cheat sheet

**🛡 DevSecOps** — trivy (สแกน image/IaC/secret), terraform-docs, yq/jq, glow

## AI (optional แต่แนะนำ)

ลง [Kiro CLI](https://aws.amazon.com/q/developer/) (ฟรี ด้วย AWS Builder ID) แล้ว:

```sh
kiro-cli login
kiro-cli integrations install dotfiles   # dropdown autocomplete 500+ CLIs
kiro-cli inline disable                  # ใช้ ghost text จาก history แทน (เสถียรใน tmux กว่า)
```

จะได้เพิ่ม: `ask "คำถาม"`, `whyfail` (AI วิเคราะห์คำสั่งที่พัง), `Alt+T` (แปลภาษาคนเป็นคำสั่ง), `prefix+i` AI popup ใน tmux

## หลังติดตั้ง

1. เปิด terminal ใหม่ → พิม `keys` ดูปุ่มลัดทั้งหมด
2. เปิด Ghostty กด `` Cmd+` `` จากแอปอื่น → อนุญาต Accessibility ครั้งเดียว
3. แก้ `AWS_DIR_PROFILES` ใน `~/.devops-terminal/configs/zshrc.sh` ให้ map โฟลเดอร์งาน → AWS profile ของคุณ

## โครงสร้าง

```
install.sh                      # ตัวติดตั้ง (idempotent)
configs/zshrc.sh                # zsh enhancements ทั้งหมด (source จาก ~/.zshrc)
configs/tmux.conf               # tmux + plugins
configs/ghostty-config          # Ghostty
configs/starship.toml           # prompt
configs/devops.cheat            # navi snippets (Ctrl+G)
configs/terminal-cheatsheet.md  # เปิดด้วยคำสั่ง keys
shaders/cursor-trail.glsl       # Ghostty cursor effect
patches/resurrect-tmux37.patch  # แก้บั๊ก tmux 3.7 × resurrect
```
