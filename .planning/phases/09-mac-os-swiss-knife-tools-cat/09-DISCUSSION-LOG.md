# Phase 9: mac-os-swiss-knife-tools-cat - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-13T09:36:01Z
**Phase:** 09-mac-os-swiss-knife-tools-cat
**Areas discussed:** 更名深度, Bundle Identifier 策略, 中文显示名写法, 兼容策略

---

## 更名深度

| Option | Description | Selected |
|--------|-------------|----------|
| 全量改 | UI、文档、Xcode target/scheme、`.app` 名、测试 target、目录名、模块名、脚本默认值一起改 | ✓ |
| 只改表层 | 只改 UI 和文档，底层工程命名保留旧名 | |
| 混合改 | 只改一部分工程命名，其余保留旧名兼容 | |

**User's choice:** 按推荐值执行，全量改。
**Notes:** 用户接受推荐，不保留“只改表层”或“混合过渡”方案。

---

## Bundle Identifier 策略

| Option | Description | Selected |
|--------|-------------|----------|
| 一起改成 `Tools Cat` 系列 | 应用和测试 bundle id 一起迁移到新品牌 | ✓ |
| 保留旧 bundle id | 只改展示名和工程名，bundle id 继续用旧名 | |
| 分裂策略 | 主 app 改名，测试或部分 bundle 维持旧 id | |

**User's choice:** 按推荐值执行，bundle identifier 一起改。
**Notes:** 不保留 `cn.notfound945.Mac-OS-Swiss-Knife*` 作为当前主命名。

---

## 中文显示名写法

| Option | Description | Selected |
|--------|-------------|----------|
| 仍显示 `Tools Cat` | 中文界面里品牌名直接使用英文 `Tools Cat` | ✓ |
| 单独起中文品牌 | 为中文界面另起一个中文名称 | |
| 混合显示 | 同时保留旧名或中英混排 | |

**User's choice:** 按推荐值执行，中文界面仍显示 `Tools Cat`。
**Notes:** 运行时功能文案继续中文，但品牌本身不再另起中文别名。

---

## 兼容策略

| Option | Description | Selected |
|--------|-------------|----------|
| 硬切 | 仓库和当前文档直接全面替换，不保留双品牌过渡 | ✓ |
| 过渡双品牌 | 一段时间内同时保留旧名和新名 | |
| 文档过渡 | 代码硬切，但文档保留双品牌说明 | |

**User's choice:** 按推荐值执行，硬切。
**Notes:** 历史/归档材料可以保留旧名作为历史事实，但当前活跃工程与文档不做双品牌过渡。

---

## the agent's Discretion

- 具体的 Xcode target/module/文件名重命名顺序
- 是否在归档材料中保留最小历史说明
- 下划线、连字符和空格变体在新名称下的具体规范化方式

## Deferred Ideas

- 单独的中文品牌名
- 双品牌兼容期
- 借更名顺手做签名、公证或其他发行流程扩展
