HOSTNAME = $(if $(host),$(host),$(shell hostname))
USER = $(if $(user),$(user),$(shell whoami))
SUDO = $(if $(askpass),sudo -A,sudo)
all:
	$(SUDO) nixos-rebuild switch --flake .#$(HOSTNAME) && home-manager switch --flake .#$(USER)@$(HOSTNAME) -b backup
home:
	home-manager switch --flake .#$(USER)@$(HOSTNAME) -b backup
system:
	$(SUDO) nixos-rebuild switch --flake .#$(HOSTNAME)
