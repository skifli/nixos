{
  pkgs,
  userVars,
  ...
}:
let
  # Linux File Converter Addon (https://codeberg.org/Lich-Corals/linux-file-converter-addon)
  # Adds a "Convert to..." context menu action in Dolphin.
  #
  # The main script is fetched from Codeberg and run through a wrapped Python so we
  # don't need pip/a local venv (NixOS has no /usr/bin/python3). Automatic self-updates
  # are disabled since the script is in the read-only store.
  #
  # Pinned together: both addon files at commit 3353f531c7b30ee415510c306a97368946234bb8
  # (mistress), adaption UI at 6c8b61565f007abdb28fa2e11bc0560c4aa73a5d.
  lfcaScript = pkgs.fetchurl {
    url = "https://codeberg.org/Lich-Corals/linux-file-converter-addon/raw/commit/3353f531c7b30ee415510c306a97368946234bb8/nautilus-fileconverter.py";
    sha256 = "0884932762304d536ae01e66cc6d6d87b6d7228765ce97194d63e6f16f65a01d";
  };

  lfcaServicemenu = pkgs.fetchurl {
    url = "https://codeberg.org/Lich-Corals/linux-file-converter-addon/raw/commit/3353f531c7b30ee415510c306a97368946234bb8/linux-file-converter-addon.kde_servicemenu";
    sha256 = "005840b6039d313ede83b3359a2b2a487bf4872cb6c5174e1709d2b1b7597904";
  };

  # The converter's modern UI is a cdylib the script loads via ctypes. Upstream only
  # publishes a prebuilt x86-64 binary, so we build it ourselves to also get it on
  # the aarch64 FydeTab Duo. It's iced + tiny-skia (only software rendering).
  adaptionUI = pkgs.rustPlatform.buildRustPackage {
    pname = "converter_addon_adaption_ui";
    version = "0.1.3";

    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "Lich-Corals";
      repo = "converter_addon_adaption_ui";
      rev = "6c8b61565f007abdb28fa2e11bc0560c4aa73a5d";
      sha256 = "sha256-pfQkrLRPYCZTLbNldb5UEFAEhbZNeKGtzGTDee24DxI=";
    };

    cargoHash = "sha256-DeiM64SNrfVUlyFACibwydap14BgQ1ytGG0x/GNxbFI=";

    doCheck = false;

    # The repo commits a prebuilt x86-64 target/release/*.so; drop it so it can't
    # shadow the self compiled architecture-native cdylib. Also drop the bogus
    # "codegen-utils" profile key that cargo warns about.
    postUnpack = ''
      rm -rf "$sourceRoot/target"
      sed -i '/^codegen-utils *=/d' "$sourceRoot/Cargo.toml"
    '';

    # Lib-only crate; cargo install would fail so install the cdylib manually.
    # The rustc wrapper sets CARGO_BUILD_TARGET, so the fresh binary is in
    # target/<triple>/release/ — locate it instead of hardcoding target/release.
    installPhase = ''
      runHook preInstall
      install -Dm755 \
        "$(find target -name 'libconverter_addon_adaption_ui.so' ! -path '*/deps/*' | head -n1)" \
        -t $out/lib
      strip --strip-unneeded "$out"/lib/*.so
      runHook postInstall
    '';
  };

  # Wrapped Python with the addon's deps. pygobject3 doesn't propagate the Gtk3
  # typelib, so point GI_TYPELIB_PATH at gtk3 for the legacy UI fallback.
  lfcaPython = pkgs.python3.withPackages (ps: [
    ps.pygobject3
    ps.pillow
    ps.python-magic
    ps.requests
    ps.pillow-heif # HEIF/AVIF read support
  ]);

  lfcaWrapper = pkgs.writeShellScriptBin "linux-file-converter-addon.py" ''
    export GI_TYPELIB_PATH="${pkgs.gtk3}/lib/girepository-1.0"
    exec '${lfcaPython}/bin/python3' -OOt '${lfcaScript}' "$@"
  '';
in
{
  /*
    nixpkgs.overlays = [
      inputs.dolphin-overlay.overlays.default # Not working - TODO: Fix myself later!?
    ]; # Add https://github.com/MattiDragon/dolphin-overlay
  */

  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu"; # TODO: REMOVE AFTER https://github.com/NixOS/nixpkgs/issues/409986 IS SOLVED

  home-manager.users.${userVars.username} =
    {
      config,
      lib,
      ...
    }:
    {
      home = {
        # Linux File Converter Addon files (see let-bindings above)
        file = {
          # kio servicemenu; Exec rewritten to the wrapper's absolute path (no
          # "python3 " prefix since NixOS has no /usr/bin/python3 and ~ isn't safe)
          ".local/share/kio/servicemenus/linux-file-converter-addon.desktop" = {
            text =
              builtins.replaceStrings
                [
                  "Exec=python3 ~/.local/bin/linux-file-converter-addon.py --dolphin-run %U"
                ]
                [
                  "Exec=${config.home.profileDirectory}/bin/linux-file-converter-addon.py --dolphin-run %U"
                ]
                (builtins.readFile lfcaServicemenu);
          };

          # Modern adaption UI, built from source so it works on x86_64 and aarch64
          ".config/linux-file-converter-addon/libconverter_addon_adaption_ui.so" = {
            source = "${adaptionUI}/lib/libconverter_addon_adaption_ui.so";
          };

          # Don't let the addon try to rewrite itself (read-only store) or download
          # an x86-only UI binary
          ".config/linux-file-converter-addon/config.json" = {
            text = builtins.toJSON {
              automaticUpdates = false;
            };
          };
        };

        # KDE service cache refresh.
        # This fixes missing/incorrect desktop integration after rebuilds
        # (for example default app handlers in Dolphin).
        activation.refreshKDECache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          KBUILD="${pkgs.kdePackages.kservice}/bin/kbuildsycoca6"
          if [ -x "$KBUILD" ]; then
            "$KBUILD" >/tmp/kbuildsycoca6.log 2>&1 || true
          fi
        '';

        packages = with pkgs; [
          lfcaWrapper
          kdePackages.dolphin
          kdePackages.dolphin-plugins

          kdePackages.breeze-icons # For sidebar icons iirc

          kdePackages.qtsvg # Support for svg icons
          kdePackages.kio # Below ig, custom though
          kdePackages.kio-admin # Another custom
          kdePackages.kio-fuse # To mount remote filesystems via FUSE
          kdePackages.kio-extras # Extra protocols support (sftp, fish and more)

          # File previews - https://wiki.archlinux.org/title/Dolphin#File_previews
          libappimage
          libheif
          icoutils
          kdePackages.ark # File extraction
          kdePackages.ffmpegthumbs
          kdePackages.kactivitymanagerd
          kdePackages.kdegraphics-thumbnailers
          kdePackages.kimageformats
          kdePackages.kdesdk-thumbnailers
          kdePackages.kservice # For kbuildsycoca6
          kdePackages.qtimageformats
          kdePackages.qttools # qdbus etc
          nufraw-thumbnailer # Own choice
          resvg
          taglib_1

          unzip
        ];

        activation.setupDolphinrc = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          TARGET_FILE="${config.xdg.configHome}/dolphinrc"
          mkdir -p "$(dirname "$TARGET_FILE")"
          cat << 'EOF' > "$TARGET_FILE"
          [MainWindow]
          MenuBar=Disabled

          [General]
          ShowFullPathInTitlebar=true

          [KFileDialog Settings]
          Places Icons Auto-resize=true
          Places Icons Static Size=0

          [PreviewSettings]
          EnableRemoteFolderThumbnail=true
          MaximumRemoteSize=104857600
          Plugins=imagethumbnail,jpegthumbnail,directorythumbnail,ffmpegthumbs,exethumbnail,comicbookthumbnail,officeMarcothumbnail
          RemotePlugins=imagethumbnail,jpegthumbnail,directorythumbnail,ffmpegthumbs,exethumbnail,comicbookthumbnail,officeMarcothumbnail
          RemotePreviewSizeLimit=104857600
          UseDefaultRemotePreviewSizeLimit=false
          EOF
        '';
      };

      xdg.mimeApps.defaultApplications = {
        "inode/directory" = [ "dolphin.desktop" ];
        "application/zip" = [ "org.kde.ark.desktop" ];
        "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
        "application/x-bzip-compressed-tar" = [ "org.kde.ark.desktop" ];
        "application/x-compressed-tar" = [ "org.kde.ark.desktop" ];
        "application/x-rar" = [ "org.kde.ark.desktop" ];
        "application/x-tar" = [ "org.kde.ark.desktop" ];
        # "application/x-gnome-saved-search" = [ "dolphin.desktop" ];
      };
    };
}
