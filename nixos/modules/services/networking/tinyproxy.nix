{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tinyproxy;
  mkValueStringTinyproxy = with lib; v:
        if true  ==   v then "yes"
        else if false ==   v then "no"
        else generators.mkValueStringDefault {} v;

  # dont use the "=" operator
  settingsFormat = (pkgs.formats.keyValue {
      mkKeyValue = lib.generators.mkKeyValueDefault {
        mkValueString = mkValueStringTinyproxy;
      } " ";
      listsAsDuplicateKeys= true;
  });
  configFile = settingsFormat.generate "tinyproxy.conf" cfg.settings;
in
  {

    options = {
      services.tinyproxy = {
        enable = mkEnableOption (lib.mdDoc "Tinyproxy daemon");
        package = mkOption {
          description = lib.mdDoc "Tinyproxy package to use.";
          default = pkgs.tinyproxy;
          type = types.package;
        };
        settings = mkOption {
          description = lib.mdDoc "Configuration for [tinyproxy](https://tinyproxy.github.io/).";
          default = { };
          example = literalExpression ''{
            Port 8888;
            Listen 127.0.0.1;
            Timeout 600;
            Allow 127.0.0.1;
            Anonymous = [''"Host"'' ''"Authorization"''];
            ReversePath = ''"/example/" "http://www.example.com/"'';
          }'';
          type = types.submodule ({name, ...}: {
            freeformType = settingsFormat.type;
            options = {
              Listen = mkOption {
                type = types.str;
                default = "127.0.0.1";
                description = lib.mdDoc ''
                Specify which address to listen to.
                '';
              };
              Port = mkOption {
                type = types.int;
                default = 8888;
                description = lib.mdDoc ''
                Specify which port to listen to.
                '';
              };
            };
          });
        };
      };
    };
    config = mkIf cfg.enable {
      systemd.services.tinyproxy = {
        description = "TinyProxy daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "tinyproxy";
          Group = "tinyproxy";
          Type = "simple";
          #PIDFile="/var/run/tinyproxy.pid";
          ExecStart = "${getExe pkgs.tinyproxy} -d -c ${configFile}";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";
          KillSignal = "SIGINT";
          TimeoutStopSec = "30s";
          Restart = "on-failure";
        };
      };

      users.users.tinyproxy = {
          group = "tinyproxy";
          isSystemUser = true;
      };
      users.groups.tinyproxy = {};
    };
  }
