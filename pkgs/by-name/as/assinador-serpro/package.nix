{
  buildFHSEnv,
  dpkg,
  fetchurl,
  lib,
  openjdk8,
  stdenv,
  wmname,
  writeShellApplication,
  tokenLibs ? [ pcsc-safenet ],
  pcsc-safenet,
}:
let
  version = "4.3.2";
  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://assinadorserpro.estaleiro.serpro.gov.br/repository/pool/stable/assinador-serpro_${version}_amd64.deb";
        hash = "sha256-D8S3ZUm/gigcQ95EOjvu/vcFnYU7KxhGpBDrVDSI/gw=";
      }
    else
      builtins.throw "assinador-serpro is not supported on ${stdenv.hostPlatform.system}";

  binScript = writeShellApplication {
    name = "assinador-serpro";
    text = ''
      export AWT_TOOLKIT="MToolkit"
      wmname LG3D
      cd /opt/serpro/tool/serpro-signer
      exec -a "$0" ./assinador-serpro "$@"
    '';
  };

  drv = stdenv.mkDerivation {
    pname = "assinador-serpro";
    inherit version src;

    nativeBuildInputs = [ dpkg ];

    postPatch = ''
      sed -i 's#^\(Exec\)=.*$#\1=assinador-serpro#' \
        ./usr/share/applications/serpro-signer.desktop
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -av ./etc $out
      cp -av ./usr/share $out
      cp -av ./opt $out
      rm $out/opt/serpro/tool/serpro-signer/jre_64/bin/java
      ln -sf ${lib.getExe openjdk8} $out/opt/serpro/tool/serpro-signer/jre_64/bin/java

      runHook postInstall
    '';
  };
in
buildFHSEnv {
  pname = "assinador-serpro";

  inherit version;

  targetPkgs =
    _pkgs:
    [
      binScript
      drv
      wmname
    ]
    ++ tokenLibs;

  runScript = "assinador-serpro";

  meta = {
    description = "Serpro signing software";
    homepage = "https://www.serpro.gov.br/links-fixos-superiores/assinador-digital/assinador-serpro";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ onemoresuza ];
    mainProgram = binScript.name;
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      binaryBytecode
    ];
    platforms = lib.intersectLists lib.platforms.linux lib.platforms.x86_64;
  };
}
