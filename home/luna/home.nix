{ pkgs, ... }:

{
  home.username = "luna";
  home.homeDirectory = "/home/luna";
  home.stateVersion = "23.11";  # <-- nimm die Version deiner ERSTEN HM-Installation

  programs.home-manager.enable = true;

  # --- GPG ---
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };
  
  programs.git = {
    enable = true;
    settings.user = {
      name = "Luna";
      email = "mhaiplick1506@gmail.com";
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
  
  programs.yazi = {
    enable = true;
    settings = {
      manager = {
        show_hidden = true;  # ← das wolltest du setzen
        sort_dir_first = true;
        linemode = "size";   # z. B. "size", "mtime", "permission"
      };
    };
  };

  # --- Cursor (Home-Session) ---
  # Hinweis: Es gibt KEIN 'enable' auf oberster Ebene.
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 15;
    gtk.enable = true;  # GTK-Apps
    x11.enable = true;  # XWayland/X11
    # hyprcursor.enable = true;  # <-- ENTFERNEN: Option existiert hier nicht
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = {
        monitor = "eDP-1";
        path = "/home/luna/.config/hypr/wallpaper/wallpaper1.jpg";
        fit_mode = "cover";
      };
      splash = false;
    };
  };
}

