{
  environment.shellAliases = {
    # Passe den Pfad zu deinem Repo an, falls anders:
    rebuild = "sudo nixos-rebuild switch --flake /home/luna/nixos#nixos";
    update  = "cd /home/luna/nixos && nix flake update && cd -";
  };
}

