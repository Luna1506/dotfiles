{ config, pkgs, ... }:
{
  # Beispiel: SDDM-Theme (du nutzt schon Catppuccin im Systempaket)
  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha-mauve";
  };

  # Weitere systemweite Styling-Dinge könnten hier hin (Fonts, Qt-Plattform, etc.)
  # fonts.packages = with pkgs; [ ... ];
}

