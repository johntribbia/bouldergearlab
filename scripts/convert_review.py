#!/usr/bin/env python3
"""
Interactive converter for transforming Google Docs (DOCX) to Boulder Gear Lab reviews.

Usage:
    python3 convert_review.py
    
    Then follow the prompts to select a document and configure the review.
"""

import os
import sys
from pathlib import Path
from google_doc_converter import ReviewToMarkdownConverter


def get_valid_input(prompt):
    """Get either a file path or Google Docs URL from user."""
    while True:
        user_input = input(prompt).strip()
        
        # Check if it's a Google Docs URL
        if "docs.google.com" in user_input:
            if "/document/d/" in user_input:
                return user_input
            else:
                print("❌ Invalid Google Docs URL format")
                print("   Use: https://docs.google.com/document/d/DOC_ID/edit")
                print()
                continue
        
        # Otherwise treat as file path
        path = Path(user_input).expanduser()
        
        if path.exists() and path.suffix.lower() == '.docx':
            return str(path)
        elif not path.exists():
            print(f"❌ File not found: {path}")
        else:
            print(f"❌ Not a .docx file: {user_input}")
        
        print("Please try again with a file path or Google Docs URL\n")


def get_string_input(prompt, default=""):
    """Get string input from user with optional default."""
    full_prompt = f"{prompt}" + (f" [{default}]: " if default else ": ")
    result = input(full_prompt).strip()
    return result if result else default


def get_list_input(prompt, default=None):
    """Get comma-separated list from user."""
    if default is None:
        default = []
    
    default_str = ", ".join(default) if default else ""
    full_prompt = f"{prompt}" + (f" [{default_str}]: " if default_str else ": ")
    
    result = input(full_prompt).strip()
    if not result:
        return default
    
    return [item.strip() for item in result.split(",")]


def main():
    """Interactive guide for converting reviews."""
    
    print("\n" + "=" * 70)
    print("  Google Docs → Boulder Gear Lab Review Converter")
    print("=" * 70 + "\n")
    
    # Step 1: Get document source
    print("Step 1: Select your Google Doc source")
    print("  Option A: Google Docs URL (paste directly)")
    print("  Option B: Local .docx file (~/Downloads/my_doc.docx)\n")
    
    doc_source = get_valid_input("Google Docs URL or .docx path: ")
    
    # Step 2: Get review metadata
    print("Step 2: Review Information")
    
    title = get_string_input("Review title (e.g., 'Hoka Speedgoat 5 GTX Review')")
    print()
    
    author = get_string_input(
        "Author(s)", 
        "John Tribbia"
    )
    print()
    
    tags = get_list_input(
        "Tags (comma-separated)",
        ["running", "shoes"]
    )
    print()
    
    categories = get_list_input(
        "Categories (comma-separated)",
        ["reviews"]
    )
    print()
    
    # Step 3: Determine output directory
    print("Step 3: Output Location")
    
    # Generate slug from title
    import re
    slug = title.lower()
    slug = re.sub(r'[^\w\s-]', '', slug)
    slug = re.sub(r'[-\s]+', '-', slug)
    slug = slug.strip('-')
    
    workspace_root = Path(__file__).parent.parent  # Get Boulder Gear Lab root
    output_dir = workspace_root / "content" / "reviews" / slug
    
    print(f"  Suggested: {output_dir}")
    custom_output = get_string_input("Override output path (leave empty to use suggested)", "")
    
    if custom_output:
        output_dir = Path(custom_output).expanduser()
    
    print(f"✓ Output directory: {output_dir}\n")
    
    # Step 4: Convert
    print("Step 4: Converting...")
    print("-" * 70)
    
    try:
        converter = ReviewToMarkdownConverter(doc_source, str(output_dir))
        converter.convert(
            title=title,
            author=author,
            tags=tags,
            categories=categories
        )
        
        print("\n✨ Next Steps:")
        print(f"   1. Review the converted files in: {output_dir}")
        print(f"   2. Edit {output_dir}/index.md to:")
        print(f"      - Add price to the title section")
        print(f"      - Adjust any formatting as needed")
        print(f"      - Add missing links or formatting")
        print(f"   3. Run 'hugo build' to verify the review renders correctly")
        print()
        
    except Exception as e:
        print(f"\n❌ Conversion failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
