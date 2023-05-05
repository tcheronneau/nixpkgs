{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tinyproxy;
  mkValueStringTinyproxy = with lib; v:
<<<<<<< HEAD
        if true  ==         v then "yes"
        else if false ==    v then "no"
        else generators.mkValueStringDefault {} v;
  mkKeyValueTinyproxy = {
    mkValueString ? mkValueStringDefault {}
  }: sep: k: v:
    if null     ==  v then ""
    else "${lib.strings.escape [sep] k}${sep}${mkValueString v}";

  settingsFormat = (pkgs.formats.keyValue {
      mkKeyValue = mkKeyValueTinyproxy {
=======
        if true  ==   v then "yes"
        else if false ==   v then "no"
        else generators.mkValueStringDefault {} v;

  # dont use the "=" operator
  settingsFormat = (pkgs.formats.keyValue {
      mkKeyValue = lib.generators.mkKeyValueDefault {
>>>>>>> 7a5de09c3da529a5680317e795ffd3a904662096
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
<<<<<<< HEAD
        package = mkPackageOptionMD pkgs "tinyproxy" {}; 
=======
        package = mkOption {
          description = lib.mdDoc "Tinyproxy package to use.";
          default = pkgs.tinyproxy;
          type = types.package;
        };
>>>>>>> 7a5de09c3da529a5680317e795ffd3a904662096
        settings = mkOption {
          description = lib.mdDoc "Configuration for [tinyproxy](https://tinyproxy.github.io/).";
          default = { };
          example = literalExpression ''{
            Port 8888;
            Listen 127.0.0.1;
            Timeout 600;
            Allow 127.0.0.1;
<<<<<<< HEAD
            Anonymous = ['"Host"' '"Authorization"'];
            ReversePath = '"/example/" "http://www.example.com/"';
=======
            Anonymous = [''"Host"'' ''"Authorization"''];
            ReversePath = ''"/example/" "http://www.example.com/"'';
>>>>>>> 7a5de09c3da529a5680317e795ffd3a904662096
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
              Anonymous = mkOption {
                type = types.listOf types.str;
                default = [];
                description = lib.mdDoc ''
                If an `Anonymous` keyword is present, then anonymous proxying is enabled. The headers listed with `Anonymous` are allowed through, while all others are denied. If no Anonymous keyword is present, then all headers are allowed through. You must include quotes around the headers.
                '';
              };
              Filter = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = lib.mdDoc ''
                Tinyproxy supports filtering of web sites based on URLs or domains. This option specifies the location of the file containing the filter rules, one rule per line.  
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
