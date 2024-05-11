let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.11";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    terrascan
    terraform-docs
    terragrunt
    checkov
    trivy
    jq
    tflint
    tfupdate
  ];
}
