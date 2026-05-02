{ pkgs, userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      starship
    ];

    programs.starship = {
      enable = true;
      settings = {
        # Reduce prompts that can timeout
        command_timeout = 1000; # ms before timeout
        scan_timeout = 500;
        
        # Disable slow modules
        hostname.disabled = false;
        
        # Network module can hang - disabled by default, enable if needed
        # username.disabled = true; # If this causes issues
      };
    };
  };
}
