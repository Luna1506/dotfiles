{ lib
, stdenv
, fetchurl
, makeWrapper
, autoPatchelfHook
, gtk3
, glib
, nss
, nspr
, alsa-lib
, libpulseaudio
, mesa
, cairo
, pango
, atk
, at-spi2-atk
, at-spi2-core
, cups
, dbus
, expat
, fontconfig
, freetype
, libdrm
, libxkbcommon
, xorg
, libxcb
, libxshmfence
}:

stdenv.mkDerivation rec {
  pname = "teamspeak6";
  version = "6.0.0-beta3.4";

  src = fetchurl {
    url = "https://files.teamspeak-services.com/pre_releases/client/${version}/teamspeak-client.tar.gz";
    sha256 = "b9ba408a0b58170ce32384fc8bba56800840d694bd310050cbadd09246d4bf27";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gtk3
    glib
    nss
    nspr
    alsa-lib
    libpulseaudio
    mesa
    cairo
    pango
    atk
    at-spi2-atk
    at-spi2-core
    cups
    dbus
    expat
    fontconfig
    freetype
    libdrm
    libxkbcommon
    libxcb
    libxshmfence
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/teamspeak6
    cp -r ./* $out/opt/teamspeak6/

    mkdir -p $out/bin
    makeWrapper $out/opt/teamspeak6/TeamSpeak $out/bin/teamspeak6 \
      --chdir $out/opt/teamspeak6

    runHook postInstall
  '';

  meta = with lib; {
    description = "TeamSpeak 6 Client (beta)";
    homepage = "https://www.teamspeak.com/";
    license = licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "teamspeak6";
  };
}
