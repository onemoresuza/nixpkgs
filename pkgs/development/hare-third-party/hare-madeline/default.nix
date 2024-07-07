{
  fetchFromSourcehut,
  hareHook,
  lib,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hare-madeline";
  version = "0.1-unstable-2024-05-05";

  src = fetchFromSourcehut {
    owner = "~ecs";
    repo = "madeline";
    rev = "c693a0a797849cff0ac629c83e21f028fa60bff6";
    hash = "sha256-ncPenYhYYLGMZHrEgaq7ISbeEUKzmF2cRSl2iRaMGP4=";
  };

  nativeBuildInputs = [ hareHook ];

  doCheck = true;

  dontConfigure = true;
  dontBuild = true;

  checkPhase = ''
    runHook preCheck

    hare test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/src/hare/third-party
    cp -r ./made ./graph $out/src/hare/third-party

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Tiny readline-alike with some bateries included";
    homepage = "https://sr.ht/~ecs/madeline/";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ onemoresuza ];
    inherit (hareHook.meta) platforms badPlatforms;
  };
})
