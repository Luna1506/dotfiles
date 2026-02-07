{ config, pkgs, lib, ... }:

{
  # Cinnamon ist ein X11-Desktop
  services.xserver.enable = true;

  # Cinnamon Desktop
  services.xserver.desktopManager.cinnamon.enable = true;

  # Display Manager (wenn du SDDM willst)
  services.displayManager.sddm.enable = true;
}
