{
  borgmatic,
  lib,
  runCommand,
}:
let
  inherit (lib) getExe;
in
{
  mkBorgmaticCheck =
    name: content:
    runCommand "borgmatic-${name}-validation" { } ''
      cat 1>config <<EOF
      ${content}
      EOF

      ${getExe borgmatic} -c config config validate

      : 1>$out
    '';
}
