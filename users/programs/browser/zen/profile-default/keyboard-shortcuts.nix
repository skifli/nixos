# Declarative keyboard shortcut overrides for Zen >= 1.24b.
# These are upserted into the profile's customKeys.json (the about:keyboard
# store); only customized ids are present and an empty object means unbound.
# ⚠ Only if modifying keyboardShortcuts: close Zen before home-manager switch
# (the activation script modifies customKeys.json, which is locked while the
# browser is running).
#
# Find shortcut IDs in about:keyboard (or the generated customKeys.json):
# jq -c 'to_entries[]' ~/.config/zen/default/customKeys.json | fzf
{
  keyboardShortcuts = [
    {
      id = "zen-compact-mode-toggle";
      key = "c";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "key_reload_skip_cache";
      key = "r";
      modifiers = {
        control = true;
        shift = true;
      };
    }
    {
      id = "key_reload";
      key = "r";
      modifiers.control = true;
    }
    {
      id = "key_savePage";
      key = "s";
      modifiers.control = true;
    }
    {
      id = "zen-copy-url";
      key = "u";
      modifiers.control = true;
    }
    {
      id = "key_selectTab1";
      key = "1";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "key_selectTab2";
      key = "2";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "key_selectTab3";
      key = "3";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "key_selectTab4";
      key = "4";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "key_selectTab5";
      key = "5";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "key_selectTab6";
      key = "6";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "key_selectTab7";
      key = "7";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "key_selectTab8";
      key = "8";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "key_selectLastTab";
      key = "9";
      modifiers = {
        alt = false;
        control = true;
      };
    }
    {
      id = "zen-workspace-switch-1";
      key = "1";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "zen-workspace-switch-2";
      key = "2";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "zen-workspace-switch-3";
      key = "3";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "zen-workspace-switch-4";
      key = "4";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "zen-workspace-switch-5";
      key = "5";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "zen-workspace-switch-6";
      key = "6";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "zen-workspace-switch-7";
      key = "7";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "zen-workspace-switch-8";
      key = "8";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "zen-workspace-switch-9";
      key = "9";
      modifiers = {
        control = true;
        alt = true;
      };
    }
    {
      id = "key_quitApplication";
      disabled = true;
    }
    {
      id = "addBookmarkAsKb";
      disabled = true;
    }
  ];
}
