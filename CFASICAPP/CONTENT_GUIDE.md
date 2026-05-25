# 内容维护指南

## 目录结构

```
CFAStudyApp/Resources/Content/
├── manifest.json              课程元数据
├── modules.json               模块列表 + 内容清单
├── questions/                 题库
│   ├── module-01.json
│   ├── module-02.json
│   ├── module-03.json
│   ├── module-04.json
│   ├── module-05.json         （空数组，无题目）
│   ├── module-06.json
│   └── module-07.json
├── glossary.json              术语表
└── content/                   阅读内容
    ├── module-01/
    │   └── notes.zh.md
    ├── module-02/
    │   └── notes.zh.md
    └── ...
```

## JSON 格式规范

### manifest.json

```json
{
  "id": "cfa-sic",
  "version": "7.0.0",
  "title": { "zh": "...", "en": "..." },
  "description": { "zh": "...", "en": "..." },
  "totalModules": 7,
  "totalQuestions": 637,
  "languages": ["zh", "en"],
  "lastUpdated": "2025-05-25"
}
```

### modules.json

每个模块的 `content` 数组定义该模块可阅读的内容类型：

```json
[
  {
    "id": "module-01",
    "number": 1,
    "title": { "zh": "ESG 投资简介", "en": "Introduction to ESG Investing" },
    "examWeight": "~10%",
    "questionCount": 83,
    "questionsFile": "questions/module-01.json",
    "content": [
      {
        "type": "notes",
        "title": { "zh": "学习笔记", "en": "Study Notes" },
        "icon": "book.fill",
        "files": { "zh": "content/module-01/notes.zh.md" }
      }
    ]
  }
]
```

**ModuleContent type 约定值**：

| type | 含义 | 建议 icon |
|---|---|---|
| `notes` | 学习笔记 | `book.fill` |
| `textbook` | 教材内容 | `text.book.closed.fill` |
| `courseware` | 课件 | `doc.richtext` |
| `summary` | 重点小结 | `star.fill` |
| `formulas` | 公式表 | `function` |
| `flashcards` | 重点卡片 | `rectangle.on.rectangle.angled` |

### questions/module-XX.json

```json
[
  {
    "id": "m01-q001",
    "moduleId": "module-01",
    "number": 1,
    "text": { "zh": "题干", "en": null },
    "options": [
      { "label": "A", "text": { "zh": "选项", "en": null } },
      { "label": "B", "text": { "zh": "选项", "en": null } },
      { "label": "C", "text": { "zh": "选项", "en": null } },
      { "label": "D", "text": { "zh": "选项", "en": null } }
    ],
    "correctAnswer": "B",
    "topic": { "zh": "考点", "en": null },
    "explanation": { "zh": "解析", "en": null },
    "source": "v7-bank",
    "tags": []
  }
]
```

**字段说明**：
- `id`：格式 `m{模块号2位}-q{题号3位}`
- `en`：当前可为 null，未来英文版填充
- `explanation`：可为 null（部分题目无解析）
- `source`：题目来源标识
- `tags`：知识点标签数组

### glossary.json

```json
[
  {
    "id": "active-ownership",
    "english": "Active Ownership",
    "chinese": "积极所有权",
    "explanation": { "zh": "解释文本", "en": null },
    "isHighFrequency": true,
    "letter": "A",
    "category": null
  }
]
```

### LocalizedString 格式

所有双语文本统一格式：

```json
{ "zh": "中文内容", "en": "English content" }
```

`en` 可为 `null`，App 默认显示 `zh`。

---

## 如何添加新内容

### 添加新模块内容（如教材、课件）

1. 在 `content/module-XX/` 下创建新的 markdown 文件：
   ```
   content/module-01/textbook.zh.md
   ```

2. 在 `modules.json` 对应模块的 `content` 数组中添加条目：
   ```json
   {
     "type": "textbook",
     "title": { "zh": "教材内容", "en": "Textbook" },
     "icon": "text.book.closed.fill",
     "files": { "zh": "content/module-01/textbook.zh.md" }
   }
   ```

3. 重新运行 App — ContentListView 会自动显示新内容类型

### 添加新题目

直接编辑 `questions/module-XX.json`，按现有格式追加新题目到数组末尾。

同步更新：
- `modules.json` 中对应模块的 `questionCount`
- `manifest.json` 中的 `totalQuestions`

### 添加新术语

直接编辑 `glossary.json`，按现有格式追加。`letter` 字段用于字母分组。

### 添加英文内容

将 JSON 中 `en: null` 替换为实际英文文本即可。Markdown 内容在 `files` 中增加 `"en"` 路径：
```json
"files": { "zh": "content/module-01/notes.zh.md", "en": "content/module-01/notes.en.md" }
```

---

## convert_data.py 使用

从学习资料仓库重新生成所有 JSON：

```bash
python convert_data.py --source /path/to/CFA-SIC\(before-CFA-ESG\)selflearning
```

会覆盖 `CFAStudyApp/Resources/Content/` 下的所有文件。

**注意**：如果手动修改过 JSON，重跑脚本会覆盖修改。建议在版本控制中跟踪变更。

---

## 常见问题

**Q: 新增的 markdown 文件没有显示？**
A: 确保 Xcode 中 Content 目录是 folder reference（蓝色文件夹），不是 group。检查 modules.json 中 files 路径是否正确。

**Q: 题目 JSON 格式错误？**
A: 用 `python3 -m json.tool questions/module-XX.json` 验证 JSON 语法。

**Q: 如何调试数据加载？**
A: DataLoader 的 print 语句会输出到 Xcode console。
