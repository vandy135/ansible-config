# Arch Linux Ansible Playbook

A highly modular, configurable Ansible playbook for Arch Linux system configuration. Designed for setting up development workstations with a Wayland desktop environment (niri).

## Features

- **Modular Design**: 10+ separate task files for easy customization
- **Feature Flags**: 15+ toggleable components via boolean variables
- **Multi-Host Support**: Different configurations for laptop, desktop, or server
- **Wayland Desktop**: niri compositor with waybar, alacritty, fuzzel, and mako
- **Modern CLI Tools**: eza, fd, ripgrep, fzf, bat, and more
- **Development Ready**: git, neovim, docker, lazygit, GitHub CLI
- **Idempotent**: Safe to run multiple times

## Quick Start

### Prerequisites

1. **Ansible** (2.14+) installed on control machine
2. **SSH access** to target machine (or run locally)
3. **Python 3** on target machine

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/arch-ansible.git
cd arch-ansible

# Install Ansible collections
ansible-galaxy install -r requirements.yml

# Edit inventory with your hosts
vim inventory/hosts.yml

# Configure host-specific variables
cp inventory/host_vars/laptop.yml inventory/host_vars/myhostname.yml
vim inventory/host_vars/myhostname.yml
```

### Running the Playbook

```bash
# Dry run (check mode) - see what would change
ansible-playbook site.yml -l laptop --check --diff

# Full run on laptop
ansible-playbook site.yml -l laptop

# Full run on desktop
ansible-playbook site.yml -l desktop

# Run locally (on the same machine)
ansible-playbook site.yml -l localhost --connection=local

# Run with verbose output
ansible-playbook site.yml -l laptop -vvv

# Run specific tags only
ansible-playbook site.yml -l laptop --tags "base,desktop"
```

## Directory Structure

```
.
├── ansible.cfg              # Ansible configuration
├── site.yml                 # Main playbook entry point
├── requirements.yml         # Ansible Galaxy requirements
├── inventory/
│   ├── hosts.yml           # Host inventory
│   ├── group_vars/
│   │   └── all.yml         # Global variables and feature flags
│   └── host_vars/
│       ├── laptop.yml      # Laptop-specific configuration
│       └── desktop.yml     # Desktop-specific configuration
├── roles/
│   └── base/               # Base system configuration role
│       ├── tasks/
│       ├── handlers/
│       ├── defaults/
│       └── templates/
├── tasks/                   # Modular task files
│   ├── aur-helper.yml      # AUR helper installation
│   ├── browser.yml         # Web browser installation
│   ├── cli-tools.yml       # CLI utilities
│   ├── desktop.yml         # Desktop environment
│   ├── development.yml     # Development tools
│   ├── dotfiles.yml        # Dotfiles management
│   ├── extra-packages.yml  # Host-specific packages
│   ├── fonts.yml           # Font installation
│   ├── security.yml        # Security configuration
│   ├── services.yml        # System services
│   └── users.yml           # User management
├── handlers/
│   └── main.yml            # Shared handlers
└── templates/
    └── alacritty.yml.j2    # Alacritty terminal config
```

## Configuration

### Feature Flags

All features can be enabled/disabled in `group_vars/all.yml` or overridden in `host_vars/`:

| Flag | Default | Description |
|------|---------|-------------|
| `install_base_devel` | true | Base development tools |
| `configure_pacman` | true | Pacman optimization |
| `install_aur_helper` | true | AUR helper (paru/yay) |
| `install_desktop` | true | Full desktop environment |
| `install_niri` | true | Niri Wayland compositor |
| `install_waybar` | true | Waybar status bar |
| `install_terminal` | true | Alacritty terminal |
| `install_launcher` | true | Fuzzel launcher |
| `install_notifications` | true | Mako notifications |
| `install_dev_tools` | true | Development tools |
| `install_docker` | true | Docker containers |
| `install_neovim` | true | Neovim editor |
| `install_audio` | true | Pipewire audio |
| `install_bluetooth` | true | Bluetooth support |
| `configure_firewall` | true | UFW firewall |
| `manage_dotfiles` | true | Dotfiles deployment |

### Host-Specific Configuration

Create a file in `host_vars/` named after your hostname:

```yaml
# inventory/host_vars/mymachine.yml
---
system_hostname: mymachine
target_user: myuser
system_timezone: America/New_York

