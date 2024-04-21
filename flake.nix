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
    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    home-manager,
    ...
  } @ args: let
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    top_level = ./.;
    lib = import ./lib;
    user_profiles = [{username = "eve";}];
    system_profiles = [
      {
        hostname = "faraday";
        inherit system;
      }
      {
        hostname = "server-vm";
        inherit system;
      }
    ];

    my_modules = import ./modules;
  in {
    inherit lib;
    formatter.x86_64-linux = pkgs.alejandra;
    homeConfigurations =
      lib.genHomeConfigurations (
        let
          inherit (args) nixvim stylix;
          modules = my_modules.home.modules ++ [nixvim.homeManagerModules.nixvim stylix.homeManagerModules.stylix];
        in
          {
            inherit pkgs;
            inherit modules;
          }
          // args
      )
      user_profiles;
    nixosConfigurations = lib.genSystemConfigurations ({
        inherit pkgs;
        inherit (my_modules.system) modules;
      }
      // args)
    system_profiles;
  };
}
