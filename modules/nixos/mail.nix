{
  pkgs,
  ...
}: {
  programs.msmtp = {
    enable = true;
    setSendmail = true;
  };
  services = {
    offlineimap = {
      enable = true;
      install = true;
      path = with pkgs; [
        bash
        notmuch
        gnupg
        sops
      ];
    };
  };
}
