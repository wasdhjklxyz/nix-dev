{ pkgs }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-medium
      latexmk
      biber
      biblatex
      moderncv
      fontawesome5
      academicons
      csquotes
      xpatch
      enumitem
      ;
  };

  zathurarc = pkgs.writeText "zathurarc" ''
    set synctex true
    set synctex-editor-command "texlab inverse-search -i %{input} -l %{line}"
  '';

  zathura-configured = pkgs.writeShellScriptBin "zathura" ''
    exec ${pkgs.zathura}/bin/zathura --config-dir=${pkgs.runCommand "zathura-config" {} ''
      mkdir -p $out
      ln -s ${zathurarc} $out/zathurarc
    ''} "$@"
  '';
in pkgs.mkShell {
  buildInputs = with pkgs; [
    texlab
    biber
    tree-sitter
    nodejs
    go
  ] ++ [ tex zathura-configured ];
  shellHook = ''
    NAME="LaTeX"
    ${builtins.readFile ./nix-develop-stack.sh}
  '';
}
