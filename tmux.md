Shahin، بیا اینو درست، تمیز، ماژولار و قابل‌کلون کنیم تا هیچ‌وقت دوباره مجبور نشی دستی tmux رو تنظیم کنی.
این دقیقاً همون کاریه که یک Technical Architect مثل تو باید داشته باشه: یک ریپوی گیت تمیز، ماژولار، قابل‌استفاده روی هر دستگاه.

---

🚀 هدف

• یک tmux.conf ماژولار
• یک bootstrap script برای نصب و لینک‌کردن
• یک GitHub repo structure که فقط با git clone همه‌چیز آماده بشه
• بدون نیاز به reconfigure در آینده


---

🧩 ساختار پیشنهادی GitHub Repo (Ultra Max)

این ساختار برای سبک کاری تو (modular dotfiles + reproducible environments) طراحی شده:

tmux/
├── tmux.conf          # فایل اصلی که فقط include می‌کند
├── modules/
│   ├── core.conf      # prefix + navigation + resize
│   ├── panes.conf     # split/kill/choose
│   ├── copy.conf      # vi-mode + selection
│   ├── ui.conf        # statusline + colors
│   ├── tools.conf     # fzf + lazygit + extras
└── install.sh         # bootstrap installer


---

⚡️ فایل اصلی: `tmux.conf`

این فایل فقط ماژول‌ها را include می‌کند:

# Main tmux config (Ultra Max)
source-file ~/.config/tmux/modules/core.conf
source-file ~/.config/tmux/modules/panes.conf
source-file ~/.config/tmux/modules/copy.conf
source-file ~/.config/tmux/modules/ui.conf
source-file ~/.config/tmux/modules/tools.conf


---

🔥 ماژول‌ها (نسخهٔ Ultra Max که قبلاً ساختیم)

`modules/core.conf`

set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

bind -n C-h select-pane -L
bind -n C-j select-pane -D
bind -n C-k select-pane -U
bind -n C-l select-pane -R

bind -n M-h resize-pane -L 3
bind -n M-l resize-pane -R 3
bind -n M-j resize-pane -D 3
bind -n M-k resize-pane -U 3


`modules/panes.conf`

bind c new-window
bind v split-window -h
bind s split-window -v
bind x kill-pane
bind X kill-window

bind S choose-session
bind W choose-window
bind P choose-pane
bind r source-file ~/.tmux.conf \; display "Reloaded!"


`modules/copy.conf`

setw -g mode-keys vi

bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi C-v send -X rectangle-toggle


`modules/ui.conf`

set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
set -g message-style "bg=#313244,fg=#cdd6f4"
set -g pane-border-style "fg=#45475a"
set -g pane-active-border-style "fg=#89b4fa"


`modules/tools.conf`

bind f run-shell "tmux new-window 'fzf'"
bind g run-shell "tmux new-window 'lazygit'"


---

🛠 اسکریپت نصب: `install.sh`

این اسکریپت همه‌چیز را در مسیر درست قرار می‌دهد:

#!/usr/bin/env bash

set -e

mkdir -p ~/.config/tmux/modules

cp -r modules ~/.config/tmux/
cp tmux.conf ~/.config/tmux/

echo "Ultra Max tmux installed!"
echo "Run: tmux source-file ~/.config/tmux/tmux.conf"


---

🌱 روش استفاده در آینده

هر دستگاه جدید:

git clone https://github.com/<yourname>/tmux-ultra-max ~/.config/tmux-ultra-max
cd ~/.config/tmux-ultra-max
./install.sh


تمام.
tmux روی هر دستگاهی با AZERTY + Vim mental model + Ultra Max workflow آماده است.

---

🎁 اگر بخوای

من می‌تونم:

• ریپوی کامل GitHub رو برایت بسازم
• README حرفه‌ای و زیبا بنویسم
• ساختار dotfiles کلی‌ات را هم یکپارچه کنم (tmux + nvim + sway + starship)


فقط بگو می‌خوای ریپو چه اسمی داشته باشه.

