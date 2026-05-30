# AryanOS Project Summary

This document summarizes the complete build process, configuration, and tools set up for the **AryanOS** Hyprland desktop environment (the "kadaberice" project).

## 🚀 What We Accomplished

1. **LazyVim Setup**: Installed and fully configured a professional LazyVim environment optimized for C/C++, Rust, Linux Systems Programming, and Cybersecurity. Backed up previous configs securely.
2. **AryanOS Core Design**: Designed a Wayland desktop from scratch drawing inspiration from Ancient Indian aesthetics (Hanuman, Shiva, Saffron banners) crossed with modern minimalism.
3. **Hyprland Configuration**: Built a modular, high-performance configuration spread across multiple files (`theme.conf`, `windowrules.conf`, `keybinds.conf`, `startup.conf`, etc.). 
4. **Hyprland v0.55 Compatibility**: Resolved complex breaking syntax changes in the latest Hyprland update (e.g., deprecated `windowrulev2`, removed `pseudotile`, new gesture system).
5. **Status Bar**: Configured **Waybar** as the primary sleek status bar for the desktop.
6. **Wallpaper System**: 
   - Created a dynamic bash rotation script (`wallpaper.sh`).
   - Sorted raw images into categorized folders (`Hanuman`, `Shiva`, `Krishna`, `Warriors`, `Minimal`, `Art`).
   - Configured **Waypaper** as a GUI-based wallpaper changing menu (Shortcut: `Super + Shift + W`).
7. **Window Switcher**: Installed and mapped **Snappy Switcher** for lightning-fast, animated `Alt + Tab` functionality.
8. **Lock Screen**: Built a beautifully blurred, Saffron-themed lock screen using **Hyprlock** (Shortcut: `Super + L`).
9. **Screenshot Engine**: Developed a robust screenshot utility using `grim`, `slurp`, and `wl-clipboard` with various region and full-screen modes.
10. **GitHub Repository**: Initialized a Git repository, wrote a strict `.gitignore` to prevent leaking private SSH keys/credentials, and pushed all configurations to `github.com:aryan742/kadaberice.git`.

## 📂 Files Tracked in this Repository

The `kadaberice` repository contains the following structure:

*   **`.config/hypr/`**: The core Wayland compositor configuration.
    *   `hyprland.conf` (Main entry point)
    *   `theme.conf` (Colors, borders, blur, shadows)
    *   `windowrules.conf` (Strict routing and floating rules)
    *   `keybinds.conf` (All keyboard shortcuts)
    *   `startup.conf` (Autostart daemons)
    *   `animations.conf` (Custom Bezier curves)
    *   `monitors.conf` (Display settings)
    *   `hyprpaper.conf` (Wallpaper daemon config)
    *   `hyprlock.conf` (Saffron/Dark theme lock screen)
    *   `scripts/` (Contains `screenshot.sh`, `wallpaper.sh`)
*   **`.config/waybar/`**: Status bar UI.
    *   `config.jsonc` (Modules)
    *   `style.css` (Styling)
*   **`.config/waypaper/`**: GUI wallpaper menu.
    *   `config.ini`
*   **`.config/nvim/`**: Complete IDE setup (LazyVim).
*   **`.config/kitty/`**: GPU-accelerated terminal emulator settings.
*   **`.config/yazi/`**: Terminal file manager configuration.
*   **`Wallpapers/`**: Organized background images.
*   **`packages.txt`**: A checklist of all required packages to reproduce this environment.
*   **`README.md`**: Project overview.
*   **`.gitignore`**: Privacy guard.

*AryanOS — Built for focus, clarity, and warrior discipline.*
