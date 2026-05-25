# CFA-SIC 备考 App

CFA-SIC (Certificate in Sustainable Investing & Climate) 备考学习 iOS 应用。

## 功能

- **笔记浏览** — 7个模块学习笔记，支持 Markdown 渲染（表格、代码块、blockquote）
- **刷题练习** — 637道V7考纲模拟题，支持顺序/随机/仅错题模式
- **错题本** — 自动记录答错题目，支持按模块筛选和重做
- **术语卡片** — 157个ESG核心术语，Anki风格翻转卡片
- **学习进度** — 正确率曲线、连续天数、各模块进度追踪

## 技术栈

- **SwiftUI** + **SwiftData** (iOS 17+)
- **MarkdownUI** — Markdown 渲染
- **Swift Charts** — 进度图表
- 所有数据离线打包，无需网络

## 快速开始

1. 用 Xcode 打开 `CFAStudyApp.xcodeproj`
2. 等待 SPM 下载 MarkdownUI 依赖
3. 选择模拟器或真机，点击 Run

## 内容数据

课程内容存储在 `CFAStudyApp/Resources/Content/`：

```
Content/
├── manifest.json      课程元数据
├── modules.json       模块列表（含动态内容清单）
├── questions/         按模块拆分的题库 JSON
├── glossary.json      术语表
└── content/           Markdown 笔记文件
    └── module-XX/
        └── notes.zh.md
```

内容更新流程：修改 markdown → 更新 JSON → 重新打包 App。

详见 [CONTENT_GUIDE.md](CONTENT_GUIDE.md)。

## 文档

- [ARCHITECTURE.md](ARCHITECTURE.md) — 架构设计和数据流
- [CONTENT_GUIDE.md](CONTENT_GUIDE.md) — 内容维护指南
- [CLAUDE.md](CLAUDE.md) — AI 辅助开发指引

## 环境要求

- Xcode 15+
- iOS 17.0+
