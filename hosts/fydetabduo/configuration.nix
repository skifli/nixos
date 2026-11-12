{
  hostname,
  inputs,
  hostVars,
  pkgs,
  ...
}:
let
  primaryUser = builtins.head hostVars.enabledUsers;
  tabletLock = "${pkgs.swaylock}/bin/swaylock -f -i /home/${primaryUser}/.local/share/wallpaper-blurred";
  display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
in
{
  _module.args = { inherit hostname; };

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
    modem.enable = false; # Avoids ModemManager probing delay
    npu.enable = true;

    # Cap charging at 90%, resuming below 85%
    battery.chargeLimit = 90;
    battery.rechargeAt = 85;

    installer-tools.enable = true;

    shell = {
      enable = false;

      audio.enable = true;
      packages.enable = false; # Cherry-picked in host-packages.nix instead
      power = {
        enable = true; # Needed because shell.enable = false disables it

        # The keyboard's lock key locks the session by default. Change to
        # "suspend" to suspend, or "ignore" to leave the key to your own
        # compositor.
        keyboardSleepKeyAction = "ignore";
      
        autoProfile = {
          enable = true;
          forcePerformanceOnAC = true;
        };
      };
    };
  };

  # The soundcore V20i is unreliable with AAC and sounds/lags better with
  # SBC-XQ. Restricting the codec list also prevents WirePlumber from
  # going back to AAC on reconnect.
  services.pipewire.wireplumber.extraConfig."90-bluetooth-codecs" = {
    "monitor.bluez.properties" = {
      "bluez5.codecs" = [
        "sbc_xq"
        "sbc"
      ];
    };
  };

  # fyde-nix's swayidle uses wlopm, which needs
  # wlr-output-power-management-v1. Niri does not implement that protocol,
  # so `wlopm --off '*'` fails and the DSI panel never turns off.
  home-manager.users.${primaryUser}.services.swayidle = pkgs.lib.mkForce {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];

    timeouts = [
      {
        timeout = hostVars.screen-lock-timeout * 60;
        command = tabletLock;
      }
      {
        timeout = hostVars.screen-blank-timeout * 60;
        command = display "off";
        resumeCommand = display "on";
      }
    ];

    events = {
      lock = tabletLock;

      before-sleep = "${tabletLock}; ${display "off"}";
      after-resume = display "on";
    };
  };

  # Do NOT import modules/core/boot.nix - for the following reason:
  # that module also selects Lyra's kernel and bootloader configuration.
  boot.loader.fydetabduo.enable = true;

  # NFS mounts over tailscale (with hard/timeo=600) leave processes D-state
  # when suspend closes the tunnel; systemd-sleep then waits a full ~60s
  # freeze placed on user.slice before suspending. They aren't needed when
  # suspended so allow an instant suspend.
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "0";
  systemd.services.systemd-hybrid-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "0";

  # HERE BEGINS STUFF FROM FYDE-NIX WE HAD TO COPY OVER DUE TO NOT USING ALL THEIR FILES ETC

  hardware.graphics.enable = true;

  systemd.services."serial-getty@ttyFIQ0".enable = false;

  systemd.sockets.dbus.wantedBy = [ "sockets.target" ];

  networking = {
    networkmanager.wifi = {
      macAddress = "permanent";
      scanRandMacAddress = false;
    };
  };

  services.openssh.enable = true; # Use Tailscale instead! But needed for Agenix...

  systemd.tmpfiles.rules = [
    "d /home/${primaryUser}/.cache 0755 ${primaryUser} users -"
    "d /tmp/.X11-unix 1777 root root -"
  ];

  # Needed by niri-rotate daemon (monitor-sensor) for auto-rotation.
  environment.etc."polkit-1/rules.d/50-iio-sensor-proxy.rules".text = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "net.hadess.SensorProxy.claim-sensor" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.services.fydetab-opengl-link = {
    description = "Ensure /run/opengl-driver points at Mesa";
    wantedBy = [ "graphical.target" ];
    before = [ "greetd.service" ];
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
    wantedBy = [ "greetd.service" ];
    before = [ "greetd.service" ];
    after = [ "systemd-udevd.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/udevadm trigger --subsystem-match=input";
      ExecStartPost = "${pkgs.systemd}/bin/udevadm settle";
    };
  };

  systemd.services.accounts-daemon.after = [ "systemd-logind.service" ];
}
