{ lib, ... }:

{
  name = "qui";
  meta.maintainers = [ ];

  nodes.machine =
    { pkgs, ... }:
    {
      services.qui.enable = true;
    };

  testScript = ''
    machine.wait_for_unit("qui.service")
    machine.wait_for_open_port(7476)
    machine.succeed("curl --fail http://localhost:7476/")
  '';
}
