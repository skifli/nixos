{ ... }:

{
  security = {
    rtkit.enable = true; # Real-time scheduling priority on demand
    polkit.enable = true; # System for managing privileges
  };
}
