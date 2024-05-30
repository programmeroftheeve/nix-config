{
  config,
  lib,
  pkgs,
  nixvim-pkgs,
  ...
} @ args: let
  cfg = config.personal.programs.nixvim;
  stylix-cfg = config.stylix.targets.personal.nixvim;
  nvim' = nixvim-pkgs.packages.nvim;
  inherit (lib) types mkOption mkEnableOption;
in {
  options = {
    stylix.targets.personal.nixvim = {
      enable = config.lib.stylix.mkEnableTarget "nixvim" (config.personal.programs ? nixvim);
      transparent_bg = {
        main = lib.mkEnableOption "background transparency for the main NeoVim window";
        sign_column = lib.mkEnableOption "background transparency for the NeoVim sign column";
      };
    };

    personal.programs.nixvim = {
      enable = lib.mkEnableOption "nixvim";
      viAlias = lib.mkOption {
        type = types.bool;
        default = false;
        description = ''
          Symlink `vi` to `nvim` binary.
        '';
      };

      vimAlias = lib.mkOption {
        type = types.bool;
        default = false;
        description = ''
          Symlink `vim` to `nvim` binary.
        '';
      };
      defaultEditor = mkEnableOption "nixvim as the default editor";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        (nvim'.nixvimExtend (
          {
            inherit (cfg) viAlias vimAlias;
          } //
          (lib.mkIf stylix-cfg.enable {
            colorschemes.base16 = {
              colorscheme = let
                colors = config.lib.stylix.colors.withHashtag;
              in {
                base00 = colors.base00;
                base01 = colors.base01;
                base02 = colors.base02;
                base03 = colors.base03;
                base04 = colors.base04;
                base05 = colors.base05;
                base06 = colors.base06;
                base07 = colors.base07;
                base08 = colors.base08;
                base09 = colors.base09;
                base0A = colors.base0A;
                base0B = colors.base0B;
                base0C = colors.base0C;
                base0D = colors.base0D;
                base0E = colors.base0E;
                base0F = colors.base0F;
              };
              enable = true;
            };

            highlight = let
              transparent = {
                bg = "none";
                ctermbg = "none";
              };
            in {
              Normal = lib.mkIf stylix-cfg.transparent_bg.main transparent;
              NonText = lib.mkIf stylix-cfg.transparent_bg.main transparent;
              SignColumn = lib.mkIf stylix-cfg.transparent_bg.sign_column transparent;
            };
          })
        ))
      ];
    }
    {
      home.sessionVariables = lib.mkIf cfg.defaultEditor {EDITOR = "nvim";};
    }
  ]);
}
