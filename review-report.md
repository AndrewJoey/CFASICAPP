# 题库问题审查报告

生成日期：2026-06-02

---

## 摘要

| 文件 | 问题类型 | 数量 |
|------|----------|------|
| `module-01.json` | 题干/选项错配（text 字段嵌入了错误题目的完整内容） | 2 |
| `mock-b.json` | 答案与解析矛盾 | 2 |
| `mock-c.json` | 重复 ID + 题干文本截断为单个数字 | 6 个 ID 共 12 条重复记录 |

**总计：10 个有缺陷的题目条目需要修复。**

---

## 一、module-01.json — 题干/选项错配

### 1.1 m01-q040（第 40 题）

| 字段 | 内容 |
|------|------|
| **ID** | `m01-q040` |
| **number** | 40 |
| **text.zh**（当前值） | `"Which of the following statements about proxy advisory firms is correct? 纠错取消 A Proxy advisory firms manage investors' portfolios directly B Proxy advisory firms provide advice on proxy voting decisions to investors C Proxy advisory firms set ESG rating standards for enterprises D Proxy advisory firms force enterprises to improve ESG performance 【单选题】 正确答案：B 你的答案： 考点：1.可持续投资导论 答案解析： Proxy advisory firms (such as ISS, Glass Lewis) provide professional advice on proxy voting to investors, including analyzing corporate proposals and making voting recommendations. A is the role of fund managers, C is the role of ESG rating agencies, D is incorrect (they cannot force enterprises). 我的笔记： 41Which of the following is a limitation of ESG ratings?"` |
| **选项 A** | ESG ratings are too comprehensive |
| **选项 B** | Different rating agencies have different rating frameworks, leading to inconsistent results |
| **选项 C** | ESG ratings are updated too frequently |
| **选项 D** | ESG ratings only focus on large enterprises |
| **correctAnswer** | B |
| **explanation.zh**（前 200 字） | "ESG评级的一大局限性在于不同评级机构采用不同的评级指标、权重设置和数据来源，导致同一企业的评级结果不一致。选项A全面性是优势而非局限，选项C更新频率高是必要的，选项D评级适用于各类企业并非局限，正确答案为B。" |

**问题描述：**
text.zh 字段包含了两道题目的混合内容。前半部分是第 40 题"关于代理咨询公司（proxy advisory firms）的正确说法"及其完整选项和答案解析（正确答案为 B），后半部分混入了第 41 题的题干"Which of the following is a limitation of ESG ratings?"。而当前的选项（A-D）实际上是关于 ESG 评级局限性的，与题干中 proxy advisory firms 的主题完全不匹配。正确答案 B 对应的是选项 B（"Different rating agencies have different rating frameworks..."），而非 proxy advisory firms 的内容。

**建议修复：**
- 将 text.zh 修正为纯题干：`"Which of the following statements about proxy advisory firms is correct?"`
- 将选项替换为 proxy advisory firms 的正确选项：
  - A: "Proxy advisory firms manage investors' portfolios directly"
  - B: "Proxy advisory firms provide advice on proxy voting decisions to investors"
  - C: "Proxy advisory firms set ESG rating standards for enterprises"
  - D: "Proxy advisory firms force enterprises to improve ESG performance"
- correctAnswer 保持 B
- explanation.zh 替换为对应的代理咨询公司解析

---

### 1.2 m01-q043（第 43 题）

| 字段 | 内容 |
|------|------|
| **ID** | `m01-q043` |
| **number** | 43 |
| **text.zh**（当前值） | `"Which of the following statements about the Principles for Responsible Investment (PRI) is correct? 纠错取消 A PRI is a mandatory regulation for all investors B PRI signatories are required to integrate ESG factors into investment decisions C PRI only accepts corporate signatories, not investor signatories D PRI sets uniform ESG rating standards for all enterprises 【单选题】 正确答案：B 你的答案： 考点：1.可持续投资导论 答案解析： PRI (Principles for Responsible Investment) is a voluntary initiative. Signatories are required to integrate ESG factors into investment decisions and stewardship practices. A is incorrect (it is voluntary), C is incorrect (main signatories are investors), D is incorrect (it does not set ESG rating standards). 我的笔记： 45What is the core principle of PRI?"` |
| **选项 A** | Pursuing maximum short-term financial returns |
| **选项 B** | Integrating ESG factors into investment decision-making and stewardship |
| **选项 C** | Excluding all high-emission enterprises |
| **选项 D** | Investing only in green industries |
| **correctAnswer** | B |
| **explanation.zh**（前 200 字） | "PRI的核心原则是要求签署方将ESG因素融入整个投资过程，包括投资决策、投资组合管理和尽责管理（股东参与）。选项A错误（PRI不要求追求短期最大回报），选项C错误（不排除所有高排放企业），选项D错误（不限于绿色产业投资），正确答案为B。" |

