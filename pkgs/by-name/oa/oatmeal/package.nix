{ lib
, stdenv
, fetchFromGitHub
, installShellFiles
, rustPlatform
, substituteAll
}:
let
  version = "0.12.1";
  # Absolute pathes are needed or the paths will have `src/domain/services/`
  # prefixed to it
  themes_dir = "/build/${srcs.oatmeal.name}/";
  syntaxes_dir = "/build/${srcs.oatmeal.name}/syntaxes";
  sytaxesSrcsDirs =
    let
      onlySyntaxesSrcs = lib.filterAttrs (n: _v: !(builtins.elem n [ "oatmeal" "themes" ])) srcs;
      dirs = lib.concatStringsSep " " (lib.forEach (builtins.attrValues onlySyntaxesSrcs) (x: "${x}"));
    in
    dirs;
  srcs = {
    oatmeal = fetchFromGitHub {
      name = "oatmeal";
      owner = "dustinblackman";
      repo = "oatmeal";
      rev = "v${version}";
      hash = "sha256-eKEYEPW0TOwTiIl1z2ntph4Hf8CHtHIXVPrvJXhtMQs=";
    };
    themes = fetchFromGitHub {
      name = "base16-textmate";
      owner = "chriskempson";
      repo = "base16-textmate";
      rev = "0e51ddd568bdbe17189ac2a07eb1c5f55727513e";
      hash = "sha256-reYGXrhhHNSp/1k6YJ2hxj4jnJQCDgy2Nzxse2PviTA=";
    };
    # Syntaxes
    sublime-packages = fetchFromGitHub {
      name = "sublime-packages";
      owner = "sublimehq";
      repo = "Packages";
      rev = "759d6eed9b4beed87e602a23303a121c3a6c2fb3";
      hash = "sha256-0qadXgGwa3RxUxa6RAQWg933oFvJooWtK7BUx8RwAy0=";
    };
    bat = fetchFromGitHub {
      name = "bat";
      owner = "sharkdp";
      repo = "bat";
      rev = "7658334645936d2a956fb19aa96e6fca849cb754";
      hash = "sha256-4IFtaji8ymuGSE1OeMC9by8OJVhbrXXlgkQlusrAAIs=";
    };
    GraphQL-SublimeText3 = fetchFromGitHub {
      name = "GraphQL-SublimeText3";
      owner = "dncrews";
      repo = "GraphQL-SublimeText3";
      rev = "9b6f6d0a86d7e7ef1d44490b107472af7fb4ffaf";
      hash = "sha256-PTM61P5dObqR0hdMZIg5bXxinPPFQNFm61WiDxXiP2M=";
    };
    protobuf-syntax-highlighting = fetchFromGitHub {
      name = "protobuf-syntax-highlighting";
      owner = "VcamX";
      repo = "protobuf-syntax-highlighting";
      rev = "726e21d74dac23cbb036f2fbbd626decdc954060";
      hash = "sha256-kYVvcz4kTWZTrjaJzdsbO5chhN56fvu4iD6Y0E5Dj68=";
    };
    sublime-zig-language = fetchFromGitHub {
      name = "sublime-zig-language";
      owner = "ziglang";
      repo = "sublime-zig-language";
      rev = "1a4a38445fec495817625bafbeb01e79c44abcba";
      hash = "sha256-buQKVIBcwicTFjmtkIDiy6VjkOlKXep47Ol5hk6eNlo=";
    };
    "Terraform.tmLanguage" = fetchFromGitHub {
      name = "Terraform.tmLanguage";
      owner = "alexlouden";
      repo = "Terraform.tmLanguage";
      rev = "54d8350c3c5929c921ea7561c932aa15e7d96c48";
      hash = "sha256-cV8eqSi4AkG3JpeJaOV78V6Mg2RHPL7KuJS8+F8rRDI=";
    };
    sublime_toml_highlighting = fetchFromGitHub {
      name = "sublime_toml_highlighting";
      owner = "jasonwilliams";
      repo = "sublime_toml_highlighting";
      rev = "fd0bf3e5d6c9e6397c0dc9639a0514d9bf55b800";
      hash = "sha256-/9RCQNWpp2j/u4o6jBCPN3HEuuR4ow3h+0Zj+Cbteyc=";
    };
    elixir-sublime-syntax = fetchFromGitHub {
      name = "elixir-sublime-syntax";
      owner = "princemaple";
      repo = "elixir-sublime-syntax";
      rev = "4fb01891dd17434dde42887bc821917a30f4e010";
      hash = "sha256-R1e6RjirSsCx3uZoEOPpj5/NXZ2Gw48IyHOFW/7GOmY=";
    };
    sublime-text-gleam = fetchFromGitHub {
      name = "sublime-text-gleam";
      owner = "digitalcora";
      repo = "sublime-text-gleam";
      rev = "0b032f78c9c4aec1c598da1d25c67ca21fa8c381";
      hash = "sha256-5QHjrik+RozACSRuuC9ltM3qHYFh5CdQZuJXJO/EWBQ=";
    };
  };
in
rustPlatform.buildRustPackage {
  pname = "oatmeal";
  inherit version;
  srcs = builtins.attrValues srcs;
  sourceRoot = "${srcs.oatmeal.name}";

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "dirs-sys-0.4.1" = "sha256-ywihWgEZ/dKO6ggnf66FKqiUY0bOjmgwN0Uyw45ZBI4=";
    };

  };

  nativeBuildInputs = [ installShellFiles ];

  buildFeatures = [ "manpages" ];

  patches = [
    # Get themes and syntaxes from a nix source instead of trying to download
    # them from within the sandbox.
    (substituteAll {
      src = ./001-get-themes-and-syntaxes-from-nix-src.patch;
      # Absolute paths are needed or the paths will have `src/domain/services/`
      # prefixed to them
      inherit themes_dir;
      inherit syntaxes_dir;
    })
  ];

  env = {
    VERGEN_IDEMPOTENT = 1;
  };

  doCheck = false;

  preBuild = ''
    cp -r ${srcs.themes}/Themes ${themes_dir}
    mkdir ${syntaxes_dir}
    cp -r ${sytaxesSrcsDirs} ${syntaxes_dir}
  '';

  postInstall = lib.optionalString (stdenv.hostPlatform.canExecute stdenv.buildPlatform) ''
    HOME="$(mktemp -d)"
    export HOME

    mkdir manpages
    $out/bin/oatmeal debug manpages
    installManPage manpages/*.[[:digit:]]

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
