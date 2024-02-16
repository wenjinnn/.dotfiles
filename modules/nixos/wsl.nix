{
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];
  wsl.enable = true;
  wsl.defaultUser = "${username}";
}
