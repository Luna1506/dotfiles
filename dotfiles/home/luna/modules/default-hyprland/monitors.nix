{ zoom, ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1,1920x1080@144,0x0,${zoom}"
      "HDMI-A-1,2560x1440@75,1920x0,1"
      ",preferred,auto,1"
    ];
  };
}
