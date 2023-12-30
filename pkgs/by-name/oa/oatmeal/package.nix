{
system ? builtins.currentSystem
, pkgs
, lib
, fetchurl
, installShellFiles
}:
let
  shaMap = {
    x86_64-linux = "0x4dn7g04ny2asw38059ida3044wps6cplgg63sf5pz9qz74i9v8";
    aarch64-linux = "12i3agydmvqws01cki42kcms0jbf7pyhx8qkld6r5s8vs5ydg2nf";
    x86_64-darwin = "1sijvqxkr0vpvqhfjlbdyllrzvv5c3ckf2fw2cfjzc2j1mamci4r";
    aarch64-darwin = "1hncfa8598kv9wa3n090avvzd2pa67axq9ggvnz48ssp9fr4w7ar";
  };

  urlMap = {
    x86_64-linux = "https://github.com/dustinblackman/oatmeal/releases/download/v0.12.1/oatmeal_0.12.1_linux_amd64.tar.gz";
    aarch64-linux = "https://github.com/dustinblackman/oatmeal/releases/download/v0.12.1/oatmeal_0.12.1_linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/dustinblackman/oatmeal/releases/download/v0.12.1/oatmeal_0.12.1_darwin_amd64.tar.gz";
    aarch64-darwin = "https://github.com/dustinblackman/oatmeal/releases/download/v0.12.1/oatmeal_0.12.1_darwin_arm64.tar.gz";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "oatmeal";
  version = "0.12.1";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./oatmeal $out/bin/oatmeal
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $out/bin/oatmeal
    mkdir -p $out/share/doc/oatmeal/copyright
    cp LICENSE $out/share/doc/oatmeal/copyright/
    cp THIRDPARTY.html $out/share/doc/oatmeal/copyright/
    installManPage ./manpages/oatmeal.1.gz
    installShellCompletion ./completions/*
  '';

  system = system;

  meta = with lib; {
    description = "Terminal UI to chat with large language models (LLM) using backends such as Ollama, and direct integrations with your favourite editor like Neovim!";
    homepage = "https://github.com/dustinblackman/oatmeal";
    license = lib.licenses.mit;
    maintainers = with maintainers; [ dustinblackman ];

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
