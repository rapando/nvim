# Records docs/demo/demo.gif with VHS (https://github.com/charmbracelet/vhs): run docs/demo/build.sh
FROM ghcr.io/charmbracelet/vhs:latest
RUN apt-get update && apt-get install -y --no-install-recommends git curl ca-certificates unzip build-essential ripgrep fd-find python3 python3-pip nodejs npm fontconfig \
    && ln -s "$(which fdfind)" /usr/local/bin/fd && rm -rf /var/lib/apt/lists/*
RUN pip install --break-system-packages pytest debugpy && npm install -g pyright tree-sitter-cli
RUN curl -fsSL https://github.com/neovim/neovim/releases/download/v0.12.5/nvim-linux-arm64.tar.gz | tar xz -C /opt \
    && ln -s /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
RUN mkdir -p /usr/local/share/fonts && curl -fsSL -o /tmp/f.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip \
    && unzip -q /tmp/f.zip -d /usr/local/share/fonts && rm /tmp/f.zip && fc-cache -f
ENV TERM=xterm-256color COLORTERM=truecolor
COPY . /root/.config/nvim
RUN nvim --headless "+Lazy! sync" +qa 2>&1 | tail -3
# let treesitter compile the parsers once, so the recording is highlighted from the first frame
RUN nvim --headless /root/.config/nvim/docs/demo/project/billing/tax.py -c 'lua vim.wait(90000, function() return false end)' -c qa! >/dev/null 2>&1; true
RUN cp -r /root/.config/nvim/docs/demo/project /work-billing && cd /work-billing && git init -q && git add -A \
    && git -c user.email=demo@example.com -c user.name=demo commit -qm "billing service" \
    && git config --global --add safe.directory '*'
WORKDIR /vhs
