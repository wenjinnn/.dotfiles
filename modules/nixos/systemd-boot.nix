{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
        consoleMode = "keep";
      };
    };
  };
}
