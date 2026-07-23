# devops-terminal Cheat Sheet

## ⚡ Quick wins
| ปุ่ม/คำสั่ง | ทำอะไร |
|---|---|
| `Tab` | **fzf-tab dropdown** — เลือกด้วยลูกศร+พิมกรอง ทุกคำสั่ง (kubectl/aws/helm/cd/git) ทุก terminal รวม tmux — กด `/` เจาะโฟลเดอร์ต่อ, มี preview ตอน cd |
| `Esc Esc` | เติม/ถอด `sudo` หน้าคำสั่ง (บรรทัดว่าง = หยิบคำสั่งก่อนหน้ามาใส่ sudo ให้) |
| `Ctrl+Z` | สลับเข้า/ออกโปรแกรมที่พักไว้ — กดใน vim/k9s เพื่อพัก กดอีกทีกลับ |
| พิมคำสั่งผิด | zsh ถาม `correct 'kubctl' to 'kubectl'? [ynae]` — y=แก้ให้ |
| `→` หรือ `Ctrl+E` / `Alt+F` | รับ ghost text ทั้งหมด / ทีละคำ |
| `keys` | เปิด cheat sheet นี้ |

## 🤖 AI (ต้องมี kiro-cli + login)
| ปุ่ม/คำสั่ง | ทำอะไร |
|---|---|
| `Alt+T` | พิมภาษาคนบนบรรทัด → AI แปลงเป็นคำสั่งจริง (มีเมนูก่อนรัน) |
| `ask <คำถาม>` | ถาม AI ตอบในจอ (read-only ไม่แตะไฟล์/ไม่รันคำสั่ง) |
| `whyfail` | คำสั่งเมื่อกี้พัง → AI อธิบายสาเหตุ+วิธีแก้ |
| `kiro-cli chat` | AI agent เต็มตัวใน terminal |

## 👻 Ghostty
| ปุ่ม | ทำอะไร |
|---|---|
| `Cmd+\`` (จากแอปไหนก็ได้) | Quick Terminal หล่นจากขอบบน กดซ้ำเก็บ |
| `Cmd+↑` / `Cmd+↓` | กระโดดระหว่าง prompt (แบบ blocks ของ Warp) |
| `Cmd+Shift+J` | เท scrollback ทั้งหมดลงไฟล์แล้วเปิดดู |
| `Shift+Enter` | ขึ้นบรรทัดใหม่ไม่ส่งคำสั่ง (ใช้กับ AI chat) |
| `Cmd+D` / `Cmd+Shift+D` | split ขวา / ล่าง |
| `Cmd+Alt+ลูกศร` / `Cmd+Shift+Enter` | ย้าย split / zoom |
| `Cmd+K` | เคลียร์จอ · `Cmd+Shift+,` reload config |

## 🔍 fzf / ค้นหา
| ปุ่ม | ทำอะไร |
|---|---|
| `Ctrl+R` | ค้น history (atuin UI — กรองตาม dir/exit code ได้) |
| `Ctrl+T` | ค้นไฟล์ + preview (bat) แล้ววางลงบรรทัด |
| `Alt+C` | เลือก dir แล้ว cd ไปเลย |
| `**` แล้ว `Tab` | fuzzy completion เช่น `vim **<Tab>` |
| `Ctrl+G` | navi — คลังคำสั่ง devops (aws/k8s/tf/trivy) |
| `z <คำ>` / `zi` | กระโดดไป dir ที่ไปบ่อย / เลือกผ่าน fzf |

## ☸️ Kubernetes / AWS
| คำสั่ง | ทำอะไร |
|---|---|
| `saws` | สลับ AWS profile (dropdown) |
| `kubectx` / `kubens` | สลับ cluster / namespace (dropdown) |
| `fkl` / `fke` / `fkd` / `fkpf` | เลือก pod → log / shell / describe / port-forward |
| `stern <pattern> -n <ns>` | tail log หลาย pod พร้อมกัน |
| `k` | kubectl แบบมีสี |
| `watch kubectl get pods` | viddy — ไฮไลท์ diff อัตโนมัติ |
| cd เข้าโฟลเดอร์ที่ map ไว้ | AWS_PROFILE สลับเอง (ตั้งใน AWS_DIR_PROFILES) |

