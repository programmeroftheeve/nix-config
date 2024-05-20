{
  description = "Eve's Nix Configuration for home-manager and NixOS";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixvim-personal = {
      url = "sourcehut:~btaidm/nixvim-config";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    flake-utils,
    home-manager,
    nixvim-personal,
    ...
  } @ args: let
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    nixvim-pkgs = with nixvim-personal; {
	packages = packages.${system};
    };
    top_level = ./.;
    lib = import ./lib;
    user_profiles = [
      {username = "eve";}
      {
        username = "ebradt";
        config = ./home/eve.nix;
      }
    ];
    system_profiles = [
      {
        hostname = "faraday";
        inherit system;
      }
      {
        hostname = "server-vm";
        inherit system;
      }
      {
        hostname = "faye";
        inherit system;
      }
    ];
    system_modules = with args; [];
    home_modules = with args; [
    ];
    my_modules = import ./modules;
  in {
    inherit lib;
    formatter.x86_64-linux = pkgs.alejandra;
    homeConfigurations =
      lib.genHomeConfigurations (
        let
          # inherit (args) nixvim stylix;
          modules = my_modules.home.modules ++ home_modules;
        in
          {
            inherit pkgs;
            inherit modules;
	    extraSpecialArgs = { inherit nixvim-pkgs; };
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
