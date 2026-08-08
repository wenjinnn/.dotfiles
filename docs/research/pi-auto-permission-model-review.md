# 调研：模型审查式自动权限（Model-Reviewed Auto Permission）在 Claude Code 与 Pi 的实现

> 调研日期：2026-08-08
> 目标：Claude Code 新出的 auto-permission 功能（由另一个模型审查 agent 将执行的系统命令是否安全）；
> 检查 pi agent 侧是否已有插件实现；若无，评估 fork `pi-permission-system` 自行实现的可行性与难度。

---

## 结论速览

| 问题 | 答案 |
| --- | --- |
| Claude Code 官方功能名 | **Auto mode**（配置值 `auto`），不是 "auto-permission"/"autoApproval" |
| 审查用什么模型 | 官方口径：Sonnet 4.6（原架构），v2.1.210 起外部会话默认 **Sonnet 5**；由 Claude Code 决定，用户不可选 |
| Pi 侧是否已有插件实现 | **已有，且不止一个。** 三个独立 npm 包，其中两个直接对接你正在用的 `@gotgenes/pi-permission-system` authorizer chain |
| 是否需要自己 fork | **不需要。** 你的 v24 fork 原生暴露 `registerAuthorizer` seam + `authorizerChain` 配置，装一个现成插件即可启用 |
| 自己实现的难度 | 低-中：只需写一个 Authorizer chain link（~200-400 行 TS），模型调用走官方 `completeSimple`/`complete` API；但现成方案已覆盖大部分需求 |

---

## 一、Claude Code 的 Auto mode 到底是什么

### 1.1 官方定义与定位

- 官方名 **Auto mode**，`permissions.defaultMode: "auto"` 或 `claude --permission-mode auto`。
- 定位：介于手动确认（manual）和 `--dangerously-skip-permissions` 之间的中间地带——把批准权委托给**模型分类器**，常规动作无打断放行，不可逆/破坏性/超出环境的动作被拦截。
- 与静态 allowlist 的本质区别：静态规则只能预先枚举匹配模式；auto mode 是**上下文判断**——评估动作的真实影响（real-world impact）以及用户是否**具体授权了该动作**，因此未枚举过的新命令也可能被放行，而"清理我的分支"这种宽泛意图**不会**被当作批量删除的授权。

### 1.2 三层决策结构

```
Tier 1  内置安全工具 allowlist + 用户静态规则（allow/ask/deny，优先级 deny > ask > allow）
        进入 auto mode 时暂停会授予任意代码执行的宽规则（blanket bash、通配解释器、包管理器 run 命令）
Tier 2  项目目录内的文件读写 → 直接放行（不走分类器，省延迟，且可被 VCS 审查）
Tier 3  Transcript classifier（Sonnet 4.6/5）：其余一切——shell 命令、web fetch、
        MCP/外部工具、subagent 派发、项目外文件操作、受保护路径写入
```

### 1.3 分类器设计（值得抄的架构细节）

- **两级流水线**：Stage 1 是快速单 token yes/no 过滤（指令"err toward blocking"）；只有被标记的才进 Stage 2 做 CoT 推理（清掉误报）。官方实测：Stage1 FPR 8.5% → 全管道 FPR 0.4%（真实流量 n=10,000）；真实 overeager 动作 FNR 17%。
- **输入裁剪**：分类器**只看到用户消息 + 可执行工具调用**，剥离 assistant 散文与工具输出——防 agent 说服分类器，也是结构性防 prompt injection（工具输出正是注入进入上下文的主要渠道）。
- **固定模板 + 3 个可定制槽位**：`environment`（信任边界：repo/org/域名/桶/服务）、`hard_deny`/`soft_deny`/`allow`（自然语言策略数组，`$defaults` 可拼接 Anthropic 默认）；`claude auto-mode defaults` 可查看默认策略原文。
- **拒绝后继续**（deny-and-continue）：拒绝以工具结果形式返回，agent 尝试更安全路径；连续 3 次或累计 20 次被拦则回退到人工（headless `-p` 直接终止）。
- **独立的输入层 prompt-injection probe**：扫描工具结果，疑似注入时在上下文里加警告（与输出层分类器互补）。

### 1.4 配置入口（最小示例）

```jsonc
{
  "permissions": {
    "defaultMode": "auto",
    "allow": ["Bash(npm test)"],
    "ask": ["Bash(git push *)"],
    "deny": ["Read(//secrets/**)"]
  },
  "autoMode": {
    "environment": ["$defaults", "Trusted source control: github.com/acme/*"],
    "allow": ["$defaults"],
    "soft_deny": ["$defaults", "Treat staging deploys as requiring explicit intent"],
    "hard_deny": ["$defaults", "Never modify production IAM"],
    "classifyAllShell": true
  }
}
```

### 1.5 关键事实

