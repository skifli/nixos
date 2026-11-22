{
  inputs,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = {
    imports = [ inputs.nixcord.homeModules.nixcord ];

    programs.nixcord = {
      enable = true;
      discord.enable = false;

      equibop = {
        enable = true;
        useSystemEquicord = true;
        installPackage = true;
        autoscroll.enable = false;

        settings = {
          minimizeToTray = true;
          hardwareAcceleration = true;
          # Follow system theme (light/dark)
          theme = "auto";
          # Video hardware acceleration (VA-API/VDPAU)
          enableHardwareAcceleration = true;
        };

        state = {
          firstLaunch = false;
        };
      };

      quickCss = ''
        /* Frameless window root; avoid Discord's changing hashed class names. */
        html,
        body,
        #app-mount,
        .appMount {
          border-radius: 0px !important;
        }
      '';

      config = {
        autoUpdate = false;
        autoUpdateNotification = false;
        notifyAboutUpdates = false;
        disableMinSize = true;
        frameless = true;
        transparent = false;

        useQuickCss = true;
        enableReactDevtools = false;

        plugins = {
          hideMedia.enable = true;

          ignoreActivities = {
            enable = true;
            ignorePlaying = true;
            # MusicRichPresence publishes as a Listening activity.
            ignoreListening = false;
            ignoreWatching = true;
            ignoreStreaming = true;
          };

          messageLogger = {
            enable = true;
            logDeletes = true;
            logEdits = true;
            ignoreBots = true;
            collapseDeleted = true;
          };

          silentTyping.enable = true;
          typingIndicator = {
            enable = true;
            # Avatars only; noTypingAnimation below disables animated dots.
            indicatorMode = 2;
            includeCurrentChannel = true;
          };

          addAttachments.enable = true;
          alwaysTrust.enable = true;
          betterAudioPlayer.enable = true;
          betterBackreading.enable = true;
          biggerStreamPreview.enable = false;
          consoleJanitor.enable = true;
          copyEmojiMarkdown.enable = true;
          directFileDownload.enable = true;
          equibopStreamFixes.enable = true;
          fixSpotifyEmbeds.enable = true;
          fixImagesQuality.enable = true;
          fixYoutubeEmbeds.enable = true;
          fullSearchContext.enable = true;
          homeTyping.enable = true;
          imageFilename.enable = true;
          imageZoom.enable = true;
          messageLatency.enable = true;
          messageLoggerEnhanced.enable = true;
          noNitroUpsell.enable = true;
          noOnboardingDelay.enable = true;
          noTypingAnimation.enable = true;
          relationshipNotifier.enable = true;
          revealAllSpoilers.enable = true;
          reviewDb.enable = true;
          searchFix.enable = true;
          sedEnhanced.enable = true;
          serverInfo.enable = true;
          shikiCodeblocks.enable = true;
          title.enable = true;

          # Use ListenBrainz's public now-playing feed; this needs no
          # Navidrome password and doesn't expose the tailnet-only server URL.
          musicRichPresence = {
            enable = true;
            scrobblerBackend = "listenbrainz";
            username = "skifli";
            useListeningStatus = true;
            nameFormat = "artist-first";
            statusDisplayType = "artist";
            showAlbumCover = true;
          };

          fakeNitro.enable = false;
          volumeBooster.enable = true;
          platformIndicators.enable = true;

          noMiddleClickPaste.enable = true;

          betterFolders.enable = true;
          themeAttributes.enable = true;

          advancedPermissions.enable = true;
          alwaysAnimate.enable = true;
          betterImageEditor.enable = true;
          blurNsfw.enable = true;
          clickableRoles.enable = true;
          commandPalette.enable = true;
          declutter.enable = true;
          equicordToolbox.enable = false;
          experiments.enable = true;
          fileUpload.enable = true;
          findReply.enable = true;
          noDevtoolsWarning.enable = true;
          noF1.enable = true;
          openInApp.enable = true;
          permissionFreeWill.enable = true;
          permissionsViewer.enable = true;
          voiceChatUtilities.enable = true;
          youtubeAdblock.enable = true;
          zipPreview.enable = true;
        };
      };

      equibopConfig = {
      };
    };
  };
}