**问题描述：**
与 q040 相同的模式。text.zh 字段包含了两道题目的混合内容。前半部分是第 43 题"关于 PRI 的正确说法"及其完整选项和解析，后半部分混入了第 45 题的题干"What is the core principle of PRI?"。当前选项（A-D）实际上是关于 PRI 核心原则的，与题干中"哪项关于 PRI 的说法正确"的问题属于不同题目。虽然正确答案恰好都是 B 且内容相关，但选项内容与题干描述的问题不匹配。

**建议修复：**
- 将 text.zh 修正为纯题干：`"Which of the following statements about the Principles for Responsible Investment (PRI) is correct?"`
- 将选项替换为关于 PRI 的正确选项：
  - A: "PRI is a mandatory regulation for all investors"
  - B: "PRI signatories are required to integrate ESG factors into investment decisions"
  - C: "PRI only accepts corporate signatories, not investor signatories"
  - D: "PRI sets uniform ESG rating standards for all enterprises"
- correctAnswer 保持 B
- explanation.zh 替换为对应的 PRI 解析

---

## 二、mock-b.json — 答案与解析矛盾

### 2.1 mock-b-q001（第 1 题）

| 字段 | 内容 |
|------|------|
| **ID** | `mock-b-q001` |
| **number** | 1 |
| **text.zh** | "A bond issued to finance a sustainable fishing project is most likely a:" |
| **选项 A** | Human rights |
| **选项 B** | green bond. |
| **选项 C** | social bond. |
| **correctAnswer** | **A** |
| **explanation.zh**（前 200 字） | "正确答案是**蓝色债券**。蓝色债券专为具有明确海洋和海洋效益的项目融资，如可持续渔业项目。绿色债券为环境改善项目融资，社会债券为弱势群体提供基本服务和基础设施融资。" |

**问题描述：**
存在严重的答案与解析矛盾：
1. 解析明确指出"正确答案是蓝色债券"，但选项中没有"蓝色债券"（blue bond）这一选项。
2. 选项 A 的内容是"Human rights"（人权），与债券题目完全不相关，明显是数据导入错误。
3. correctAnswer 设置为 A，但选项 A 是"Human rights"，完全不合理。

**建议修复：**
- 将选项 A 替换为 "blue bond."（蓝色债券）
- correctAnswer 保持 A（对应 blue bond）
- 修正 explanation 使其与选项标签对应

---

### 2.2 mock-b-q067（第 67 题）

| 字段 | 内容 |
|------|------|
| **ID** | `mock-b-q067` |
| **number** | 67 |
| **text.zh** | "ESG ratings are primarily based on:" |
| **选项 A** | historical company data only. |
| **选项 B** | alternative data sources only. |
| **选项 C** | both historical company data and alternative data sources. |
| **correctAnswer** | **B** |
| **explanation.zh**（前 200 字） | "ESG评级主要基于历史公司数据和替代数据来源如媒体来源**两者的结合**而非单一来源。仅基于历史数据或仅基于替代数据都不完整。" |

**问题描述：**
正确答案应为 C（both historical company data and alternative data sources），但系统中记录为 B（alternative data sources only）。解析明确指出"ESG评级主要基于历史公司数据和替代数据来源两者的结合"，与选项 C 完全对应。英文解析也确认 "Correct because ESG ratings are primarily based on historical company data and alternative data sources"。

**建议修复：**
- 将 correctAnswer 从 **B** 改为 **C**

---

## 三、mock-c.json — 重复 ID 和题干截断

mock-c.json 中存在 6 个 ID 的重复记录，其中重复条目的 text.zh 字段被截断为单个数字字符（如 "5"、"6"、"4" 等），属于数据导入/转换错误。

### 3.1 mock-c-q002 — 重复条目

| 字段 | 第 1 条（正确） | 第 2 条（截断） |
|------|----------------|----------------|
| **number** | 2 | 2 |
| **text.zh** | "Which of the following social factors most likely impacts external stakeholders of a company?" | **"5"** |
| **选项 A** | Human rights | Setting a strategic asset allocation |
| **选项 B** | Working conditions, health and safety | Clarifying the client's ESG investment beliefs |
| **选项 C** | Product liability and consumer protection | Defining how ESG performance will be measured |
| **correctAnswer** | C | B |
| **解析** | 产品责任和消费者保护是外部利益相关者的社会因素 | 有效设计 ESG 投资授权书的第一步是客户明确其 ESG 投资信念 |

**建议：** 删除第 2 条截断记录（text="5" 的条目）。如果第 2 条是独立题目，应分配新 ID（如 mock-c-q025）并补全题干。

---

### 3.2 mock-c-q003 — 重复条目

