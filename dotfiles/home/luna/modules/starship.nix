{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    package = pkgs.starship;

    # Bash init
    enableBashIntegration = true;

    settings = {
      add_newline = false;

      # Prompt: | user@host | path | git_branch |
      format = "$username$hostname$directory$git_branch$character";

      username = {
        show_always = true;
        style_user = "white";
        format = "| [$user]($style)";
      };

      hostname = {
        ssh_only = false;
        style = "white";
        format = "@[$hostname]($style) | ";
      };

      directory = {
        style = "white";
        format = "[$path]($style) | ";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        style = "white";
        format = " [$branch]($style) | ";
      };

      character = {
        success_symbol = "[>](white) ";
        error_symbol = "[>](white) ";
      };
    };
  };
}

