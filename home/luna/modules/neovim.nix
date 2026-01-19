{ inputs, pkgs, ... }:

{
  # installiert DEIN gebautes Neovim
  home.packages = [
    inputs.nvim.packages.${pkgs.system}.neovim
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # bindet die Config exakt nach ~/.config/nvim
  xdg.configFile."nvim".source =
    inputs.nvim.outPath;
}

