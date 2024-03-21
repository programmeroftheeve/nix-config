{
  description = "Eve's Nix Configuration for home-manager and NixOS";

  inputs = {

    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
#    nixvim = {
#      url = "github:nix-community/nixvim/release-23.11";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
    flake-utils.url = "github:numtide/flake-utils";
    stylix.url = "github:danth/stylix";
  };

  outputs = { nixpkgs, nixpkgs-unstable, flake-utils, home-manager,  ...
    }@inputs:
    let system = "x86_64-linux";
    in {

      homeConfigurations."eve" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ 
#	nixvim.homeManagerModules.nixvim 
	./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
#          nixvim = nixvim;
        };
      };
    };
}
