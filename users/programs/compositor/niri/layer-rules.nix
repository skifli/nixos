{userVars, ...}: [
  {
    match._props = {
      namespace = "^notifications$";
    };
    block-out-from = "screen-capture";
  }
  {
    match._props = {
      namespace._raw = ''r#"^(gcr-prompter)"#'';
    };
    block-out-from = "screen-capture";
  }
  {
    match._props = {
      namespace._raw = ''r#"^(${userVars.programs.launcher}|${userVars.programs.desktop-shell}.*)"#'';
      layer = "top";
    };
    background-effect = {
      blur = [];
    };
  }
]
