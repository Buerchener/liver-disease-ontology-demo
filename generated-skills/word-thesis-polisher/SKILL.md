---
name: word-thesis-polisher
description: Use when editing, rewriting, or polishing Word `.docx` thesis/report templates, especially when the user complains about ugly layout, inconsistent fonts, bad Word formatting, broken tables, page breaks, headings, lists, or wants a polished thesis/report draft generated from an existing template. The skill emphasizes code-driven DOCX style normalization, preserving the original file, and render-to-PNG visual QA.
---

# Word Thesis Polisher

Use this skill for `.docx` thesis, report, proposal, or academic-template work where layout quality matters.

## Human vs Codex Split

Before editing, identify what is faster for the user to do manually:

- User should confirm school-specific requirements: required font, page size, margins, line spacing, citation style, title page fields, word count, and supervisor preferences.
- Codex should handle repetitive and fragile formatting: style normalization, table geometry, heading hierarchy, page breaks, lists, headers/footers, and visual QA.

If requirements are unknown, use a conservative academic default unless the template itself specifies otherwise.

## Default Academic Style

Use this when no stricter instruction is available:

- Page: portrait, preserve template page size; if unclear use 2 cm margins for BNU-HKBU-style templates or 1 inch for generic reports.
- Body font: Times New Roman, 12 pt.
- Body paragraphs: justified, 1.15 line spacing, 6 pt after, first-line indent about 0.63 cm.
- Headings: Times New Roman, bold, black; Heading 1 = 16 pt, Heading 2 = 14 pt, Heading 3 = 12 pt.
- Major sections: start on a new page when the template says chapter sections should start on a new page.
- Lists: use real Word numbering definitions, not typed numbers or fake bullets.
- Tables: fixed width, explicit column widths, light borders, readable cell padding, vertically centered cells, header shading only if it improves readability.
- Cover page: preserve template fields; keep placeholders for missing student name, ID, supervisor, group ID, and date.

## Workflow

1. Preserve the original `.docx`; create a clearly named copy or output file.
2. Inspect the template structure with `python-docx`: paragraphs, styles, headings, tables, sections, headers, and footers.
3. If generating a draft, replace placeholder instructions with real content but keep required template sections.
4. Normalize styles explicitly in code:
   - Do not rely on Word defaults or inherited template styles.
   - Set run font and paragraph formatting on generated content.
   - Clear unwanted template remnants such as odd indents, duplicate page numbers, centered table body text, or incorrect heading spacing.
5. Build tables with explicit geometry:
   - Set table width and each cell width.
   - Set cell margins.
   - Use thin gray borders and restrained header fill.
   - Check that table text is not cramped, clipped, over-centered, or oddly justified.
6. Render the document with the documents skill renderer:
   - Use `render_docx.py input.docx --output_dir out --emit_pdf`.
   - Inspect representative PNG pages: cover, dense prose, every table pattern, lists, references, and the final page.
7. Iterate until visual QA is clean.

## Common Fixes

- Mixed fonts: set both `run.font.name` and East Asian font with `run._element.rPr.rFonts.set(qn("w:eastAsia"), "Times New Roman")`.
- Weird hanging text in body paragraphs: explicitly set `left_indent = 0`, `right_indent = 0`, and apply `first_line_indent` only to body paragraphs.
- Headings indented like body text: set heading first-line indent to 0.
- Lists wrapping badly: give list paragraphs their own left indent and negative first-line/hanging indent.
- Tables look ugly: avoid default table styles; set borders, widths, cell margins, vertical alignment, header fill, and paragraph alignment manually.
- Duplicate page numbers: inspect inherited footers before adding a page number field.
- Title at page bottom: insert a page break before major sections or set keep-with-next style where appropriate.
- References spill awkwardly: slightly reduce reference paragraph spacing or font size, but do not shrink main body text.

## Output Discipline

- Return only the final `.docx` unless the user asks for PDFs or page images.
- Mention whether render QA was completed.
- If the draft still contains placeholders, list the exact fields the user should fill.
- Do not claim final academic correctness for references or scientific claims unless they were verified in the current turn.
