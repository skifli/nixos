{
  hostname,
  inputs,
  hostVars,
  pkgs,
  ...
}: let
  primaryUser = builtins.head hostVars.enabledUsers;
in {
  _module.args = {inherit hostname;};

  imports = [
    ../common/default.nix

    # All hardware features
    inputs.fyde-nix.nixosModules.fydetabduo-hardware

    # Shell sub-modules: power management + fydetab-update package
    # (shell.enable = false skips labwc/compositor stuff)
    inputs.fyde-nix.nixosModules.shell
  ];

  hardware.fydetabduo = {
    enable = true;

    sensors.autoRotate = false; # Replaced by niri-specific rotation daemon (see below)
    tabletMode.enable = true;
    modem.enable = true;
    npu.enable = true;

    installer-tools.enable = true;

    shell = {
      enable = false;

      packages.enable = false; # Cherry-picked in host-packages.nix instead
      power = {
        enable = true; # Needed because shell.enable = false disables it
        autoProfile = {
          enable = true;
          forcePerformanceOnAC = true;
        };
      };
    };
  };

  boot.loader.fydetabduo.enable = true;

  # Large console font so the tuigreet greeter text is readable on the VT
  console.font = "ter-u28n";

  # HERE BEGINS STUFF FROM FYDE-NIX WE HAD TO COPY OVER DUE TO NOT USING ALL THEIR FILES ETC

  hardware.graphics.enable = true;

  systemd.services."serial-getty@ttyFIQ0".enable = false;

  systemd.sockets.dbus.wantedBy = ["sockets.target"];

  networking = {
    networkmanager.wifi = {
      macAddress = "permanent";
      scanRandMacAddress = false;
      # Overrides the shared lib.mkDefault in modules/core/networking.nix.
      backend = "iwd";
    };

    wireless.iwd.enable = true;
  };

  services.openssh.enable = true; # Use Tailscale instead! But needed for Agenix...

  systemd.tmpfiles.rules = [
    "d /home/${primaryUser}/.cache 0755 ${primaryUser} users -"
    "d /tmp/.X11-unix 1777 root root -"
  ];

  systemd.services.fydetab-opengl-link = {
    description = "Ensure /run/opengl-driver points at Mesa";
    wantedBy = ["graphical.target"];
    before = ["greetd.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "fydetab-opengl-link" ''
        ln -sfn ${pkgs.mesa} /run/opengl-driver
      '';
    };
  };

  environment.sessionVariables = {
    __EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d";
    # GTK4 dmabuf textures render black on Mesa panfrost
    GDK_DISABLE = "dmabuf";
  };

  # Re-trigger udev for input devices before greetd starts so logind
  # assigns the touchscreen/stylus to the greeter session immediately
  systemd.services.fydetab-input-trigger = {
    description = "Re-trigger udev for input devices before greeter";
    wantedBy = ["greetd.service"];
    before = ["greetd.service"];
    after = ["systemd-udevd.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/udevadm trigger --subsystem-match=input";
      ExecStartPost = "${pkgs.systemd}/bin/udevadm settle";
    };
  };

  systemd.services.accounts-daemon.after = ["systemd-logind.service"];
}
