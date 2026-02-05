# Dot Files

Personal dotfiles configuration repository.

## Quick Install

Run the installation script to set up everything automatically:

```bash
git clone https://github.com/YOUR_USERNAME/dot-files.git ~/Projects/dot-files
cd ~/Projects/dot-files
./install.sh
```

This will install:
- zsh (if not present)
- Oh My Zsh
- Powerlevel10k theme
- zsh plugins (autosuggestions, syntax-highlighting, completions, z)
- CLI tools (fzf, bat, eza, zoxide, delta)
- Create symlinks for `.zshrc` and `~/.config/zsh`
- Source `.zshrc` and run `p10k configure`

## Reloading Configuration

To apply changes and reload your shell configuration:

```bash
reload
```

## Tools Used

| Tool | Description |
|------|-------------|
| [Oh My Zsh](https://ohmyz.sh/) | Zsh framework |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Zsh theme |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [eza](https://github.com/eza-community/eza) | Modern ls replacement |
| [bat](https://github.com/sharkdp/bat) | Modern cat with syntax highlighting |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter cd command |
| [delta](https://github.com/dandavison/delta) | Better git diff |
