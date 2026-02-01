{ pkgs, ... }:
{
  programs.oh-my-posh = {
    enable = true;
    package = pkgs.oh-my-posh;
    enableBashIntegration = true;
  };

  # Theme-Datei direkt hier definieren
  home.file.".config/ohmyposh/theme.json".text = ''
    {
      "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
      "version": 2,
      "final_space": true,
      "blocks": [
        {
          "type": "prompt",
          "alignment": "left",
          "segments": [
            {
              "type": "session",
              "style": "plain",
              "foreground": "#ffffff"
            },
            {
              "type": "text",
              "text": "@",
              "style": "plain",
              "foreground": "#666666"
            },
            {
              "type": "path",
              "style": "plain",
              "foreground": "#ffffff",
              "properties": {
                "style": "folder"
              }
            }
          ]
        },
        {
          "type": "prompt",
          "alignment": "right",
          "segments": [
            {
              "type": "git",
              "style": "plain",
              "foreground": "#ff5fd7",
              "properties": {
                "branch_icon": " ",
                "fetch_status": true
              }
            }
          ]
        }
      ]
    }
  '';

  # Bash init: oh-my-posh Theme laden
  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/theme.json)"
    '';
  };
}

