{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 6;

        modules-left = [
          "hyprland/workspaces"
        ];

        modules-right = [
          "wireplumber"
          "network"
          "bluetooth"
          "clock"
          "custom/power"
        ];

        # -----------------------------
        # Workspaces (Hyprland)
        # -----------------------------
        "hyprland/workspaces" = {
          all-outputs = true;
          format = "{name}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };

        # -----------------------------
        # Audio (PipeWire / WirePlumber)
        # -----------------------------
        wireplumber = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 muted";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        };

        # -----------------------------
        # Network
        # -----------------------------
        network = {
          format-wifi = "󰖩 {signalStrength}%";
          format-ethernet = "󰈀 {ipaddr}";
          format-disconnected = "󰖪 offline";
          tooltip = true;
          on-click = "nm-connection-editor";
        };

        # -----------------------------
        # Bluetooth
        # -----------------------------
        bluetooth = {
          format = "";
          format-off = " off";
          format-disabled = " off";
          tooltip = true;
          on-click = "blueman-manager";
        };

        # -----------------------------
        # Clock
        # -----------------------------
        clock = {
          format = "{:%a %d.%m · %H:%M}";
          tooltip-format = "{:%A, %d. %B %Y}";
        };

        # -----------------------------
        # Power button
        # -----------------------------
        "custom/power" = {
          format = "⏻";
          tooltip = true;
          tooltip-format = "Power";
          on-click = "wlogout";
        };
      };
    };

    # -----------------------------
    # Style (CSS)
    # -----------------------------
    style = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
        font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
        font-size: 12px;
      }

      window#waybar {
        background: rgba(10, 10, 10, 0.60);
        color: #eaeaea;
      }

      #workspaces,
      #clock,
      #wireplumber,
      #network,
      #bluetooth,
      #custom-power {
        padding: 0 10px;
        margin: 6px 4px;
        background: rgba(255, 255, 255, 0.06);
        border-radius: 10px;
      }

      /* Workspaces */
      #workspaces {
        padding: 0 6px;
      }

      #workspaces button {
        padding: 2px 8px;
        margin: 4px 3px;
        border-radius: 8px;
        background: transparent;
        color: #bdbdbd;
        transition: background 120ms ease, color 120ms ease;
      }

      #workspaces button.active {
        background: rgba(255, 255, 255, 0.14);
        color: #ffffff;
      }

      #workspaces button:hover {
        background: rgba(255, 255, 255, 0.10);
        color: #ffffff;
      }

      #workspaces button.urgent {
        background: rgba(255, 80, 80, 0.18);
        color: #ffffff;
      }

      #workspaces button.empty {
        color: rgba(255, 255, 255, 0.35);
      }

      /* Audio */
      #wireplumber.muted {
        color: rgba(255, 255, 255, 0.45);
      }

      /* Network */
      #network.disconnected {
        color: rgba(255, 255, 255, 0.45);
      }

      /* Bluetooth */
      #bluetooth.off,
      #bluetooth.disabled {
        color: rgba(255, 255, 255, 0.45);
      }

      /* Power */
      #custom-power {
        padding: 0 12px;
        font-weight: 700;
      }

      #custom-power:hover {
        background: rgba(255, 255, 255, 0.12);
      }

      tooltip {
        background: rgba(10, 10, 10, 0.90);
        color: #eaeaea;
        border-radius: 10px;
        padding: 8px 10px;
      }
    '';
  };
}

