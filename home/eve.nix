{
  config,
  pkgs,
  profile,
  ...
} @ inputs:
let
  username = profile.username;
  homeDir = profile.homeDir;
in
{
  #imports = [ nixvim.homeManagerModules.nixvim ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDir;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = (with pkgs; [nixfmt htop ripgrep fd grit glab hut ]) ++ [ inputs.nixvim-pkgs.packages.nvim ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".doom.d" = {
      enable = true;
      source = dotfiles/doom.d;
      recursive = true;
    };
    ".config/fish/fish_plugins".source = dotfiles/fish/fish_plugins;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/eve/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.sessionPath = ["$HOME/.local/bin" "$HOME/.emacs.d/bin" "$HOME/.config/emacs/bin"];

  programs.fish = {
    enable = true;
    interactiveShellInit = "set -g fish_key_bindings fish_vi_key_bindings";
    plugins = [
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "4.4.4";
          hash = "sha256-e8gIaVbuUzTwKtuMPNXBT5STeddYqQegduWBtURLT3M=";
        };
      }
    ];
    shellAliases = {
      lstask = "grit ls";
      tasks = "grit tree";
      task = "grit stat";
      todays_tasks = "grit ls (date +%F)";
      rmtask = "grit rm";
      add_jira_task = "grit link jira";
      rm_jira_task = "grit unlink jira";
      finish_task = "grit check";
    };
    functions = {
      lntask = ''
        set -l options (fish_opt -s r -l rm)
        argparse --min-args=2 $options -- $argv

        if  test -n "$_flag_r" -o -n "$_flag_rm"
           set -l node_id $argv[1]
           for other_id in $argv[2..]
              grit unlink "$node_id" "$other_id"
           end
        else
          grit link $argv
        end
      '';
      newtask = {
        body = ''
          set -l options (fish_opt -s a -l alias -o)
          set options $options (fish_opt -s p -l predecessor -o)
          set options $options (fish_opt -s r -l root)
          set options $options (fish_opt -s l -l link --multiple-vals)
          set options $options (fish_opt -s c -l children --multiple-vals)
          argparse --min-args=1 -x"p,predecessor,r,root" $options -- $argv
          or return

          if test -n "$_flag_p"
              set -f grit_opts "-p=$_flag_p"
          end
          if test -n "$_flag_r"
              set -f grit_opts "-r"
          end

          set -l grit_out (grit add "$grit_opts" $argv)
          or return
          string match -g -r '\((?<node_id>\d+)\)$' "$grit_out" >/dev/null
          or return

          if test -n "$_flag_a"
              grit alias "$node_id" "$_flag_a"
          end

          for parent in $_flag_l
              grit link $parent $node_id
          end

          if test -n "$_flag_c"
              grit link $node_id $_flag_c
          end
          echo $node_id

        '';
      };
      task_aliases = "sqlite3 ~/.config/grit/graph.db 'SELECT node_alias FROM nodes WHERE node_alias IS NOT NULL;' '.exit'";
      get_tasks = "sqlite3 ~/.config/grit/graph.db 'SELECT node_id FROM nodes;' '.exit'";
      get_root_tasks = "sqlite3 ~/.config/grit/graph.db 'SELECT node_id FROM nodes WHERE node_id NOT IN (SELECT dest_id FROM links);' '.exit'";
      schtask = {
        body = ''
                set -l options (fish_opt -s d -l date -o)
                set options $options (fish_opt -s a -l alias -o)
                set options $options (fish_opt -s l -l link --multiple-vals)
                set options $options (fish_opt -s c -l children --multiple-vals)
                argparse $options -- $argv
                or return
          if test -n "$_flag_date"
                set -f node (data +%F -d"$_flag_date")
          else
                set -f current_weekday (date +%w)
                if test "$current_weekday" -eq 5
                    set -f offset 3
                else
                    set -f offset 1
                end
                set -f node (date +%F -d"$offset days")
          end
                set -f grit_opts "-p=$node"
                set -l grit_out (grit add "$grit_opts" $argv)
                or return
                string match -g -r '\((?<node_id>\d+)\)$' "$grit_out" >/dev/null
                or return

                if test -n "$_flag_a"
                    grit alias "$node_id" "$_flag_a"
                end

                for parent in $_flag_l
                    grit link $parent $node_id
                end

                if test -n "$_flag_c"
                    grit link $node_id $_flag_c
                end
                echo $node_id
        '';
      };
      fish_greeting = {
        body = ''
          echo Scheduled Tasks for the day:
          set -l _tasks (todays_tasks)
          if test -n "$_tasks"
              for i in $_tasks
                echo $i
              end
          else
              echo "Nothing scheduled!"
          end
        '';
      };
    };
  };
  programs.fzf.enable = true;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  personal.programs.git.enable = true;
  programs.git.enable = true;

  programs.emacs = {enable = true;};

  services.emacs = {
    enable = true;
    client.enable = true;
  };


  #  programs.neovim = {
  #enable = true;
  #defaultEditor = true;
  #viAlias = true;
  #vimAlias = true;
  #vimdiffAlias = true;
  #};
}
