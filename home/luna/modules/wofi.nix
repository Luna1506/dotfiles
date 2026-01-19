{ pkgs, ... }:

let
  wofiStyle = pkgs.stdenv.mkDerivation {
    name = "wofi-style";

    src = ./wofi/style.scss;

    nativeBuildInputs = [ pkgs.sass ];

    buildPhase = ''
      sass $src style.css
    '';

    installPhase = ''
      mkdir -p $out
      cp style.css $out/
    '';
  };
in
{
  programs.wofi = {
    enable = true;

    settings = {
      show = "drun";
      allow_images = true;
      gtk_dark = true;
      width = 600;
      height = 400;
    };
  };

  home.file.".config/wofi/style.css".source =
    "${wofiStyle}/style.css";
}

