{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    ghostty
    wofi
    # Zen Browser aus Flake-Input:
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    firefox
    yazi
    nautilus
    steam
    vulkan-loader
    vulkan-validation-layers
    gnome-disk-utility
    bibata-cursors
    vesktop
    spotify
    waybar
    hyprpaper
    hyprlock
    grim
    slurp
    wl-clipboard
    polkit
    sl
    git
    jetbrains.idea-ultimate
    catppuccin-sddm
    lazydocker
    pavucontrol
    wireplumber
    networkmanagerapplet
    networkmanager
    ncurses # for nmtui stuff (usually pulled anyway)
    blueman
    bluez
    wlogout
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}

