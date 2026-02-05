# Dot Files

Personal dotfiles configuration repository.

## Setup

### Linking to ~/.config

Link the dot-files directory to `~/.config` and Link the `.zshrc` file to `~/.zshrc`:

```bash
ln -s ~/dot-files/zsh ~/.config/zsh
ln -s ~/dot-files/.zshrc ~/.zshrc
```

This creates a symbolic link so that `~/.config/zsh` points to `~/dot-files/zsh`.

### First Time Setup

After linking, source your `.zshrc` to load the configuration:

```bash
source ~/.zshrc
```

### Second Time Onwards

To apply your changes and reload your shell configuration, run the following command:

```bash
reload
```

This will source your `~/.zshrc` and apply all changes immediately.
