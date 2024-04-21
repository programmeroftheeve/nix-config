{system, ...} @ inputs: {
  builderOverlay = final: prev: {
    mkHomeConf = {
      pkgs ? f,
      extraPkgs ? [],
    }:
      import ./outputs/mkHomeConfig.nix {inherit extraPkgs inputs pkgs system;};
    mkSystemConf = {pkgs ? f}:
      import ./outputs/mkSystemConfig.nix {inherit inputs pkgs system;};
  };
}
