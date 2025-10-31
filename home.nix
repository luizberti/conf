{
  config,
  pkgs,
  lib,
  home-manager,
  user, # FIXED: Accept user from specialArgs in flake.nix
  ...
}: let
  # user = "%USER%"; # FIXED: Commented out - using user from specialArgs instead
  name = "%NAME%"; # TODO: Replace with actual name or accept from specialArgs
  mail = "%EMAIL%"; # TODO: Replace with actual email or accept from specialArgs
  # Define the content of your file as a derivation
  # myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
  #   #!/bin/sh
  #   emacsclient -c -n &
  # '';
  # sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  # additionalFiles = import ./files.nix { inherit user config pkgs; };
in {
  # imports = [
  #  ./dock.nix
  # ];

  # Enable fish shell program
  programs.fish.enable = true;

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    # onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    masApps = {
      # "wireguard" = 1451685025;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = {
      pkgs,
      config,
      lib,
      ...
    }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./pkgs.nix {};
        file = lib.mkMerge [
          # sharedFiles
          # additionalFiles
          # { "emacs-launcher.command".source = myEmacsLauncher; }
        ];
        stateVersion = "23.11";
      };
      programs = {
        fish = {
          enable = true;
          shellInit = ''
            set --universal --export EDITOR               nvim
            set --universal --export DO_NOT_TRACK         1
            set --universal --export NIXPKGS_ALLOW_UNFREE 1
          '';
          shellAliases = {
            co = "container";
            ku = "kubectl";
            kc = "kubectx";
            kn = "kubens";

            vim = "nvim";
            http = "curlie";

            z = "zoxide";
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "....." = "cd ../../../..";

            gs = "git status";
            ls = "eza --group-directories-first";
            la = "eza --all --group-directories-first";
            ll = "eza --long --git --time-style=long-iso --group-directories-first";
            lls = "eza -la -s modified";
            lla = "ll --all";
            tre = "eza --all --classify --tree --group-directories-first --ignore-glob='.git|.jj|target|zig-out|.zig-cache|node_modules|.vscode|.idea'";
          };
          interactiveShellInit = ''
            # INITIALIZE INTEGRATIONS
            starship init fish | source
            zoxide init fish | source
            #atuin init fish | source
          '';
        };

        # git = {
        #   enable = true;
        #   ignores = [ "*.swp" ];
        #   userName = name;
        #   userEmail = email;
        #   lfs = {
        #     enable = true;
        #   };
        #   extraConfig = {
        #     init.defaultBranch = "main";
        #     core = {
        #       editor = "vim";
        #       autocrlf = "input";
        #     };
        #     pull.rebase = true;
        #     rebase.autoStash = true;
        #   };
        # };

        # neovim
        # ghostty

        # ssh = {
        #   enable = true;
        #   enableDefaultConfig = false;
        #   includes = [
        #     (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        #       "/home/${user}/.ssh/config_external"
        #     )
        #     (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        #       "/Users/${user}/.ssh/config_external"
        #     )
        #   ];
        #   matchBlocks = {
        #     "*" = {
        #       # Set the default values we want to keep
        #       sendEnv = [ "LANG" "LC_*" ];
        #       hashKnownHosts = true;
        #     };
        #     # Example SSH configuration for GitHub
        #     # "github.com" = {
        #     #   identitiesOnly = true;
        #     #   identityFile = [
        #     #     (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        #     #       "/home/${user}/.ssh/id_github"
        #     #     )
        #     #     (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        #     #       "/Users/${user}/.ssh/id_github"
        #     #     )
        #     #   ];
        #     # };
        #   };
        # };
      };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  # local.dock = {
  #   enable = true;
  #   username = user;
  #   entries = [
  #     { path = "/Applications/Safari.app/"; }
  #     { path = "/System/Applications/Messages.app/"; }
  #     { path = "/System/Applications/Notes.app/"; }
  #     {
  #       path = toString myEmacsLauncher;
  #       section = "others";
  #     }
  #     {
  #       path = "${config.users.users.${user}.home}/Downloads";
  #       section = "others";
  #       options = "--sort name --view grid --display stack";
  #     }
  #   ];
  # };
}
