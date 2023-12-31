{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, installShellFiles
, rustPlatform
}:
let
  version = "0.12.1-unstable-2023-12-30";
  assets = builtins.fromTOML (builtins.readFile ./assets.toml);
  mkSrcsFromTomlArray = tomlArray: lib.forEach tomlArray (x:
    fetchFromGitHub {
      inherit (x) owner rev repo;
      hash = x.nix-hash;
      name = x.repo;
    });
  syntaxesSrcs = mkSrcsFromTomlArray assets.syntaxes;
  themesSrcs = mkSrcsFromTomlArray assets.themes;
  oatmealSrc = fetchFromGitHub {
    name = "oatmeal";
    owner = "dustinblackman";
    repo = "oatmeal";
    rev = "f5aab048841b91a3db4e749e74b4652848b7f5e1";
    hash = "sha256-31QR9HSjZ4Fbj2a46uHUfr+EmQQktZmVs2gzYHhjZFI=";
  };
in
rustPlatform.buildRustPackage {
  pname = "oatmeal";
  inherit version;
  srcs = [ oatmealSrc ] ++ themesSrcs ++ syntaxesSrcs;
  sourceRoot = oatmealSrc.name;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ installShellFiles ];

  patches = [
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/dustinblackman/oatmeal/pull/32.diff?full_index=true";
      hash = "sha256-q5gE6OxkULGTUWqS7hrFqV+LwgToJpkiEgn2ydCU914=";
    })
  ];

  env = {
    VERGEN_IDEMPOTENT = 1;
  };

  doCheck = false;

  preBuild = ''
    OATMEAL_BUILD_DOWNLOADED_THEMES_DIR="$(mktemp -d)"
    export OATMEAL_BUILD_DOWNLOADED_THEMES_DIR
    OATMEAL_BUILD_DOWNLOADED_SYNTAXES_DIR="$(mktemp -d)"
    export OATMEAL_BUILD_DOWNLOADED_SYNTAXES_DIR
    for src in $srcs; do
      case $src in
        *base16-textmate) cp -r $src $OATMEAL_BUILD_DOWNLOADED_THEMES_DIR/''${src#*-} ;;
        *oatmeal) ;;
        *) cp -r $src $OATMEAL_BUILD_DOWNLOADED_SYNTAXES_DIR/''${src#*-}
      esac
    done
  '';

  postInstall = lib.optionalString (stdenv.hostPlatform.canExecute stdenv.buildPlatform) ''
    HOME="$(mktemp -d)"
    export HOME

    $out/bin/oatmeal manpages 1>oatmeal.1
    installManPage oatmeal.1

    installShellCompletion --cmd oatmeal \
      --bash <($out/bin/oatmeal completions -s bash) \
      --fish <($out/bin/oatmeal completions -s fish) \
      --zsh <($out/bin/oatmeal completions -s zsh)
  '';

  meta = {
    description = "Terminal UI to chat with large language models (LLM)";
    longDescription = ''
      Oatmeal is a terminal UI chat application that speaks with LLMs, complete with
      slash commands and fancy chat bubbles. It features agnostic backends to allow
      switching between the powerhouse of ChatGPT, or keeping things private with
      Ollama. While Oatmeal works great as a stand alone terminal application, it
      works even better paired with an editor like Neovim!
    '';
    homepage = "https://github.com/dustinblackman/oatmeal/";
    changelog = "https://github.com/dustinblackman/oatmeal/blob/main/CHANGELOG.md";
    downloadPage = "https://github.com/dustinblackman/oatmeal/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dustinblackman ];
    mainProgram = "oatmeal";
  };
}
