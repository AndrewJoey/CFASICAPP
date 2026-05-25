#!/usr/bin/env python3
"""
convert_data.py — 将 CFA-SIC 学习资料仓库的内容转换为 App JSON 数据

用法:
    python convert_data.py --source /path/to/CFA-SIC(before-CFA-ESG)selflearning

输出:
    CFAStudyApp/Resources/Content/
    ├── manifest.json
    ├── modules.json
    ├── questions/module-01~07.json
    ├── glossary.json
    └── content/module-01~07/notes.zh.md
"""

import argparse
import json
import os
import re
import shutil
import sys
from pathlib import Path


# ─── 配置 ──────────────────────────────────────────────────────────────────────

MODULES_CONFIG = [
    {"num": 1, "slug": "module-01-intro",              "titleZh": "ESG 投资简介",                    "titleEn": "Introduction to ESG Investing",                      "weight": "~10%"},
    {"num": 2, "slug": "module-02-environmental",       "titleZh": "环境因素",                        "titleEn": "Environmental Factors",                              "weight": "~10-15%"},
    {"num": 3, "slug": "module-03-social",              "titleZh": "社会因素",                        "titleEn": "Social Factors",                                    "weight": "~10%"},
    {"num": 4, "slug": "module-04-governance",          "titleZh": "治理因素",                        "titleEn": "Governance Factors",                                "weight": "~15-20%"},
    {"num": 5, "slug": "module-05-stewardship",         "titleZh": "股东参与与尽责管理",              "titleEn": "Engagement and Stewardship",                        "weight": "~10%"},
    {"num": 6, "slug": "module-06-analysis-valuation",  "titleZh": "ESG 分析、估值与整合",            "titleEn": "ESG Analysis, Valuation and Integration",           "weight": "~15%"},
    {"num": 7, "slug": "module-07-portfolio",           "titleZh": "ESG 整合型投资组合构建与管理",    "titleEn": "ESG Integrated Portfolio Construction and Management","weight": "~10-15%"},
]

SCRIPT_DIR = Path(__file__).parent
OUTPUT_DIR = SCRIPT_DIR / "CFAStudyApp" / "Resources" / "Content"


# ─── 题目解析 ──────────────────────────────────────────────────────────────────

