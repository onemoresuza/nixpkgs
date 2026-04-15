{
  stdenv,
  buildFHSEnv,
  writeShellApplication,
  fetchurl,
  lib,
  openssl,
  unzip,
  xorg,
  pcsclite,
  glib,
  gtk3,
  libappindicator-gtk3,
  pcsc-safenet,
  tokenLibs ? [ pcsc-safenet ],
}:
let
  inherit (builtins) attrValues;
  inherit (lib)
    intersectLists
    licenses
    maintainers
    platforms
    sourceTypes
    ;
  version = "2.5.16u";
  src = fetchurl {
    url = "https://pje-office.pje.jus.br/pro/pjeoffice-pro-v${version}-linux_x64.zip";
    hash = "sha256-YIc5F1nHy6Efte+BX+i+kXE7RqhgfBLrZkqdmmiCxMc=";
  };
  runScript = writeShellApplication {
    name = "pjeoffice-pro";
    text = ''
      cd /opt/pjeoffice-pro
      ./pjeoffice-pro.sh
    '';
  };
  pkg = stdenv.mkDerivation {
    pname = "pjeoffice-pro";
    inherit version src;

    patches = [ ./001-fix-script.patch ];

    nativeBuildInputs = [ unzip ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/pjeoffice-pro
      cp -av ./* $out/opt/pjeoffice-pro
      chmod 0755 $out/opt/pjeoffice-pro/pjeoffice-pro.sh
      chmod 0755 $out/opt/pjeoffice-pro/ffmpeg.exe
      chmod 0755 $out/opt/pjeoffice-pro/jre/bin/*

      runHook postInstall
    '';
  };
in
buildFHSEnv {
  inherit (pkg) pname version;

  targetPkgs =
    _pkgs:
    [
      pkg
      openssl
      pcsclite.lib
      glib
      gtk3
      libappindicator-gtk3
      runScript
    ]
    ++ tokenLibs
    ++ attrValues {
      inherit (xorg)
        libXext
        libX11
        libXrender
        libXtst
        libXi
        ;
    };
  runScript = runScript.name;

  meta = {
    description = "CNJ software to access the PJE";
    homepage = "https://pjeoffice.trf3.jus.br/pjeoffice-pro/docs/index.html";
    license = licenses.unfree;
    maintainers = attrValues {
      inherit (maintainers) onemoresuza;
    };
    mainProgram = runScript.name;
    sourceProvenance = attrValues {
      inherit (sourceTypes) binaryBytecode binaryNativeCode;
    };
    platforms = intersectLists platforms.linux platforms.x86_64;
  };
}
