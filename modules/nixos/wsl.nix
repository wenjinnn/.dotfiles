{
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];
  wsl = {
    enable = true;
    defaultUser = "${username}";
    startMenuLaunchers = true;
  };
}