def parse_questions_file(filepath: Path, module_num: int) -> list[dict]:
    """解析单个模块的题目 markdown 文件"""
    text = filepath.read_text(encoding="utf-8")

    # 按 --- 分隔题目块
    blocks = re.split(r'\n---\n', text)
    questions = []

    for block in blocks:
        block = block.strip()
        if not block or '### Q' not in block:
            continue

        # 提取题号和题干
        q_match = re.match(r'###\s*Q(\d+)[.\s]*(.*)', block, re.DOTALL)
        if not q_match:
            continue
        number = int(q_match.group(1))
        rest = q_match.group(2)

        # 提取选项（在 <details> 之前的部分）
        details_split = re.split(r'<details>', block, maxsplit=1)
        question_part = details_split[0]

        # 题干：选项行之前的内容
        option_lines = re.findall(r'^-\s+\*\*([A-D])\.\*\*\s*(.*)', question_part, re.MULTILINE)
        # 找到第一个选项的位置，之前的就是题干
        first_option_pos = None
        for m in re.finditer(r'^-\s+\*\*[A-D]\.\*\*', question_part, re.MULTILINE):
            first_option_pos = m.start()
            break

        if first_option_pos:
            # 题干 = Q行到第一个选项之间的内容（去掉Q行本身）
            q_header = f"### Q{number}."
            after_header = rest
            # 清理题干：去掉选项部分
            question_text = question_part
            question_text = re.sub(r'^###\s*Q\d+[.\s]*', '', question_text, count=1, flags=re.MULTILINE)
            question_text = question_text[:first_option_pos - len(f"### Q{number}. " if f"### Q{number}. " in question_part else len(f"### Q{number}."))].strip()
            # 更简单的方法：取 rest 然后截取到选项开始
            lines_after_q = rest.split('\n')
            q_lines = []
            for line in lines_after_q:
                if re.match(r'^-\s+\*\*[A-D]\.\*\*', line):
                    break
                q_lines.append(line)
            question_text = '\n'.join(q_lines).strip()
        else:
            question_text = rest.strip()

        if not question_text:
            continue

        # 提取选项
        options = []
        for label, opt_text in option_lines:
            options.append({"label": label, "text": {"zh": opt_text.strip(), "en": None}})

        if len(options) != 4:
            print(f"  ⚠ Q{number} in module {module_num}: found {len(options)} options, expected 4")
            continue

        # 提取答案、考点、解析
        correct_answer = None
        topic = None
        explanation = None

        if len(details_split) > 1:
            details_content = details_split[1]

            # 正确答案
            ans_match = re.search(r'\*\*正确答案[：:]\s*([A-D])\*\*', details_content)
            if ans_match:
                correct_answer = ans_match.group(1)

            # 考点
            topic_match = re.search(r'\*\*考点[：:]\*\s*(.*)', details_content)
            if topic_match:
                topic = topic_match.group(1).strip()

            # 解析
            expl_match = re.search(r'\*\*解析[：:]\*\s*(.*?)(?:\n</details>|$)', details_content, re.DOTALL)
            if expl_match:
                expl_text = expl_match.group(1).strip()
                if expl_text:
                    explanation = expl_text

        if not correct_answer:
            print(f"  ⚠ Q{number} in module {module_num}: no correct answer found")
            continue

        q_id = f"m{module_num:02d}-q{number:03d}"
        questions.append({
            "id": q_id,
            "moduleId": f"module-{module_num:02d}",
            "number": number,
            "text": {"zh": question_text, "en": None},
            "options": options,
            "correctAnswer": correct_answer,
            "topic": {"zh": topic, "en": None} if topic else None,
            "explanation": {"zh": explanation, "en": None} if explanation else None,
            "source": "v7-bank",
            "tags": []
        })

    return questions


# ─── 术语表解析 ────────────────────────────────────────────────────────────────

def parse_glossary(filepath: Path) -> list[dict]:
    """解析 glossary.md"""
    text = filepath.read_text(encoding="utf-8")
    terms = []
    current_letter = ""

    for line in text.split('\n'):
        # 检测字母分区
        heading_match = re.match(r'^##\s+([A-Z])', line)
        if heading_match:
            current_letter = heading_match.group(1)
            continue

        # 解析表格行: | **Term** *| 中文 | 解释 |
        # 格式可能有变化，需要灵活匹配
        row_match = re.match(
            r'^\|\s*\*\*(.+?)\*\*\s*\\?\*?\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|',
            line
        )
        if row_match:
            english = row_match.group(1).strip()
            chinese = row_match.group(2).strip()
            explanation = row_match.group(3).strip()

            # 检测高频标记 *
            is_high_freq = '* \\*' in line or '**\\***' in line or re.search(r'\*\*.*\*\\?\*', line) is not None
            # 更简单的检测：看原文是否有 \*
            is_high_freq = '\\*' in line.split('|')[0] or '* \\*' in line or '**\\*' in line

            # 生成 id
            term_id = re.sub(r'[^a-z0-9]+', '-', english.lower()).strip('-')

            terms.append({
                "id": term_id,
                "english": english,
                "chinese": chinese,
                "explanation": {"zh": explanation, "en": None},
                "isHighFrequency": is_high_freq,
                "letter": current_letter,
                "category": None
            })

    return terms


