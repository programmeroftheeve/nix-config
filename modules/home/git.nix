{
  config,
  lib,
  pkgs,
  ...
} @ args: {
  options.personal.programs.git = {
    enable = lib.mkEnableOption "personal git configuration";
  };

  config = lib.mkIf config.personal.programs.git.enable {
    home.packages = with pkgs; [
      git-filter-repo
    ];
    programs.git = {
      enable = true;
    };
  };
}
