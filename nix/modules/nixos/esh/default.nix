{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with types; let
  templates = config.swarm.esh.templates;
  templateOpts = {
    name,
    config,
    ...
  }: {
    options = {
      template = mkOption {
        type = types.lines;
        description = "The esh template to apply.";
      };
      destination = mkOption {
        type = types.nonEmptyStr;
        description = "Path to the destination location.";
      };
    };
  };
in {
  options.swarm.esh.templates = mkOption {
    default = {};
    description = "List of templates to apply";
    type = attrsOf (submodule [templateOpts]);
  };

  config = mkIf (templates != {}) {
    systemd.services =
      concatMapAttrs (name: templateOpts: {
        "${name}-swarm-template" = {
          description = "Applies a template file to a target path.";
          after = ["network.target"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
          script = ''
            ${pkgs.uutils-coreutils}/bin/uutils-mkdir -p $(dirname ${templateOpts.destination})
            ${pkgs.esh}/bin/esh \
              -o ${templateOpts.destination} \
              -s ${pkgs.zsh}/bin/zsh \
              ${pkgs.writeText "templates/${name}" templateOpts.template}
          '';
        };
      })
      templates;
  };
}
