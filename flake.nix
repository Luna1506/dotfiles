{
  description = "Modulares NixOS-Setup (Host: nixos) mit Home Manager-Option";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim = {
      url = "github:Gako358/neovim?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      nixos = let
        system = "x86_64-linux";
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };  # damit modules auf 'inputs' zugreifen können
        modules = [
          ./hosts/laptop/default.nix

          # Home Manager als NixOS-Modul (optional & empfohlen)
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.luna = import ./home/luna/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
  };
}

