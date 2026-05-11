let
  containers = import ./containers.nix;
in {
  Home = {
    id = "1f8a6f7c-3b59-4d65-9c1f-0a3e9a6f1b01";
    icon = "🏠";
    position = 1000;
    container = containers.Home.id;
  };
}

