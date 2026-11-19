# Shared Wayle custom modules for the pomodoro timer and GitHub Actions
# status. Imported by the regular desktop Wayle config and by fydetabduo's
# fyde-nix Wayle configuration.
[
  {
    id = "pomodoro";
    border-color = "auto";
    border-show = true;
    button-bg-color = "bg-surface-elevated";
    command = "pomodoro-wayle.sh";
    format = "{{ output }}";
    hide-if-empty = true;
    icon-show = false;
    interval-ms = 1000;
    label-color = "fg-default";
    label-max-length = 0;
    label-show = true;
    left-click = "pomodoro-wayle.sh start-pause";
    right-click = "pomodoro-wayle.sh skip";
    middle-click = "pomodoro-wayle.sh reset";
    mode = "poll";
    restart-interval-ms = 1000;
    restart-policy = "never";
    scroll-down = "";
    scroll-up = "";
  }
  {
    id = "ci_status";
    border-color = "auto";
    border-show = true;
    button-bg-color = "bg-surface-elevated";
    command = "ci-status-wayle.sh";
    format = "{{ output }}";
    hide-if-empty = true;
    icon-show = false;
    interval-ms = 60000;
    label-color = "fg-default";
    label-max-length = 0;
    label-show = true;
    left-click = "ci-status-wayle.sh open";
    right-click = "ci-status-wayle.sh refresh";
    middle-click = "ci-status-wayle.sh status-menu";
    mode = "poll";
    restart-interval-ms = 1000;
    restart-policy = "never";
    scroll-down = "";
    scroll-up = "";
  }
]
