import ./make-test-python.nix ({ pkgs, ... }: {
  name = "quickwit";

  nodes.machine = { config, pkgs, ... }: {
    services.quickwit = {
      enable = true;
      settings = {
        Listen = "127.0.0.1";
        Port = 7280;
      };
    };
  };

  testScript = ''
    machine.wait_for_unit("quickwit.service")
    machine.wait_for_open_port(7280)

    machine.succeed('curl --fail http://localhost:7280/api/v1/version')
  '';
})