# Disable features not needed
install_printing: false
install_bluetooth: false

# Add extra packages
extra_packages:
  - steam
  - discord

extra_aur_packages:
  - spotify
```

## Usage Examples

### Example 1: Initial Setup on New Machine

```bash
# First, ensure SSH access is working
ssh root@192.168.1.100

# Run the full playbook
ansible-playbook site.yml -l laptop -K
```

### Example 2: Update Only Desktop Components

```bash
ansible-playbook site.yml -l laptop --tags desktop
```

### Example 3: Install Development Tools Only

```bash
ansible-playbook site.yml -l laptop --tags "dev-tools,cli-tools"
```

### Example 4: Dry Run Before Production

```bash
ansible-playbook site.yml -l laptop --check --diff -v
```

### Example 5: Configure Security Settings Only

```bash
ansible-playbook site.yml -l laptop --tags security
```

## Adding New Features

### Step 1: Create Task File

Create a new file in `tasks/`:

```yaml
# tasks/my-feature.yml
---
- name: My Feature Setup
  when: install_my_feature | default(true)
  tags:
    - my-feature
  block:
    - name: Install packages
      community.general.pacman:
        name: "{{ my_feature_packages }}"
        state: present
      become: true
```

### Step 2: Add Variables

Add to `group_vars/all.yml`:

```yaml
# Feature flag
install_my_feature: true

# Packages
my_feature_packages:
  - package1
  - package2
```

### Step 3: Include in Main Playbook

Add to `site.yml`:

```yaml
- name: Configure my feature
  ansible.builtin.include_tasks: tasks/my-feature.yml
  when: install_my_feature | default(true)
  tags:
    - my-feature
```

### Step 4: Add Documentation

Update this README with the new feature flag and description.

## Tags Reference

| Tag | Description |
|-----|-------------|
| `base` | Base system configuration |
| `pacman` | Pacman configuration |
| `aur` | AUR helper installation |
| `users` | User management |
| `desktop` | Desktop environment |
| `niri` | Niri compositor |
| `waybar` | Waybar status bar |
| `terminal` | Terminal emulator |
| `dev-tools` | Development tools |
| `cli-tools` | CLI utilities |
| `services` | System services |
| `security` | Security configuration |
| `fonts` | Font installation |
| `dotfiles` | Dotfiles management |
| `browser` | Web browser |
| `extra-packages` | Host-specific packages |

## Troubleshooting

### Issue: AUR packages fail to install

**Cause**: AUR helper needs to run as non-root user.

**Solution**: Ensure `target_user` is set correctly and the user exists:

```bash
# Verify user
ansible -m command -a "id {{ target_user }}" laptop
```

### Issue: Services fail to start

**Cause**: Systemd services may not be available during check mode.

**Solution**: Run without `--check` for service tasks:

```bash
ansible-playbook site.yml -l laptop --tags services
```

### Issue: Permission denied errors

**Cause**: Tasks need elevated privileges.

**Solution**: Ensure you're using `-K` flag or have passwordless sudo:

```bash
ansible-playbook site.yml -l laptop -K
```

### Issue: Package not found

**Cause**: Package database needs updating.

**Solution**: Run base role first to update pacman:

```bash
ansible-playbook site.yml -l laptop --tags pacman
```

### Issue: Playbook hangs on SSH

**Cause**: SSH host key verification.

**Solution**: Either accept the key or disable checking:

```bash
# Accept key
ssh-keyscan 192.168.1.100 >> ~/.ssh/known_hosts

# Or set in ansible.cfg (already configured)
# host_key_checking = False
```

## Security Considerations

- Vault passwords should be stored in `.vault_password` (excluded from git)
- SSH keys with proper permissions (600)
- Consider enabling `ssh_password_authentication: no` after setup
- Review firewall rules before enabling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `--check` mode
5. Submit a pull request

## Documentation References

- [Ansible Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
- [Ansible Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)
- [Pacman Module](https://docs.ansible.com/ansible/latest/collections/community/general/pacman_module.html)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Niri Compositor](https://github.com/YaLTeR/niri)

## License

MIT License - See LICENSE file for details.
