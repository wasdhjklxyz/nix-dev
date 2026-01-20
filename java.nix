{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [
    jdk25
    jdt-language-server
  ];
  shellHook = ''
    NAME="java"
    ${builtins.readFile ./nix-develop-stack.sh}
    JAVA_HOME="${pkgs.jdk25}"
    java --version
  '';
}
