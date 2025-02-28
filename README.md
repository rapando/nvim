## Neovim Configs.

Good for Rust, Go, Python, JS and C.

## Installation

```sh
# install general binaries.
brew install neovim fd ripgrep fzf rust-analyzer lazygit cmake node

# install LSPs
npm install -g typescript-language-server pyright luajit gcc

# Install rust specific tools.
rustup component add clippy-preview rust-src rustfmt

# Install gopls.
go install golang.org/x/tools/gopls@latest
export PATH=$PATH:$(go env GOPATH)/bin

# Setup lua 5.1
curl -LO https://github.com/luarocks/luarocks/archive/refs/tags/v3.9.1.tar.gz
tar -xvzf v3.9.1.tar.gz
cd luarocks-3.9.1
./configure --with-lua=/usr/local --lua-version=5.1 --prefix=/usr/local
make
sudo make install
cd ..
```

Install [Cousine](https://font.download/font/cousine) Font. Or to change the font, change it in `lua/general/configs.lua`. Update this line

```lua
vim.o.guifont         = "Cousine:h16" -- set font and size.
```

Clone

```sh
git clone https://github.com/rapando/nvim ~/.config/nvim
```

## Keyboard shortcuts

The leader key is mapped to 'spacebar'. You can get all the keybindings from lua/configs but these
are the ones I mostly use.

| Binding | Language/ Tech | Explanation | 
| :--- | :--- | :---|
| \<leader\>gg | General | Opens Lazygit interface |
| \<leader\>m | General | Open or close the file tree |
| \<leader\>n or Right click| General | Open menu options |
| \<leader\>v | General | Split vertically |
| \<leader\>tt | General | Open terminal at the bottom |
| \<leader\>f | General | Global search for a symbol |
| \<leader\>o | General | Search for and open a file |
| \<leader\>gc | General | Show Git status in floating window |
| \<leader\>m | General | Multi-cursor select. \<A-n\> [more](https://github.com/mg979/vim-visual-multi?tab=readme-ov-file#vim-visual-multi) |
| \<leader\>S | General | Open search interface |
| \<leader\>sw | General | Search current word |
| \<leader\>sp | General | Search current file |
| \<leader\>tf | General | Find Todos |
| ]t | General | Find next TODO |
| [t | General | Find Previous TODO |
| gD | Golang | Go to symbol declaration |
| gd | Golang/ Rust | Go to symbol definition |
| K | Golang/ Rust | Hover over a symbol to see a summary |
| \<leader\>c | Rust | Code actions e.g optimizing import structure |
|\<leader\>rr| Rust | Runnables, e.g cargo check |
| \<leader\>rf | Rust | Format code |
| \<leader\>ru | Rust | Organize imports |


## Post Installation

```sh 
:Mason
:MasonInstall gopls pyright rust-analyzer
```

|> rapando