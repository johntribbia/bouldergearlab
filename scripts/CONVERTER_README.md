# Google Docs to Markdown Converter

Convert Google Docs (exported as .docx) directly into Boulder Gear Lab review markdown files with automatic image extraction and proper formatting.

## Setup

### Prerequisites

You need the `python-docx` and `requests` libraries:

```bash
pip install python-docx requests
```

## Usage

### Interactive Method (Recommended)

```bash
cd scripts
python3 convert_review.py
```

Then follow the prompts:
1. Paste your Google Docs URL OR select your .docx file
2. Enter review title and author(s)
3. Add tags and categories
4. Confirm output location
5. The script creates the review directory with all files

### Programmatic Method

```python
from google_doc_converter import ReviewToMarkdownConverter

# Option 1: Use Google Docs URL directly
converter = ReviewToMarkdownConverter(
    docx_path="https://docs.google.com/document/d/ABC123XYZ/edit",
    output_dir="content/reviews/my-product-review"
)

# Option 2: Use local .docx file
converter = ReviewToMarkdownConverter(
    docx_path="~/Downloads/My_Product_Review.docx",
    output_dir="content/reviews/my-product-review"
)

converter.convert(
    title="Product Name Review",
    author="John Tribbia, Renee Krusemark",
    tags=["running", "shoes"],
    categories=["reviews"]
)
```

## How to Prepare Your Google Doc

### 1. **Formatting**
- Use Google Docs' built-in **Heading 1**, **Heading 2**, **Heading 3** styles for section titles
- Bold text for emphasis (will be preserved)
- The converter detects heading styles automatically

### 2. **Images**
- Paste/insert images directly into your Google Doc
- They will be automatically extracted and saved as `image_1.jpg`, `image_2.jpg`, etc.
- **Important**: Images are linked in order they appear in the doc
- The first image becomes the banner image (`banner: "image_1.jpg"`)

### 3. **Sharing Permissions**
- Your Google Doc must be shared with **view** access (to anyone or specific users)
- The converter downloads the document via Google's export API
- No need to manually download — just copy/paste the URL

### 4. **Tables and Lists**
- Use standard Google Docs tables and lists
- The converter preserves the text content
- You may need to manually adjust markdown table syntax after conversion

### 5. **Special Content Sections**
- Sections like "Pros", "Cons", "Stats" should be clear headings in your doc
- Use Heading 2 or 3 styles for these

## Export from Google Docs

### Option 1: Direct URL (Recommended - No Export Needed!)
1. Open your Google Doc
2. Copy the URL from your browser: `https://docs.google.com/document/d/ABC123/edit`
3. Run the converter and paste this URL when prompted
4. The converter automatically downloads and processes it

### Option 2: Manual Export
1. In Google Docs, click **File** → **Download** → **Microsoft Word (.docx)**
2. Save the file to your computer (e.g., `~/Downloads/My_Review.docx`)
3. Run the converter and provide the file path when prompted

## What Gets Created

The converter creates a directory structure:

```
content/reviews/my-product-review/
├── index.md              # Your review content
├── image_1.jpg           # First image (becomes banner)
├── image_2.jpg           # Second image
└── image_N.jpg           # Nth image (extracted from doc)
```

## Front Matter

The converter automatically creates proper YAML front matter:

```yaml
---
title: "Product Name Review"
date: 2025-12-31
banner: "image_1.jpg"
tags: ["running", "shoes"]
categories: ["reviews"]
description: ""
draft: false
---
```

## Manual Adjustments After Conversion

After conversion, you'll want to:

1. **Add pricing information** to the title section (e.g., "Product Name ($199)")
2. **Verify image placement** - sometimes images need context labels
3. **Check heading hierarchy** - ensure Heading 1, 2, 3 structure is correct
4. **Add links** - the converter preserves link text but you may need to adjust URLs
5. **Format special sections** - like author attributions for multi-reviewer content

## Example Conversion

### Input Google Doc Structure
```
Heading 1: Nike Pegasus Trail 4 GTX Review

Paragraph text...

Heading 2: Pros
- Lightweight
- Great traction

Heading 2: Cons
- Narrow toe box

[Image inserted]

Heading 3: First Impressions
Text content...
```

### Output `index.md`
```markdown
---
title: "Nike Pegasus Trail 4 GTX Review"
date: 2025-12-31
banner: "image_1.jpg"
tags: ["running", "shoes"]
categories: ["reviews"]
description: ""
draft: false
---
<!--more-->

*Article by John Tribbia*

...

## Nike Pegasus Trail 4 GTX Review

Paragraph text...

## Pros
- Lightweight
- Great traction

## Cons
- Narrow toe box

![image_1.jpg](image_1.jpg)

### First Impressions
Text content...
```

## Troubleshooting

### "File not found" error
- Make sure you exported as `.docx` (not `.doc` or `.pdf`)
- Use the full path: `~/Downloads/my_doc.docx`
- Check that the file exists in your file system

### Images not extracted
- Ensure images are inserted directly in the Google Doc (not linked)
- Some special image types may not be supported
- Check the console output for which images were extracted

### Heading detection issues
- Use Google Docs' built-in heading styles (not just bold text)
- Format → Paragraph styles → Heading 1/2/3

### Formatting lost after conversion
- The converter focuses on structure, not detailed formatting
- Complex formatting (colors, special fonts) may need manual adjustment
- Use Markdown syntax for emphasis: `**bold**`, `*italic*`, etc.

## Advanced: Batch Converting Multiple Reviews

```python
import glob
from google_doc_converter import ReviewToMarkdownConverter

docs = glob.glob("~/Downloads/Reviews/*.docx")

for docx_file in docs:
    converter = ReviewToMarkdownConverter(docx_file)
    # Customize title/author extraction as needed
    converter.convert(
        title=Path(docx_file).stem,
        author="John Tribbia"
    )
```

## Questions?

Refer to the example files in `content/reviews/` for the expected format, or check the script comments in `google_doc_converter.py`.
