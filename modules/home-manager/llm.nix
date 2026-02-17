{ pkgs, ... }:
{

  home.packages = with pkgs; [
    mcp-nixos
  ];
  programs = {
    bash = {
      shellAliases = {
        # Alias to connect to the most recent nvim instance
        opencode = ''
          env NVIM_SOCKET_PATH=''${NVIM:-$( \
                  find "''${XDG_RUNTIME_DIR:-''${TMPDIR}nvim.''${USER}}/" -type s -name 'nvim.*.0' -printf '%T@ %p\n' 2>/dev/null \
                  | sort -nr \
                  | head -n 1 \
                  | awk '{print $2}')} \
          opencode
        '';
        gemini = ''
          env GEMINI_API_KEY="$(sops exec-env $SOPS_SECRETS 'echo -n $GEMINI_API_KEY')" \
          GOOGLE_CLOUD_PROJECT="$(sops exec-env $SOPS_SECRETS 'echo -n $GOOGLE_CLOUD_PROJECT')" \
          NVIM_SOCKET_PATH=''${NVIM:-$( \
                  find "''${XDG_RUNTIME_DIR:-''${TMPDIR}nvim.''${USER}}/" -type s -name 'nvim.*.0' -printf '%T@ %p\n' 2>/dev/null \
                  | sort -nr \
                  | head -n 1 \
                  | awk '{print $2}')} \
          gemini
        '';
      };
    };
    gemini-cli = {
      enable = true;
      commands = {
        japteacher = {
          prompt = ''
            接下来请扮演我的专业日语老师，使用中文回复我，对于我发出的每一个句子给出注音，
            并尽可能详细的分解语法成分，给出中文的完整意思。可能的话，再标注自动词和他动词,外来词的源词，以及动词的活用类型，最后，灵活补充你认为还需要补充的额外内容
          '';
          description = "A professional Japanese teacher that provides detailed explanations in Chinese.";
        };
        nvim-embed = {
          prompt = ''
            你现在在一个叫做nvim-embed的环境中，这个环境可以让你通过mcp调用neovim的功能来编辑文本。
            接下来的任何编辑相关的任务，你都应该使用neovim mcp提供的工具来完成，以便我能在neovim中看到结果。
            同时，编辑的过程中保证当前的terminal buffer永远在屏幕上，因为我要看到你的输出过程。
            如果有其他buffer需要编辑，优先利用当前屏幕上其他已存在的window编辑，没有已存在的window时，使用spilt命令自行创建新的window。
          '';
          description = "A specialized environment for editing text using Neovim via MCP.";
        };
      };

      settings = {
        general = {
          preferredEditor = "nvim";
          disableAutoUpdate = true;
          enablePromptCompletion = true;
          previewFeatures = true;
        };
        security = {
          auth.selectedType = "gemini-api-key";
        };
        mcpServers = {
          neovim = {
            command = "npx";
            args = [
              "-y"
              "mcp-neovim-server"
            ];
          };
          context7 = {
            command = "npx";
            args = [
              "-y"
              "@upstash/context7-mcp"
            ];
          };
          nixos = {
            command = "mcp-nixos";
            args = [ "--" ];
          };
        };
      };
    };
    opencode = {
      enable = true;
      settings = {
        mcp = {
          context7 = {
            enabled = true;
            type = "local";
            command = [
              "npx"
              "-y"
              "@upstash/context7-mcp"
            ];
          };
          neovim = {
            enabled = true;
            type = "local";
            command = [
              "npx"
              "-y"
              "mcp-neovim-server"
            ];
          };
          nixos = {
            enabled = true;
            type = "local";
            command = [
              "mcp-nixos"
              "--"
            ];
          };
        };
      };
    };
  };
}
