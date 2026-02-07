{ config, pkgs, ... }:

let
  dockCss = ''
    /* ~/.config/nwg-dock-hyprland/style.css */

    window {
      background: rgba(18, 18, 22, 0.35);
      border-radius: 22px;
      background-clip: padding-box;

      border: 1px solid rgba(255, 255, 255, 0.14);

      box-shadow:
        inset 0 1px 0 rgba(255, 255, 255, 0.10);

      padding: 12px 18px;
    }

    button {
      margin: 0 8px;
      padding: 8px;
      border-radius: 14px;
      background: transparent;
      transition: background 120ms ease;
      color: rgba(255, 255, 255, 0.9);
    }

    button:hover {
      background: rgba(255, 255, 255, 0.10);
    }

    button:checked {
      background: rgba(255, 255, 255, 0.14);
    }
  '';

  autohideScript = ''
    #!/usr/bin/env bash
    set -euo pipefail

    HYPRCTL=${pkgs.hyprland}/bin/hyprctl
    JQ=${pkgs.jq}/bin/jq
    SLEEP=${pkgs.coreutils}/bin/sleep
    PIDOF=${pkgs.procps}/bin/pidof
    KILL=${pkgs.coreutils}/bin/kill

    SIG_SHOW=36
    SIG_HIDE=37

    while true; do
      WS=$($HYPRCTL activeworkspace -j | $JQ .id)
      COUNT=$($HYPRCTL clients -j | $JQ "[.[] | select(.workspace.id == $WS)] | length")

      PID="$($PIDOF -s nwg-dock-hyprland || true)"
      if [ -n "$PID" ]; then
        if [ "$COUNT" -eq 0 ]; then
          $KILL -s "$SIG_SHOW" "$PID" || true
        else
          $KILL -s "$SIG_HIDE" "$PID" || true
        fi
      fi

      $SLEEP 0.35
    done
  '';
in
{
  ########################################
  # Pakete
  ########################################
  home.packages = with pkgs; [
    nwg-dock-hyprland
    wofi
    jq
    procps
  ];

  ########################################
  # Dock CSS
  ########################################
  xdg.configFile."nwg-dock-hyprland/style.css".text = dockCss;

  ########################################
  # Appmenu SVG (aus ./icons/appmenu.svg)
  ########################################
  xdg.configFile."nwg-dock-hyprland/icons/appmenu.svg".source =
    ./icons/appmenu.svg;

  ########################################
  # Autohide Script
  ########################################
  home.file.".local/bin/nwg-dock-emptyws-autohide.sh" = {
    executable = true;
    text = autohideScript;
  };

  ########################################
  # Dock Service
  ########################################
  systemd.user.services.nwg-dock = {
    Unit = {
      Description = "nwg-dock-hyprland";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = ''
        ${pkgs.nwg-dock-hyprland}/bin/nwg-dock-hyprland \
          -r \
          -p bottom \
          -a center \
          -i 56 \
          -ico "/home/luna/.config/nwg-dock-hyprland/icons/appmenu.svg" \
          -c "wofi --show drun" \
          -s style.css \
          -mb 20
      '';
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  ########################################
  # Autohide Service
  ########################################
  systemd.user.services.nwg-dock-emptyws-autohide = {
    Unit = {
      Description = "nwg-dock-hyprland autohide (empty workspace)";
      After = [ "nwg-dock.service" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "%h/.local/bin/nwg-dock-emptyws-autohide.sh";
      Restart = "always";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
