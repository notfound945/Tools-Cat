# Phase 4: Timed Keep-Awake - Context

**Gathered:** 2026-04-12
**Status:** Ready for planning

<domain>
## Phase Boundary

把现有“保持屏幕常亮”从单一开关扩展为一组原生菜单控制项，让用户可以直接从菜单栏选择无限常亮或定时常亮，并在会话进行中看到实时倒计时，到时自动关闭。该阶段只覆盖菜单控制、时长预设、倒计时反馈和自动结束语义，不包含新窗口、通知、快捷键、后台自动化或更广泛的菜单美化。

</domain>

<decisions>
## Implementation Decisions

### 菜单结构
- **D-01:** keep-awake 控制采用主菜单直接展开的结构，而不是收进子菜单。
- **D-02:** 主菜单中的 keep-awake 动作项应作为同一组并列展示：`无限常亮`、`15 分钟`、`30 分钟`、`1 小时`、`2 小时`。
- **D-03:** 不保留旧的单一“保持屏幕常亮”切换项作为并列入口；无限模式与定时模式统一归入同一组动作项。
- **D-04:** 用户必须始终看得到一个明确的手动关闭入口，使用单独一行 `关闭常亮`，而不是依赖再次点击当前激活项来关闭。

### 时长与切换语义
- **D-05:** 定时常亮的预设时长固定为 `15 分钟`、`30 分钟`、`1 小时`、`2 小时`。
- **D-06:** 如果当前已有定时常亮会话在运行，再次选择新的定时时长或切换到无限常亮时，应直接替换为新选择，不做二次确认。
- **D-07:** 定时常亮自然结束后，状态应直接回到关闭，而不是切回无限常亮或保留新的活动会话。

### 倒计时与状态反馈
- **D-08:** 实时倒计时只显示在 keep-awake 的状态行中，不写进动作项标题。
- **D-09:** 动作项标题应保持稳定、可扫描，不因倒计时每秒变化而频繁跳动。
- **D-10:** 定时结束后不额外保留“已结束”提示；菜单直接回到关闭状态的常规呈现。

### 与既有真实状态语义的衔接
- **D-11:** 仍然沿用 Phase 1 的真实状态原则：稳定态 UI 只能在底层 assertion 状态真正切换成功后更新。
- **D-12:** keep-awake 菜单仍应保持紧凑、原生，不引入长说明文案或新的设置型交互。

### the agent's Discretion
- 无限常亮与定时项的精确中文文案，只要保持短、直观、便于扫描。
- 状态行倒计时的具体格式，例如“还剩 28 分钟”是否在低于 1 分钟时切到秒级显示。
- 活跃 keep-awake 模式在菜单中的高亮方式，例如 checkmark、disabled 状态、或补充状态行组合。
- 定时会话的内部计时实现方式，以及它与 `PowerAssertionManager` / `KeepAwakePowerControlling` 的衔接模型。

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` — 定义 Phase 4 的目标、成功标准，以及“原生菜单控制 + 明确时长 + 倒计时 + 自动结束”的范围边界。
- `.planning/REQUIREMENTS.md` — 定义 `AWAKE-01`、`AWAKE-02`、`AWAKE-03`、`AWAKE-04`，并给出本里程碑的范围约束。

### Project and prior-phase constraints
- `.planning/PROJECT.md` — 定义核心价值、原生 macOS 方向、可靠性要求，以及“小而克制”的产品约束。
- `.planning/STATE.md` — 确认当前焦点已进入 Phase 4。
- `.planning/phases/01-truthful-foundations/01-CONTEXT.md` — 继承 keep-awake 的真实状态语义、过渡态反馈和失败时保持已确认状态的约束。
- `.planning/phases/03-saved-device-wake-flows/03-CONTEXT.md` — 继承菜单保持紧凑、状态行承载轻量反馈、不要把根菜单做成长列表的约束。

### Existing product behavior
- `README.md` — 描述当前菜单栏工具的运行模型和现有 keep-awake / WOL 能力。

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Mac OS Swiss Knife/StatusBarController.swift`：当前 keep-awake 菜单项、状态行、图标更新和点击处理都在这里，Phase 4 的菜单扩展会主要落在这个控制器中。
- `Mac OS Swiss Knife/KeepAwakePresentation.swift`：已经承载 keep-awake 的标题、图标、状态行文案，是继续抽象定时/无限状态展示的自然位置。
- `Mac OS Swiss Knife/PowerAssertionManager.swift`：当前唯一的 assertion 真实状态边界，后续定时会话必须继续以它的成功/失败结果为准。
- `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift`：已经覆盖 keep-awake 的过渡态、成功、失败和防重复点击行为，可扩展为 timed keep-awake 的主要回归测试入口。
- `Mac OS Swiss Knife/AppDelegate.swift`：目前负责应用生命周期和退出时关闭 keep-awake，可作为共享 timed session 的组合点。

### Established Patterns
- AppKit 负责菜单壳层和长期持有的控制器，状态逻辑通过专门的 session/presentation 类型向菜单暴露。
- 稳定态 UI 只在底层副作用成功后更新；失败时保留之前的确认状态并展示清晰错误信息。
- 菜单中的轻量状态反馈优先用单独状态行承载，而不是持续改写高频动作项本身。
- 运行时用户文案保持中文，类型和 API 名保持英文。

### Integration Points
- `StatusBarController` 需要从单一 toggle 演进为一组 keep-awake 动作项加一个统一状态行。
- `KeepAwakePresentation` 需要从“开/关 + 过渡态”扩展到“关闭 / 无限 / 定时进行中 / 定时即将结束”等更丰富的展示状态。
- `KeepAwakePowerControlling` 与 `PowerAssertionManager` 仍是底层开关边界，但 Phase 4 需要在其之上增加定时会话状态与倒计时驱动。
- 退出应用时的清理逻辑需要兼容 timed session，确保 app 终止时 assertion 被正确释放。

</code_context>

<specifics>
## Specific Ideas

- keep-awake 的菜单应直接展开成一组并列项，而不是嵌套子菜单。
- 用户必须能直接看到一行明确的 `关闭常亮`，作为手动提前结束 keep-awake 的入口。
- 用户明确选择的预设时长是：15 分钟、30 分钟、1 小时、2 小时。
- 倒计时只放在状态行，不写进动作项标题，保证动作项稳定可扫描。
- 运行中再次选择新的 keep-awake 模式时直接替换，无需确认。
- 定时结束后直接回到关闭状态，不额外保留“已结束”提示。

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 04-timed-keep-awake*
*Context gathered: 2026-04-12*
