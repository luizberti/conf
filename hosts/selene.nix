{
  config,
  pkgs,
  user, # FIXED: Accept user from specialArgs in flake.nix
  ...
}: let
  # user = "%USER%"; # FIXED: Commented out - using user from specialArgs instead
in {
  imports = [
    ../../modules/darwin/home-manager.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
  };

  nix.enable = false;

  # NOTE: /etc/nix/nix.custom.conf
  determinate-nix.customSettings = {
    eval-cores = 0;
    extra-experimental-features = [
      "build-time-fetch-tree"
      "parallel-eval"
    ];

    trusted-users = ["@admin" "${user}"];
    substituters = ["https://nix-community.cachix.org" "https://cache.nixos.org"];
    trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
  };

  # nix = {
  #   package = pkgs.nix;
  #   settings = {
  #     trusted-users = ["@admin" "${user}"];
  #     substituters = ["https://nix-community.cachix.org" "https://cache.nixos.org"];
  #     trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
  #   };
  #   gc = {
  #     automatic = true;
  #     interval = {
  #       Weekday = 0;
  #       Hour = 2;
  #       Minute = 0;
  #     };
  #     options = "--delete-older-than 30d";
  #   };
  #   extraOptions = ''
  #     experimental-features = nix-command flakes
  #   '';
  # };

  environment.systemPackages = with pkgs;
    [
      # TODO: add packages specific to this host
      cowsay
    ]
    ++ (import ../pkgs.nix {inherit pkgs;});

  # launchd.user.agents.emacs.path = [ config.environment.systemPath ];
  # launchd.user.agents.emacs.serviceConfig = {
  #   KeepAlive = true;
  #   ProgramArguments = [
  #     "/bin/sh"
  #     "-c"
  #     "/bin/wait4path ${pkgs.emacs}/bin/emacs && exec ${pkgs.emacs}/bin/emacs --fg-daemon"
  #   ];
  #   StandardErrorPath = "/tmp/emacs.err.log";
  #   StandardOutPath = "/tmp/emacs.out.log";
  # };

  # https://nix-darwin.github.io/nix-darwin/manual/#opt-users.users
  users.users.${user} = {
    # name = user;
  };

  system = {
    stateVersion = 5;
    checks.verifyNixPath = false;
    primaryUser = user;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

        # "com.apple.mouse.tapBehavior" = 1;
        # "com.apple.sound.beep.volume" = 0.0;
        # "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        tilesize = 48;
        autohide = true;
        launchanim = true;
        show-recents = false;
        orientation = "bottom";
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
