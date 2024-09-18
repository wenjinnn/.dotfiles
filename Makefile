HOSTNAME = $(if $(host),$(host),$(shell hostname))
USER = $(if $(user),$(user),$(shell whoami))
all:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME) && home-manager switch --flake .#$(USER)@$(HOSTNAME) -b backup
home:
	home-manager switch --flake .#$(USER)@$(HOSTNAME) -b backup
system:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)
