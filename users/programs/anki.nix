{
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}:
let
  advanced-review-bottom-bar = (
    pkgsUnstable.anki-utils.buildAnkiAddon (finalAttrs: {
      pname = "advanced-review-bottom-bar";
      version = "v3.6.1";
      src = pkgs.fetchFromGitHub {
        owner = "noobj2";
        repo = "Anki-Advanced-Review-Bottombar";
        rev = finalAttrs.version;
        sparseCheckout = [ "" ];
        hash = "sha256-ah51DWf1DbULF580hMj360R5qPh3fHnYM6KGBtJrgh8=";
      };
      sourceRoot = "${finalAttrs.src.name}";
    })
  );

  add-unstable-anki = final: _prev: {
    anki-utils = pkgsUnstable.anki-utils;
  };
in
{
  # HM tries to use add-anki-utils from (stable) pkgs which is only present in unstable pkgs
  nixpkgs.overlays = [ add-unstable-anki ];

  home-manager.users.${userVars.username} = {
    home.file.".config/anki-keyFile" = {
      source = ../${userVars.username}/secrets/anki-keyFile;
    };

    home.file.".config/anki-usernameFile" = {
      source = ../${userVars.username}/secrets/anki-usernameFile;
    };

    programs.anki = {
      enable = true;
      package = pkgsUnstable.anki;
      addons = with pkgsUnstable; [
        ankiAddons.review-heatmap
        (advanced-review-bottom-bar.withConfig {
          config = {
            "  Button Colors" = true;
            "  Speed Focus Add-on" = false;
            "  Rebuild Empty All Add-on" = false;
            "  Direct Config Edit" = false;
            "  Hide Easy if not in Learning" = false;
            "  More Overview Stats" = 0;
            "  Settings Menu Place" = 0;
            "  Skip Method" = 0;
            "  Style Main Screen Buttons" = true;
            " Review_ Active Button Indicator" = 1;
            " Review_ Buttons Style" = 6;
            " Review_ Hover Effect" = 1;
            " Review_ Custom Colors" = false;
            " Review_ Custom Review Button Text Color" = false;
            " Review_ Custom Active Indicator Color" = false;
            " Review_ Bottombar Buttons Style" = 3;
            " Review_ Cursor Style" = 0;
            " Review_ Interval Style" = 0;
            " Review_ Button Transition Time" = 250;
            " Review_ Button Border Radius" = 5;
            " Review_ Wide Button Percent" = 80;
            "Button_   Info Button" = true;
            "Button_   Skip Button" = true;
            "Button_   Show Skipped Button" = true;
            "Button_   Undo Button" = false;
            "Button_   Hide Hard" = true;
            "Button_   Hide Good" = false;
            "Button_   Hide Easy" = true;
            "Button_  Custom Button Sizes" = false;
            "Button_ Shortcut_ Skip Button" = "c";
            "Button_ Shortcut_ Show Skipped Button" = "Alt + c";
            "Button_ Shortcut_ Info Button" = "f4";
            "Button_ Shortcut_ Undo Button" = "NOT_SET";
            "Button_ Position_ Info Button" = "left";
            "Button_ Position_ Skip Button" = "middle left";
            "Button_ Position_ Show Skipped Button" = "middle left";
            "Button_ Position_ Undo Button" = "middle right";
            "Button_ Text Size" = 14;
            "Button_ Font Weight" = 3;
            "Button_ Height_ All Bottombar Buttons" = 40;
            "Button_ Width_ Edit Button" = 150;
            "Button_ Width_ Show Answer Button" = 150;
            "Button_ Width_ Info Button" = 150;
            "Button_ Width_ Skip Button" = 150;
            "Button_ Width_ Show Skipped Button" = 150;
            "Button_ Width_ More Button" = 150;
            "Button_ Width_ Review Buttons" = 150;
            "Button_ Width_ Undo Button" = 150;
            "Button Label_ Study Now" = "Study Now";
            "Button Label_ Edit" = "Edit";
            "Button Label_ Show Answer" = "Show Answer";
            "Button Label_ More" = "More";
            "Button Label_ Info" = "Info";
            "Button Label_ Skip" = "Skip";
            "Button Label_ Show Skipped" = "Show Skipped";
            "Button Label_ Undo" = "Undo Review";
            "Button Label_ Again" = "Again";
            "Button Label_ Hard" = "Hard";
            "Button Label_ Good" = "Good";
            "Button Label_ Easy" = "Easy";
            "Card Info sidebar_ Hide Current Card" = 0;
            "Card Info sidebar_ Number of previous cards to show" = 0;
            "Card Info sidebar_ theme" = 0;
            "Card Info sidebar_ Created" = true;
            "Card Info sidebar_ Edited" = true;
            "Card Info sidebar_ First Review" = true;
            "Card Info sidebar_ Latest Review" = true;
            "Card Info sidebar_ Due" = true;
            "Card Info sidebar_ Interval" = true;
            "Card Info sidebar_ Ease" = true;
            "Card Info sidebar_ Reviews" = true;
            "Card Info sidebar_ Lapses" = true;
            "Card Info Sidebar_ Correct Percent" = true;
            "Card Info Sidebar_ Fastest Review" = true;
            "Card Info Sidebar_ Slowest Review" = true;
            "Card Info sidebar_ Average Time" = true;
            "Card Info sidebar_ Total Time" = true;
            "Card Info sidebar_ Card Type" = true;
            "Card Info sidebar_ Note Type" = true;
            "Card Info sidebar_ Deck" = true;
            "Card Info sidebar_ Tags" = true;
            "Card Info Sidebar_ Note ID" = false;
            "Card Info Sidebar_ Card ID" = false;
            "Card Info sidebar_ Sort Field" = true;
            "Card Info sidebar_ Current Review Count" = true;
            "Card Info sidebar_ Font" = "Fira Code";
            "Card Info sidebar_ number of reviews to show for a card" = 0;
            "Card Info sidebar_ Auto Open" = false;
            "Card Info sidebar_ warning note" = false;
            "Color_  General Text Color" = "#ffffff";
            "Color_ Active Button Indicator" = "#ffffff";
            "Color_ Bottombar Button Text Color" = "#ea4e9c";
            "Color_ Bottombar Button Border Color" = "#3b82f6";
            "Color_ Custom Bottombar Button Text Color" = true;
            "Color_ Custom Bottombar Button Border Color" = true;
            "Color_ Again" = "#BA0C0C";
            "Color_ Again on hover" = "#FF1111";
            "Color_ Hard" = "#BF720F";
            "Color_ Hard on hover" = "#FF9814";
            "Color_ Good" = "#20A11C";
            "Color_ Good on hover" = "#33FF2D";
            "Color_ Easy" = "#188AB8";
            "Color_ Easy on hover" = "#21C0FF";
            "Tooltip" = false;
            "Tooltip Timer" = 500;
            "Tooltip Text Color" = "#f3f3f3";
            "Tooltip Style" = 1;
            "Tooltip Position" = [
              950
              (-950)
            ];
            "Tooltip Offset" = [
              (-800)
              0
            ];
            "ShowAnswer_ Border Color Style" = 0;
            "ShowAnswer_ Ease1" = 200;
            "ShowAnswer_ Ease2" = 250;
            "ShowAnswer_ Ease3" = 300;
            "ShowAnswer_ Ease4" = 350;
            "ShowAnswer_ Ease1 Color" = "#FF1111";
            "ShowAnswer_ Ease2 Color" = "#FF9814";
            "ShowAnswer_ Ease3 Color" = "#33FF2D";
            "ShowAnswer_ Ease4 Color" = "#21C0FF";
          };
        })
      ];
      answerKeys = [
        {
          ease = 1;
          key = "1";
        }
        {
          ease = 2;
          key = "";
        }
        {
          ease = 3;
          key = "3";
        }
        {
          ease = 4;
          key = "";
        }
      ];
      spacebarRatesCard = false;
      style = "anki";
      sync = {
        autoSync = true;
        autoSyncMediaMinutes = 60;
        keyFile = "/home/${userVars.username}/.config/anki-keyFile";
        networkTimeout = 5;
        syncMedia = true;
        usernameFile = "/home/${userVars.username}/.config/anki-usernameFile";
      };
      theme = "followSystem";
      uiScale = 0.5;
      videoDriver = "vulkan";
    };
  };
}
