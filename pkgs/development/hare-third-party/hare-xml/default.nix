{
  fetchFromSourcehut,
  hareHook,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "hare-xml";
  version = "0-unstable-2023-12-31";
  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "hare-xml";
    rev = "82ad30e1143286417b12b00d45ee1a03330f117e";
    hash = "sha256-y0N0BxEJZ8E119MdOVay2DpAogA9DLVm7pk0RL7MPH4=";
  };

  nativeBuildInputs = [ hareHook ];

  makeFlags = [ "PREFIX=${builtins.placeholder "out"}" ];

  doCheck = true;
}
