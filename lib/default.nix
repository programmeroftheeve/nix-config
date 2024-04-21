let
  home_config_dir = ../home;
  system_config_dir = ../system;
  getConfigs = {
    username ? null,
    hostname ? null,
    ...
  }:
    {
    }
    // (
      if username != null
      then let
        user_config_path = home_config_dir + "/${username}.nix";
        user_dir_path = home_config_dir + "/${username}";
        user_host_config_path =
          home_config_dir
          + "/${username}${
            if builtins.isNull hostname
            then ""
            else "@${hostname}"
          }.nix";
        user_host_dir_config_path =
          home_config_dir
          + "/${username}${
            if builtins.isNull hostname
            then ""
            else "@${hostname}"
          }";
        config =
          if builtins.pathExists user_host_config_path
          then user_host_config_path
          else if builtins.pathExists user_host_dir_config_path
          then user_host_dir_config_path
          else if builtins.pathExists user_config_path
          then user_config_path
          else user_dir_path;

        home_config = import config;
      in {inherit home_config;}
      else {}
    )
    // (
      if hostname != null
      then let
        nix_config = system_config_dir + "/${hostname}.nix";
        dir_config = system_config_dir + "/${hostname}";
      in {
        system_config =
          import
          (
            if builtins.pathExists nix_config
            then nix_config
            else dir_config
          );
      }
      else {}
    );
  genProfileName = {
    username,
    hostname ? null,
    ...
  }:
    "${username}"
    + (
      if !builtins.isNull hostname
      then "@${hostname}"
      else ""
    );

  genSystemConf = {
    pkgs,
    modules ? [],
    specialArgs ? {},
    nixpkgs,
    ...
  }: profile @ {
    hostname,
    config ? ((getConfigs profile).system_config),
    profileName ? hostname,
    system,
    ...
  }: let
    args = {
      inherit system;
      pkgs = profile.pkgs or pkgs;
      modules = modules ++ (profile.additionalModules or []) ++ [config];
      specialArgs =
        specialArgs
        // (profile.specialArgs or {})
        // {
          inherit profile;
        };
    };
  in {
    name = profileName;
    value = nixpkgs.lib.nixosSystem {
      inherit (builtins.trace args args) system pkgs modules specialArgs;
    };
  };
  genHomeConf = {
    pkgs,
    modules ? [],
    extraSpecialArgs ? {},
    home-manager,
    ...
  }: profile @ {
    username,
    hostname ? null,
    homesDir ? "/home",
    homeDir ? "${homesDir}/${username}",
    config ? ((getConfigs profile).home_config),
    profileName ? (genProfileName profile),
    ...
  }: let
    args = {
      pkgs = profile.pkgs or pkgs;
      modules = modules ++ (profile.additionalModules or []) ++ [config];
      extraSpecialArgs =
        extraSpecialArgs
        // (profile.extraSpecialArgs or {})
        // {
          profile = {inherit username hostname profileName homeDir;};
        };
    };
  in {
    name = profileName;
    value = home-manager.lib.homeManagerConfiguration {
      inherit (args) pkgs modules extraSpecialArgs;
    };
  };
in rec {
  output = import ./output;
  overlays = import ./overlays.nix;
  genHomeConfigurations = {
    pkgs,
    home-manager,
    modules ? [],
    extraSpecialArgs ? {},
    ...
  } @ inputs: profiles:
    builtins.listToAttrs (map (genHomeConf inputs) profiles);
  genSystemConfigurations = {
    pkgs,
    home-manager,
    modules ? [],
    specialArgs ? {},
    ...
  } @ inputs: profiles:
    builtins.listToAttrs (map (genSystemConf inputs) profiles);
}