| 字段 | 第 1 条（正确） | 第 2 条（截断） |
|------|----------------|----------------|
| **number** | 3 | 3 |
| **text.zh** | "Which of the following represents the steps of developing a scorecard for ESG analysis of a given" | **"6"** |
| **选项 A** | Identify sector- or company-specific ESG issues and indicators... | discount rate. |
| **选项 B** | Determine a scoring system, benchmark against peers... | cost of capital. |
| **选项 C** | Benchmark against peers, identify sector-... | revenue projections. |
| **correctAnswer** | A | C |
| **解析** | 开发 ESG 评分卡的正确步骤 | 当公司面临气候政策风险时，投资者应降低收入预测 |

**建议：** 删除第 2 条截断记录。如需保留题目内容，应分配新 ID 并补全题干。

---

### 3.3 mock-c-q004 — 重复条目

| 字段 | 第 1 条（正确） | 第 2 条（截断） |
|------|----------------|----------------|
| **number** | 4 | 4 |
| **text.zh** | "Describing ESG performance attribution at a portfolio level is difficult because:" | **"4"** |
| **选项 A** | there is a lack of third-party data providers. | I, but not II |
| **选项 B** | there is a size bias in ESG ratings in favor of large companies. | II, but not I |
| **选项 C** | many third-party data providers describe ESG attributes as an uncorrelated... | Both I and II |
| **correctAnswer** | B | B |
| **解析** | ESG 评级存在显著的规模偏差 | GRESB 评分加权三个维度 |

**建议：** 删除第 2 条截断记录。

---

### 3.4 mock-c-q005 — 重复条目

| 字段 | 第 1 条（正确） | 第 2 条（截断） |
|------|----------------|----------------|
| **number** | 5 | 5 |
| **text.zh** | "With regards to ESG analysis, which of the following statements is most accurate?" | **"1"** |
| **选项 A** | The ESG market has grown because of improvements in ESG analysis | No |
| **选项 B** | The analysis business is dominated by consultants who advise investors | Yes, Company 1 is in compliance |
| **选项 C** | Mergers and acquisitions among investors have hindered investors' ability... | Yes, Company 2 is in compliance |
| **correctAnswer** | A | A |
| **解析** | ESG 数据采集和分析方法的改进促进了市场增长 | 两家公司都未能满足 EU 分类法的三个必要要素之一 |

**建议：** 删除第 2 条截断记录。

---

### 3.5 mock-c-q008 — 重复条目（3 条）

| 字段 | 第 1 条（正确） | 第 2 条（截断） | 第 3 条（截断） |
|------|----------------|----------------|----------------|
| **number** | 8 | 8 | 8 |
| **text.zh** | "Reshoring as a result of the COVID-19 experience is most likely to counteract." | **"3"** | **"4"** |
| **选项 A** | urbanization | Japan. | Deploying solar energy |
| **选项 B** | globalization | Europe | Building flood defenses |
| **选项 C** | digital disruption. | the United States. | Expanding the use of electric vehicles |
| **correctAnswer** | B | B | B |
| **解析** | 回流直接对抗全球化趋势 | 欧洲是唯一 ESG 投资市场份额下降的地区 | 建设防洪设施是气候变化适应战略的典型示例 |

**建议：** 删除第 2 条和第 3 条截断记录。

---

### 3.6 mock-c-q009 — 重复条目（3 条）

| 字段 | 第 1 条（正确） | 第 2 条（截断） | 第 3 条（截断） |
|------|----------------|----------------|----------------|
| **number** | 9 | 9 | 9 |
| **text.zh** | "To reflect an upgrade of a company's ESG rating, an analyst valuing the company should most likely:" | **"7"** | **"9"** |
| **选项 A** | decrease the company's cost of capital. | Discussing the report with the company during their annual review dialogue | ensure financial reports are free of fraud |
| **选项 B** | not change the company's cost of capital. | Writing a tailored letter to the company requesting additional details | provide an independent review of financial reports |
| **选项 C** | increase the company's cost of capital. | Participating in a collective engagement in collaboration with other investors | provide absolute assurance that financial reports fairly represent... |
| **correctAnswer** | A | C | B |
| **解析** | ESG 评级上调可能导致公司资本成本降低 | 集体参与最有可能满足有效参与的全部六项成功因素 | 审计师的职责是提供独立的评估，提供合理保证而非绝对保证 |

**建议：** 删除第 2 条和第 3 条截断记录。

---

## 四、修复优先级建议

| 优先级 | 问题 | 原因 |
|--------|------|------|
| **P0（紧急）** | mock-b-q067 答案错误（B 应为 C） | 用户会被引导选择错误答案 |
| **P0（紧急）** | mock-b-q001 选项 A 内容错误（"Human rights"应为"blue bond"） | 选项与题目完全不相关，用户无法作答 |
| **P1（高）** | module-01 q040、q043 题干/选项错配 | 题干描述的问题与实际选项不匹配，影响用户体验 |
| **P2（中）** | mock-c 重复 ID 问题（6 个 ID） | 截断数据不影响正确题目，但增加文件体积，可能导致加载异常 |
