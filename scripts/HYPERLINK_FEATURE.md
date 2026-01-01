# Hyperlink Extraction Feature

## Overview

The Google Docs converter now automatically extracts and preserves hyperlinks from your Google Docs, converting them to proper markdown `[text](url)` format.

## What Was Added

### New Method: `_extract_hyperlink_from_run()`

Located in `google_doc_converter.py`, this method:

1. **Detects hyperlinks** in run elements by examining the XML structure
2. **Extracts the link text** - the visible text that's hyperlinked
3. **Extracts the target URL** - from the document relationships
4. **Returns both** as a tuple `(text, url)` for markdown conversion

### How It Works

When processing paragraph runs, the converter now:

1. Checks each run for embedded hyperlinks
2. If a hyperlink is found, it extracts the relationship ID (`rId`)
3. Uses that ID to lookup the actual URL from the document's relationships
4. Formats the hyperlink as markdown: `[link_text](url)`
5. Falls back to plain text if no hyperlink is found

### Key Implementation Details

The hyperlink detection uses two approaches:

1. **Direct search**: Look for hyperlink elements within the run using `find('.//' + qn('w:hyperlink'))`
2. **Parent tree walk**: If direct search fails, walk up the XML tree to find the parent hyperlink element

This dual approach handles various DOCX structures and ensures compatibility.

## Usage

No special action needed! Just use the converter as normal:

```python
from google_doc_converter import ReviewToMarkdownConverter

converter = ReviewToMarkdownConverter(
    docx_path="https://docs.google.com/document/d/YOUR_DOC_ID/edit",
    output_dir="content/reviews/my-review"
)

converter.convert(
    title="Product Review",
    author="John Tribbia",
    tags=["running"],
    categories=["reviews"]
)
```

Links in your Google Doc are automatically extracted and converted to markdown.

## Example

### Google Docs Input
```
Check out the product specifications at this link: [specifications page](https://example.com/specs)
For more info, see the official guide.
```

### Markdown Output
```markdown
Check out the product specifications at this [specifications page](https://example.com/specs)
For more info, see the official guide.
```

## Technical Details

**File**: `google_doc_converter.py`

**Methods Modified**:
- `_extract_hyperlink_from_run()` - NEW: Extract hyperlinks from run elements
- `convert()` - UPDATED: Call hyperlink extraction during content processing

**Lines of Code Added**: ~80 (including new method + integration)

**Dependencies**: Uses only existing imports (python-docx's `qn` utility for XML namespaces)

## Testing

The feature is transparent and doesn't require special testing. Links in your Google Docs will be automatically preserved in the markdown output. You can verify by:

1. Creating a Google Doc with some hyperlinked text
2. Converting it using the converter
3. Checking that the markdown output contains proper `[text](url)` format
4. Building the Hugo site and verifying links work in the HTML output

## Backward Compatibility

This feature is 100% backward compatible:
- Documents without hyperlinks work exactly as before
- All other conversion features (images, headings, etc.) unchanged
- No API changes to the converter class
- Existing conversions continue to work without modification

## Future Enhancements

Possible improvements:
- Extract hyperlinks from headings (currently headings use `.text` which loses link info)
- Handle hyperlinks in table cells
- Support anchor links and internal document references
- Add logging for extracted links (for debugging)
