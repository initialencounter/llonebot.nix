{ pkgs, lib, ... }:
let
  qq = pkgs.callPackage ./qq/package.nix {
    libgbm = pkgs.mesa.drivers; # 显式传递 libgbm
    inherit (pkgs)
      alsa-lib
      libuuid
      cups
      dpkg
      fetchurl
      glib
      libssh2
      gtk3
      libayatana-appindicator
      libdrm
      libgcrypt
      libkrb5
      libnotify
      libpulseaudio
      libGL
      nss
      xorg
      systemd
      vips
      at-spi2-core
      autoPatchelfHook
      makeShellWrapper
      wrapGAppsHook3
      ;
    commandLineArgs = ""; # 可选参数
  };
  sources = import ./sources.nix { };

  srcs = {
    x86_64-linux = pkgs.fetchurl {
      url = sources.pmhq_amd64_url;
      hash = sources.pmhq_amd64_hash;
    };
    aarch64-linux = pkgs.fetchurl {
      url = sources.pmhq_arm64_url;
      hash = sources.pmhq_arm64_hash;
    };
  };

  currentSystem = pkgs.stdenv.hostPlatform.system;
  src = srcs.${currentSystem} or (throw "Unsupported system: ${currentSystem}");
in

pkgs.stdenv.mkDerivation rec {
  pname = "pmhq";
  version = "${sources.pmhq_version}";

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    unzip
    zlib
  ];

  inherit src;
  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv pmhq-linux-* $out/bin/source-pmhq
    chmod +x $out/bin/source-pmhq
    head -n -1 ${qq}/opt/QQ/qq > $out/bin/pmhq
    echo "$out/bin/source-pmhq ${qq}/opt/QQ/source-qq" >> $out/bin/pmhq
    chmod +x $out/bin/pmhq
  '';

  meta = with lib; {
    description = "Pure memory hook QQNT";
    homepage = "https://github.com/linyuchen/PMHQ";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
