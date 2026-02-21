{ pkgs }: pkgs.mkShell {
  buildInputs = with pkgs; [
    nmap
    masscan
    netcat-openbsd
    nikto
    nuclei
    gobuster
    ffuf
    curl
    wget
    dnsutils  # dig nslookup
    whois
    metasploit
    exploitdb  # searchsploit
    enum4linux
    smbmap
    hydra
  ];

  shellHook = ''
    NAME="recon"
    ${builtins.readFile ./nix-develop-stack.sh}
    alias nmap-quick="nmap -sS -T4 --top-ports 1000"
    alias nmap-full="nmap -sS -p- -T4"
    alias nmap-version="nmap -sV -sC"
    alias nmap-vuln="nmap --script vuln"
    alias nmap-stealth="nmap -sS -T2 -f --data-length 24"
    echo "[Tools]"
    echo "  nmap, masscan, netcat, nikto, nuclei"
    echo "  gobuster, ffuf, searchsploit, hydra"
    echo "[Aliases]"
    echo "  nmap-quick    - Top 1000 ports SYN scan"
    echo "  nmap-full     - All ports SYN scan"
    echo "  nmap-version  - Version + default scripts"
    echo "  nmap-vuln     - Vuln NSE scripts"
    echo "  nmap-stealth  - Fragmented slow scan"
  '';
}
