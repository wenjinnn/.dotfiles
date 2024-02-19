{ pkgs, ... } : {
  home.packages = with pkgs; [
    (python311.withPackages (p: [ p.python-pam ]))
  ];
}
