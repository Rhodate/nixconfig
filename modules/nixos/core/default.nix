{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.swarm.core = with types; {
    enable = mkOption {
      description = "Enable core nix options";
      type = types.bool;
      default = true;
    };
    timezone = mkOption {
      type = types.str;
      default = "America/New_York";
    };

    locale = {
      main = mkOption {
        description = "The main system locale";
        type = with types; str;
        default = "en_US.UTF-8";
      };

      misc = mkOption {
        description = "Other supported locales";
        type = with types; listOf str;
        default = [];
      };
    };
  };

  config = let
    cfg = config.swarm.core;
  in
    mkIf cfg.enable {
      programs.nix-ld.enable = true;
      security.rtkit.enable = true;
      hardware.enableAllFirmware = true;
      environment.systemPackages = with pkgs; [
        home-manager
        swarm.gamescope-launcher
        snowfallorg.flake
        age
      ];
      nixpkgs.config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "dotnet-sdk-7.0.410"
        ];
      };
      nix.package = pkgs.lix;
      time.timeZone = cfg.timezone;
      i18n = {
        defaultLocale = cfg.locale.main;
        supportedLocales = ["${cfg.locale.main}/UTF-8"] ++ (builtins.map (l: "${l}/UTF-8") cfg.locale.misc);
        extraLocaleSettings = {
          LC_CTYPE = cfg.locale.main;
          LC_NUMERIC = cfg.locale.main;
          LC_TIME = cfg.locale.main;
          LC_COLLATE = cfg.locale.main;
          LC_MONETARY = cfg.locale.main;
          LC_MESSAGES = cfg.locale.main;
          LC_PAPER = cfg.locale.main;
          LC_NAME = cfg.locale.main;
          LC_ADDRESS = cfg.locale.main;
          LC_TELEPHONE = cfg.locale.main;
          LC_MEASUREMENT = cfg.locale.main;
          LC_IDENTIFICATION = cfg.locale.main;
        };
      };
    };
}
