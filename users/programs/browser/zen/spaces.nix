let
  containers = import ./containers.nix;
in {
  Home = {
    id = "1f8a6f7c-3b59-4d65-9c1f-0a3e9a6f1b01";
    icon = "🏠";
    position = 1000;
    container = containers.Home.id;
  };

  "F1 in Schools" = {
    id = "2b9d4c41-6a8e-4c9b-9a44-6d1c7f2e8b02";
    icon = "🏎️";
    position = 2000;
    container = containers."F1 in Schools".id;
  };

  Programming = {
    id = "3c7e2b6d-9f5a-4b41-8f77-1e9c5a4d2c03";
    icon = "💻";
    position = 3000;
    container = containers.Home.id;
  };
}

