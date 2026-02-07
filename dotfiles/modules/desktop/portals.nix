{ pkgs, lib, ... }:

{
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];

    config = {
      common = {
        default = [ "gtk" "wlr" ];
      };
    };
  };

  # ÄNDERUNG GEHÖRT GENAU HIERHIN:
  # Backends in grafischer Session automatisch starten
  systemd.user.services.xdg-desktop-portal-gtk.wantedBy = [ "graphical-session.target" ];
  systemd.user.services.xdg-desktop-portal-wlr.wantedBy = [ "graphical-session.target" ];
}
