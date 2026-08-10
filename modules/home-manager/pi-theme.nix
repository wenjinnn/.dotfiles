# Stylix palette theme for pi-coding-agent.
#
# Mirrors upstream stylix PR #2423 (modules/pi-coding-agent/hm.nix): writes
# ~/.pi/agent/themes/stylix.json so pi's TUI follows the active stylix
# palette, and selects it via settings.theme.
#
# pi loads custom themes from ~/.pi/agent/themes/*.json (getCustomThemesDir);
# the file must define every color token in pi's theme schema. Setting
# settings.theme = "stylix" points pi at it — leave llm's pi settings free of
# a plain `theme` key, otherwise the two definitions collide.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.pi-coding-agent;
  palette = config.lib.stylix.colors.withHashtag;

  # Base16 gives us semantic foreground colors, but not enough tinted surfaces
  # for pi's tool/message states. Generate those variants from the same palette.
  hexToRgb =
    color:
    let
      value = lib.removePrefix "#" color;
    in
    map (offset: lib.fromHexString (builtins.substring offset 2 value)) [
      0
      2
      4
    ];
  padHex =
    value:
    let
      hex = lib.toHexString value;
    in
    if lib.strings.stringLength hex == 1 then "0${hex}" else hex;
  rgbToHex = channels: "#${lib.concatStringsSep "" (map padHex channels)}";
  tint =
    background: foreground: weight:
    let
      backgroundRgb = hexToRgb background;
      foregroundRgb = hexToRgb foreground;
    in
    rgbToHex (
      lib.imap0 (
        index: channel: lib.floor (channel * (1 - weight) + builtins.elemAt foregroundRgb index * weight)
      ) backgroundRgb
    );
in
{
  options.programs.pi-coding-agent.stylixTheme = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Generate ~/.pi/agent/themes/stylix.json from the active stylix palette
      and set pi's theme to it. Disable to opt out (pi then falls back to its
      built-in dark/light detection).
    '';
  };

  config = lib.mkIf (cfg.enable or false && config.stylix.enable or false && cfg.stylixTheme) {
    programs.pi-coding-agent.settings.theme = "stylix";

    home.file.".pi/agent/themes/stylix.json" = {
      text = builtins.toJSON {
        "$schema" =
          "https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
        name = "stylix";
        vars = {
          accent = palette.base0D;
          text = palette.base05;
          muted = palette.base04;
          dim = palette.base03;
          selectedBg = palette.base02;
          userMsgBg = palette.base01;
          customMsgBg = tint palette.base00 palette.base0E 0.16;
          toolPendingBg = tint palette.base00 palette.base0D 0.12;
          toolSuccessBg = tint palette.base00 palette.base0B 0.12;
          toolErrorBg = tint palette.base00 palette.base08 0.12;
          infoBg = tint palette.base00 palette.base0A 0.16;
          pageBg = palette.base00;
          cardBg = palette.base01;
        };
        colors = {
          # Core UI/status colors.
          accent = "accent";
          border = palette.base03;
          borderAccent = palette.base0D;
          borderMuted = palette.base02;
          success = palette.base0B;
          error = palette.base08;
          warning = palette.base0A;
          muted = "muted";
          dim = "dim";
          text = "text";
          thinkingText = palette.base04;

          # Keep every message/tool surface distinct, like pi's native theme.
          selectedBg = "selectedBg";
          userMessageBg = "userMsgBg";
          userMessageText = "text";
          customMessageBg = "customMsgBg";
          customMessageText = "text";
          customMessageLabel = palette.base0E;
          toolPendingBg = "toolPendingBg";
          toolSuccessBg = "toolSuccessBg";
          toolErrorBg = "toolErrorBg";
          toolTitle = "text";
          toolOutput = "muted";

          # Markdown.
          mdHeading = palette.base0E;
          mdLink = palette.base0D;
          mdLinkUrl = palette.base0C;
          mdCode = palette.base0B;
          mdCodeBlock = palette.base0B;
          mdCodeBlockBorder = palette.base03;
          mdQuote = palette.base04;
          mdQuoteBorder = palette.base03;
          mdHr = palette.base03;
          mdListBullet = palette.base0C;

          # Tool diffs.
          toolDiffAdded = palette.base0B;
          toolDiffRemoved = palette.base08;
          toolDiffContext = palette.base04;

          # Syntax highlighting.
          syntaxComment = palette.base03;
          syntaxKeyword = palette.base0E;
          syntaxFunction = palette.base0D;
          syntaxVariable = palette.base08;
          syntaxString = palette.base0B;
          syntaxNumber = palette.base09;
          syntaxType = palette.base0A;
          syntaxOperator = palette.base0C;
          syntaxPunctuation = palette.base05;

          # Thinking-level border hierarchy.
          thinkingOff = palette.base03;
          thinkingMinimal = palette.base0D;
          thinkingLow = palette.base0C;
          thinkingMedium = palette.base0B;
          thinkingHigh = palette.base0A;
          thinkingXhigh = palette.base09;
          thinkingMax = palette.base08;

          # `!` shell mode gets the success/green semantic color.
          bashMode = palette.base0B;
        };
        export = {
          pageBg = "pageBg";
          cardBg = "cardBg";
          infoBg = "infoBg";
        };
      };
    };
  };
}
