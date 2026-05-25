# 架构设计

## 整体架构

MVVM + SwiftData，纯 SwiftUI 应用。

```
┌─────────────────────────────────────────────────────┐
│  Views (SwiftUI)                                     │
│  ├── ModuleListView / ContentListView / MarkdownReaderView   │
│  ├── QuizHomeView / QuizSessionView / QuizResultView         │
│  ├── ErrorBookView                                           │
│  ├── GlossaryListView / FlashcardView                        │
│  └── ProgressDashboardView                                   │
├─────────────────────────────────────────────────────┤
│  ViewModels (@Observable)                            │
│  ├── StudyViewModel    刷题会话管理                   │
│  ├── GlossaryViewModel 卡片组管理                     │
│  └── ProgressViewModel 统计聚合                      │
├─────────────────────────────────────────────────────┤
│  Services                                            │
│  └── DataLoader        加载 Bundle 内 JSON/Markdown  │
├─────────────────────────────────────────────────────┤
│  Models                                              │
│  ├── Codable structs   (ModuleInfo, Question, ...)   │
│  └── SwiftData @Model  (WrongAnswerRecord, ...)     │
├─────────────────────────────────────────────────────┤
│  Resources/Content/                                  │
│  └── JSON + Markdown 文件                            │
└─────────────────────────────────────────────────────┘
```

## 数据流

```
JSON/Markdown 文件 (bundle)
    ↓ DataLoader.loadModules() / loadGlossary() / loadMarkdown()
Codable structs ([ModuleInfo], [Question], [GlossaryTerm])
    ↓ ViewModel 初始化/方法调用
@Observable ViewModel 属性
    ↓ SwiftUI 自动观察
View 重新渲染
```

持久化数据流：

```
用户答题 → StudyViewModel.submitAnswer()
    ↓
WrongAnswerRecord (@Model) → SwiftData 自动持久化
StudyDayRecord (@Model)    → SwiftData 自动持久化
```

## 导航结构

```
TabView (5 tabs)
├── 笔记 📚
│   NavigationStack
│     ModuleListView → ContentListView → MarkdownReaderView
│
├── 刷题 ✏️
│   NavigationStack
│     QuizHomeView → QuizSessionView → QuizResultView
│
├── 错题 📕
│   NavigationStack
│     ErrorBookView
│
├── 术语 📖
│   NavigationStack
│     GlossaryListView → FlashcardView (fullScreenCover)
│
└── 进度 📊
    NavigationStack
      ProgressDashboardView
```

## 文件职责

### App/
| 文件 | 职责 |
|---|---|
| `CFAStudyApp.swift` | @main 入口，配置 SwiftData ModelContainer |
| `ContentView.swift` | 5-tab TabView 根视图 |

### Models/
| 文件 | 职责 |
|---|---|
| `LocalizedString.swift` | 双语文本封装，支持 zh/en |
| `ModuleInfo.swift` | 模块元数据 + 动态内容清单 (ModuleContent) |
| `Question.swift` | 题目 + 选项 |
| `GlossaryTerm.swift` | 术语条目 |
| `WrongAnswerRecord.swift` | 错题记录 (@Model) |
| `StudyDayRecord.swift` | 每日学习统计 (@Model) |
| `ReadingProgress.swift` | 笔记阅读位置 (@Model) |

### Services/
| 文件 | 职责 |
|---|---|
| `DataLoader.swift` | 加载和解码 bundle 内所有 JSON/Markdown，全局单例 |

### ViewModels/
| 文件 | 职责 |
|---|---|
| `StudyViewModel.swift` | 刷题会话：选题、答题判定、错题保存、每日记录 |
| `GlossaryViewModel.swift` | 卡片翻转、前后导航、洗牌 |
| `ProgressViewModel.swift` | 统计聚合：正确率、连续天数、各模块进度 |

### Views/
| 文件 | 职责 |
|---|---|
| `Notes/ModuleListView.swift` | 7模块列表 |
| `Notes/ContentListView.swift` | 模块内内容类型选择（笔记/教材/...） |
| `Notes/MarkdownReaderView.swift` | MarkdownUI 渲染 + 自定义主题 |
| `Quiz/QuizHomeView.swift` | 模块+模式+数量选择 |
| `Quiz/QuizSessionView.swift` | 答题主界面 |
| `Quiz/QuizResultView.swift` | 会话结果 |
| `ErrorBook/ErrorBookView.swift` | 错题列表 + 模块筛选 |
| `Glossary/GlossaryListView.swift` | 术语搜索列表 |
| `Glossary/FlashcardView.swift` | 3D翻转卡片 |
| `Progress/ProgressDashboardView.swift` | 图表仪表盘 |

## 关键设计决策

1. **ModuleContent 动态清单**：`modules.json` 中每个模块的 `content` 数组定义可阅读内容。当前只有 notes，未来加教材/课件只需增加条目，无需改代码。

2. **LocalizedString 双语**：所有文本字段封装为 `{ zh, en }` 结构。当前 en 为 null，未来填充后 UI 可切换语言。

3. **DataLoader 单例**：使用 `@Observable` + 单例模式，SwiftUI 自动追踪数据变化。

4. **SwiftData 持久化**：错题和进度用 SwiftData @Model 类，自动持久化。与 Codable structs 分离——前者是运行时状态，后者是静态内容。