## 🖥 tmux (prefix = Ctrl+b)
| ปุ่ม | ทำอะไร |
|---|---|
| `prefix Tab` | extrakto — หยิบ token จากจอ (pod/IP/hash) ด้วย fzf |
| `prefix i` | AI chat popup (kiro) |
| `prefix k` | k9s popup |
| `prefix t` | scratch terminal popup |
| `prefix S` | sync panes — พิมครั้งเดียวลงทุก pane (มี ⚠ SYNC เตือน) |
| `prefix F` | เมนูจัดการ session/window/pane (fzf) |
| `prefix u` | เปิด URL ที่อยู่บนจอ |
| `prefix \|` / `prefix -` | split แนวตั้ง / แนวนอน |
| `Alt+ลูกศร` | ย้าย pane (ไม่ต้อง prefix) |
| `Shift+←/→` | สลับ window (ไม่ต้อง prefix) |
| `prefix [` แล้ว `v`,`y` | copy mode แบบ vim — เลือกแล้ว copy เข้า clipboard |
| `prefix Ctrl+s` / `Ctrl+r` | save / restore session (autosave ทุก 15 นาที) |
| `prefix I` | ติดตั้ง/อัปเดต plugins · `prefix r` reload config |

## 🛡 DevSecOps
| คำสั่ง | ทำอะไร |
|---|---|
| `trivy image <img>` | สแกน vuln ใน image |
| `trivy config .` | สแกน terraform/k8s yaml หา misconfig |
| `trivy fs --scanners secret .` | หา secret หลุดใน repo |
| `terraform-docs markdown table .` | gen เอกสาร module |
| `glow <file.md>` | อ่าน markdown สวยๆ ในจอ |
## 🚀 Pro tools (เพิ่ม 2026-07-23)
| คำสั่ง | ทำอะไร |
|---|---|
| `lg` | lazygit — git TUI ครบจบในจอเดียว (stage/commit/rebase/push) |
| `git diff` | สวยอัตโนมัติด้วย delta — กด `n`/`N` กระโดดข้ามไฟล์ |
| `y` | yazi — file manager มี preview ออกแล้ว cd ตามให้ |
| `btop` / `lazydocker` / `dive <image>` | monitor ระบบ / docker TUI / ส่องชั้น image |
| `kubectl neat -f x.yaml` | ล้าง yaml ให้เหลือแต่เนื้อ |
| `kubectl tree deploy/<name>` | ดู ownership ของ resource เป็นต้นไม้ |
| `kubectl node-shell <node>` | เข้า shell ของ node ตรงๆ |
| `kubent` | สแกน deprecated API ก่อนอัปเกรด cluster |
| `popeye` | ตรวจสุขภาพ cluster + ให้เกรด |
| `argocd` / `kustomize` | CLI คู่สาย gitops |
| `lnav <dir>` | เปิด log หลายไฟล์ merge ตามเวลา + query ด้วย SQL |
| `fx` / `jless` | ส่อง JSON แบบโต้ตอบ / แบบ pager |
| `xh get api.example.com/x` | curl โฉมใหม่ syntax ภาษาคน |
| `trippy <host>` / `gping <h1> <h2>` / `doggo <domain>` | traceroute+ping TUI / ping เป็นกราฟ / DNS สวยๆ |
| `hyperfine 'cmd1' 'cmd2'` | benchmark เทียบคำสั่ง |
| `watchexec -e tf 'terraform validate'` | รันซ้ำอัตโนมัติเมื่อไฟล์เปลี่ยน |
| `sops -e secrets.yaml` | เข้ารหัส secret เก็บใน git (คู่กับ age) |
| `assume` | granted — สลับ AWS SSO role หลาย account, token อยู่ใน keychain |
| `steampipe query "select name, region from aws_s3_bucket"` | query AWS ด้วย SQL |
| `aws ssm start-session --target <instance-id>` | เข้า EC2 โดยไม่ต้องมี SSH/bastion |
| `mise use terraform@1.9` / `just` | pin เวอร์ชัน tool ต่อโปรเจกต์ / task runner |
| `eksctl get cluster` / `infracost breakdown --path .` | จัดการ EKS / ประเมินค่าใช้จ่าย terraform |
