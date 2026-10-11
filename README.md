# Deck Companion

Decky Loader 插件（游戏模式）：

- **翻译**：按需截图 → OCR → 大模型翻译（主要面向日语文字类游戏 → 中文），译文叠加在原文位置。
- **学习**（开发中）：列出当前句子用到的单词和语法，记录到本地生词本，可导出 Anki。
- **对话**（开发中）：带截图和当前游戏信息向 AI 提问、查攻略；伴侣网页支持中文输入和语音。

大模型统一走 OpenAI 兼容接口，API Key 只保存在本机。

## 开发

在 devbox 里：

```bash
corepack enable && pnpm install
pnpm build          # 前端 → dist/index.js
pnpm test
```

## 许可与来源

GPL-3.0（见 `LICENSE`），第三方依赖见 `THIRD_PARTY_LICENSES`。

本项目修改自以 GPL-3.0 发布的 Decky Translator 及其衍生版本 Decky LLM Translator，
2026 年 10 月起独立维护并做了大量修改。