# ─── 主流程 ────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Convert CFA-SIC study content to App JSON")
    parser.add_argument("--source", required=True, help="Path to the study content repo")
    args = parser.parse_args()

    source = Path(args.source)
    if not source.exists():
        print(f"Error: source directory not found: {source}")
        sys.exit(1)

    # 清理并创建输出目录
    if OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)
    OUTPUT_DIR.mkdir(parents=True)
    (OUTPUT_DIR / "questions").mkdir()
    (OUTPUT_DIR / "content").mkdir()

    print("=== CFA-SIC Content Converter ===\n")

    # ── 1. 生成 manifest.json ──
    total_questions = 0
    for m in MODULES_CONFIG:
        q_file = source / "questions" / f"module-{m['num']:02d}.md"
        if q_file.exists():
            qs = parse_questions_file(q_file, m["num"])
            total_questions += len(qs)

    manifest = {
        "id": "cfa-sic",
        "version": "7.0.0",
        "title": {"zh": "CFA-SIC 可持续投资证书备考", "en": "CFA-SIC Exam Preparation"},
        "description": {
            "zh": "CFA Institute 可持续投资证书（原 ESG Investing Certificate）备考学习工具",
            "en": "CFA Institute Certificate in Sustainable Investing & Climate Exam Prep"
        },
        "totalModules": 7,
        "totalQuestions": total_questions,
        "languages": ["zh", "en"],
        "lastUpdated": "2025-05-25"
    }

    (OUTPUT_DIR / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"manifest.json: {manifest['totalQuestions']} total questions across {manifest['totalModules']} modules")

    # ── 2. 解析题目并按模块输出 ──
    modules_data = []

    for m in MODULES_CONFIG:
        module_id = f"module-{m['num']:02d}"
        q_file = source / "questions" / f"module-{m['num']:02d}.md"
        notes_dir = source / "notes" / m["slug"]

        # 解析题目
        questions = []
        if q_file.exists():
            questions = parse_questions_file(q_file, m["num"])
            print(f"module-{m['num']:02d}: {len(questions)} questions parsed")
        else:
            print(f"module-{m['num']:02d}: no questions file (skipped)")

        # 写入题目 JSON
        q_out = OUTPUT_DIR / "questions" / f"{module_id}.json"
        q_out.write_text(
            json.dumps(questions, ensure_ascii=False, indent=2), encoding="utf-8"
        )

        # 复制笔记 markdown
        has_notes = False
        notes_src = notes_dir / "README.md"
        content_module_dir = OUTPUT_DIR / "content" / module_id
        if notes_src.exists():
            content_module_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(notes_src, content_module_dir / "notes.zh.md")
            has_notes = True
            print(f"  notes copied: {m['slug']}/README.md → content/{module_id}/notes.zh.md")

        # 构建模块元数据
        content_list = []
        if has_notes:
            content_list.append({
                "type": "notes",
                "title": {"zh": "学习笔记", "en": "Study Notes"},
                "icon": "book.fill",
                "files": {"zh": f"content/{module_id}/notes.zh.md"}
            })

        modules_data.append({
            "id": module_id,
            "number": m["num"],
            "title": {"zh": m["titleZh"], "en": m["titleEn"]},
            "examWeight": m["weight"],
            "questionCount": len(questions),
            "questionsFile": f"questions/{module_id}.json",
            "content": content_list
        })

    # 写入 modules.json
    (OUTPUT_DIR / "modules.json").write_text(
        json.dumps(modules_data, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"\nmodules.json: {len(modules_data)} modules written")

    # ── 3. 解析术语表 ──
    glossary_file = source / "glossary.md"
    if glossary_file.exists():
        terms = parse_glossary(glossary_file)
        (OUTPUT_DIR / "glossary.json").write_text(
            json.dumps(terms, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        high_freq = sum(1 for t in terms if t["isHighFrequency"])
        print(f"glossary.json: {len(terms)} terms ({high_freq} high-frequency)")
    else:
        print("Warning: glossary.md not found")

    # ── 完成 ──
    print(f"\n=== Conversion complete ===")
    print(f"Output: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