- 分类器模型**用户不可配置**，由 Claude Code 侧决定（原始架构 Sonnet 4.6；v2.1.210 起外部会话默认 Sonnet 5，首个请求校验后会话内固定）。
- 完整固定 prompt 未公开原文，只有结构描述 + 可检查的策略槽默认值。
- 官方明确警告：auto mode 比跳过校验安全，但**不是高危基础设施上仔细人工审查的替代品**。

**主要来源**：[Anthropic 工程博客](https://www.anthropic.com/engineering/claude-code-auto-mode) · [Permission modes 文档](https://code.claude.com/docs/en/permission-modes) · [Auto mode 配置文档](https://code.claude.com/docs/en/auto-mode-config) · [Permissions 文档](https://code.claude.com/docs/en/permissions) · [官方 CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)

---

## 二、Pi 侧：已存在三个实现（2026-08 现状）

### 2.1 关键背景：你装的 v24 fork 已原生支持模型审查架构

你当前安装的是 **`@gotgenes/pi-permission-system` v24.0.0**（不是上游 MasuRii/pi-permission-system 0.8.0）。v24 有一个 **ADR 0007 的 Authorizer chain 架构**：

- `PermissionsService.registerAuthorizer(name, fn)` — 外部扩展可注册一个具名 chain link；
- link 收到 `ask` 时返回 `allow` / `deny`（带 reason）/ `defer`（传给下一级）；
- 终端 link 是 `LocalUserAuthorizer`（弹 UI 问人）；
- **opt-in**：link 只有在你的 `config.json` 的 `authorizerChain: ["..."]` 里列名才生效。

也就是说：**"让另一个模型先审，审不了再问人"正是这个架构预留的插槽**——不需要 fork，装一个注册了 authorizer 的插件、在配置里启用即可。

### 2.2 三个现成插件

| 包 | 版本 | 审查模型 | 机制 | 亮点 |
| --- | --- | --- | --- | --- |
| **`@gotgenes/pi-permission-model-judge`** | 1.1.2 | 任意 pi provider/model（默认示例 claude-haiku） | 注册 `"model-judge"` link，只审 `external_directory` 路径**拼写错误** | 作者即 gotgenes（你 fork 的作者）；fail-safe（任何异常→defer）；只 deny 从不 allow；强制 `toolChoice: "any"` 结构化 verdict；timeout 5s |
| **`@mzwing/pi-permission-auto-review`** | 0.1.4 | **`openai-codex` provider 的 `codex-auto-review` 模型**（OpenAI 官方训练的权限审查模型，可换自定义 provider/model） | 注册 `"auto-review"` link，Codex 风格自动审批；**可 allow/deny/defer** | 内置基线风险策略（risk_level + user_authorization 判定 + hard-deny 规则：凭据外泄/安全弱化/prompt injection）；**3 连拒或 50 次内 10 拒触发 circuit breaker**；transcript 只信 `user` 来源记录（防注入）；支持 additionalPolicy |
| **`@erichll/pi-auto-review`** | 0.3.4 | 同上（`codex-auto-review`） | 更重的 broker 架构：注册 `pi-auto-review` link + 跨扩展 broker service + sandbox 适配器接口 | 模型审批 + 一次性过期授权（sandbox 边界请求）；TUI 自动确认桥；人工 retry override 绑定完整请求 hash；同样有 circuit breaker |

三者均：缺模型/缺 auth/超时/解析失败 → **defer 回人工提示**（fail-safe，绝不放行）；都在 pi-permission-system 的共享 review log（`~/.pi/agent/extensions/pi-permission-system/logs/pi-permission-system-permission-review.jsonl`）留审计轨迹。

### 2.3 安装启用方式（以 mzwing 为例）

```bash
pi install npm:@gotgenes/pi-permission-system   # 已安装
pi install npm:@mzwing/pi-permission-auto-review
```

```jsonc
// ~/.pi/agent/extensions/pi-permission-system/config.json
{ "authorizerChain": ["auto-review"] }   // 显式启用
```

```jsonc
// ~/.pi/agent/extensions/pi-permission-auto-review/config.json（可选，默认即用）
{
  "provider": "openai-codex",
  "model": "codex-auto-review",
  "reasoning": "low",
  "timeoutMs": 90000,
  "includeBaselinePolicy": true
}
```

**来源**：npm registry 元数据 + 三个包解包后的 README/源码（本地已存 `/tmp/pkg-extract/`）。

---

## 三、你的环境现状（本地核实）

| 项 | 状态 |
| --- | --- |
| 已安装 | `@gotgenes/pi-permission-system` **24.0.0**（支持 `registerAuthorizer` + `authorizerChain` ✅） |
| 当前配置 | `~/.pi/agent/extensions/pi-permission-system/config.json`：静态规则（`*` allow + bash 危险命令 ask/deny），**未设置 `authorizerChain`**，`yoloMode: false` |
| 可用模型 provider | `deepseek` / `google`(gemini) / `openrouter` / `xiaomi-token-plan-cn`（sops 加密 key）——**没有 `openai-codex`**，也没有 anthropic |
| 已装扩展中的先例 | `pi-hermes-memory` 已在生产环境用 **`completeSimple` from `@earendil-works/pi-ai/compat` + `ctx.modelRegistry`** 在扩展内直接调用模型（review-memory-ops.ts）——证明 Pi 扩展内嵌模型调用路径是官方支持且可用的 |

⚠️ 注意：mzwing/erichll 的**默认审查模型 `codex-auto-review` 在你的环境不可用**（无 openai-codex provider）。但两个包都支持自定义 `provider`/`model`——可指向 `google`（如 gemini-flash 系列）或 `openrouter`。gotgenes 的 model-judge 本来就任意 provider。

---

## 四、若仍需自己实现：fork 可行性评估

### 4.1 好消息：不需要 fork 主包

- v24 的 `registerAuthorizer` seam 是**设计好的扩展点**（ADR 0007 §4，跨包注册），三个现成插件就是走这条路的证明。
- 最小实现 = **一个独立的 Pi 扩展**（不碰 pi-permission-system 源码）：在 factory 里 `getPermissionsService().registerAuthorizer("my-review", authorize)`，`authorize` 里对 `ask` 组装 prompt → 调模型 → 返回 `{kind:"allow"}` / `{kind:"deny",reason}` / `{kind:"defer"}`。模型调用直接复用 `@earendil-works/pi-ai` 的 `complete` + toolChoice（gotgenes model-judge 的 `model-review.ts` 就是一份可直接参考的最小实现，约 150 行）。

### 4.2 难点（若要做得"像 Claude Auto mode"）

1. **转录裁剪**（最难也最关键）：只给审查模型看用户消息 + 工具调用，剥离 assistant 散文/工具输出——防说服与注入。mzwing 已有实现（transcript.ts，40 条内 1 万 token 预算）。
2. **授权判定 prompt**：区分"用户具体授权" vs "agent 自选"。Claude 的完整固定 prompt 未公开，需自己写策略（mzwing 的 BASELINE_POLICY 是很好的起点）。
3. **电路熔断**：连续 N 次拒绝后回退人工/停止自动审查，防止越权 agent 反复试探。
4. **延迟与成本**：每次 ask 一次模型调用（stage-1 快速过滤可借鉴：先便宜模型/低 reasoning，仅疑点进贵模型）。
5. **语义细节**：v24 中 authorizer 对 `path`/`external_directory` 的 `allow` 会被降级为 `defer`（bounded-delegation checkpoint）——模型不能自动批准文件路径类请求，只能人批；`external_directory` 可通过 erichll 的 TUI 桥在特定条件下自动确认。

### 4.3 工作量估计

| 方案 | 工作量 | 说明 |
| --- | --- | --- |
| 装现成插件（推荐） | ~10 分钟 | `pi install` + 改 2 个 config；注意把审查模型换成你环境里有的（gemini/openrouter） |
| 自写最小 authorizer link | 半天 | 只做 bash 命令 deny/defer（参考 gotgenes model-review.ts ~150 行） |
| 自写完整 Claude-style 方案 | 2-5 天 | 转录裁剪 + 风险策略 + 熔断 + UI 反馈，即重造 mzwing/erichll |

---

## 五、建议

1. **直接用现成插件**，优先试 `@mzwing/pi-permission-auto-review`（最接近 Claude Auto mode 语义：可 allow、有风险策略、有熔断）。审查模型改为 `google` 或 `openrouter` 下的小模型（注意：`codex-auto-review` 是 OpenAI 专用训练模型，换成通用模型时效果会打折，`additionalPolicy` 需要自己补）。
2. 若只想要"防手滑路径"这类窄需求，`@gotgenes/pi-permission-model-judge` 更轻、作者即主包作者。
3. **保留人工兜底**：v24 的 bounded-delegation 保证模型不能自动放行文件路径类请求；bash 类仍可被模型 allow——在 `config.json` 里保留 `git push`/`rm -rf` 等硬 ask/deny 静态规则作为最终防线。
4. 审计：打开 `permissionReviewLog`（你的 config 已开），模型每次审查都会写入 `pi-permission-system-permission-review.jsonl`，可事后核对。

## 附：调研来源汇总

- Claude Code 侧（primary）：[工程博客](https://www.anthropic.com/engineering/claude-code-auto-mode) / [permission-modes](https://code.claude.com/docs/en/permission-modes) / [auto-mode-config](https://code.claude.com/docs/en/auto-mode-config) / [permissions](https://code.claude.com/docs/en/permissions) / [settings](https://code.claude.com/docs/en/settings) / [hooks-guide](https://code.claude.com/docs/en/hooks-guide) / [CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- Pi 侧（本地核实的 primary）：`@gotgenes/pi-permission-system` v24 源码（`src/authority/*`、`service.ts`）；npm 上三个插件的解包源码（`/tmp/pkg-extract/`）；`pi-hermes-memory` 的 `review-memory-ops.ts`（扩展内直接调模型的先例）；pi 官方 `docs/extensions.md`（`tool_call` hook、`modelRegistry`、`complete`）。
