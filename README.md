# Dot Files

Personal dotfiles configuration repository.

## Setup

### Linking to ~/.config

Link the dot-files directory to `~/.config`:

```bash
ln -s ~/dot-files/zsh ~/.config/zsh
```

This creates a symbolic link so that `~/.config/zsh` points to `~/dot-files/zsh`.

### Reload Shell Configuration

After making changes to your dotfiles, reload your shell configuration:

```bash
reload
```

This will source your `~/.zshrc` and apply all changes immediately.
