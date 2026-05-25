# CLAUDE.md

## 项目概述

CFA-SIC 备考 iOS App。SwiftUI + SwiftData，iOS 17+。

## 技术栈

- SwiftUI (iOS 17+)
- SwiftData (持久化)
- MarkdownUI (SPM) — Markdown 渲染
- Swift Charts — 进度图表

## 目录结构

```
CFAStudyApp/
├── App/           入口 + TabView
├── Models/        Codable structs + SwiftData @Model
├── Services/      DataLoader (bundle 内容加载)
├── ViewModels/    @Observable view models
├── Views/         SwiftUI views (Notes/Quiz/ErrorBook/Glossary/Progress)
└── Resources/
    └── Content/   JSON + Markdown 课程数据
```

## 关键约定

- 所有文本用 `LocalizedString { zh, en }` 双语封装
- 模块内容通过 `modules.json` 的 `content` 数组动态配置
- 新增内容类型不需要改代码，只需更新 JSON
- 数据在 `Resources/Content/` 目录，JSON + Markdown 格式
- SwiftData models 放在 `Models/` 目录，@Model 类以 `Record` 结尾

## 内容更新流程

1. 编辑 markdown 或 JSON 文件
2. 如需从源仓库重新生成：`python convert_data.py --source /path/to/repo`
3. 在 Xcode 中重新 build

## 注意事项

- Content 目录在 Xcode 中必须是 **folder reference**（蓝色），不是 group
- `DataLoader` 使用 `Bundle.main.url(forResource:withExtension:subdirectory:)` 加载文件
- Module 05 无题目（questions 文件为空数组），需在 UI 中处理
- 部分 Question 的 `explanation` 为 null
