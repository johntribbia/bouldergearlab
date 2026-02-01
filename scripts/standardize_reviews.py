#!/usr/bin/env python3
"""
Standardize formatting across all review markdown files
"""
import os
import re
from pathlib import Path

def standardize_review(file_path):
    """Standardize formatting in a single review file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    changes = []
    
    # 1. Remove empty H3 headings (### followed by newline)
    new_content = re.sub(r'\n###\s*\n', '\n', content)
    if new_content != content:
        changes.append("Removed empty H3 headings")
        content = new_content
    
    # 2. Standardize list formatting (convert asterisks to dashes)
    lines = content.split('\n')
    new_lines = []
    in_front_matter = False
    front_matter_dashes = 0
    
    for line in lines:
        # Track front matter to avoid changing it
        if line.strip() == '---':
            front_matter_dashes += 1
            if front_matter_dashes <= 2:
                in_front_matter = not in_front_matter
        
        # Only convert list items outside front matter
        if not in_front_matter and re.match(r'^\s*\*\s+', line):
            # Convert asterisk lists to dash lists
            new_line = re.sub(r'^(\s*)\*\s+', r'\1- ', line)
            new_lines.append(new_line)
            if '- ' in new_line and '* ' in line:
                if "list formatting" not in str(changes):
                    changes.append("Standardized list formatting to dashes")
        else:
            new_lines.append(line)
    
    content = '\n'.join(new_lines)
    
    # 3. Ensure consistent spacing after front matter
    content = re.sub(r'(---\n)<!--more-->\n+', r'\1<!--more-->\n\n', content)
    
    # Write back if changes were made
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return changes
    return []

def main():
    """Process all review files"""
    reviews_dir = Path('/Users/johntribbia/bouldergearlab/content/reviews')
    
    total_files = 0
    total_changes = 0
    
    for review_dir in reviews_dir.iterdir():
        if review_dir.is_dir():
            index_file = review_dir / 'index.md'
            if index_file.exists():
                total_files += 1
                changes = standardize_review(index_file)
                if changes:
                    total_changes += 1
                    print(f"✓ {review_dir.name}:")
                    for change in changes:
                        print(f"  - {change}")
    
    print(f"\n📊 Summary: Processed {total_files} files, modified {total_changes} files")

if __name__ == '__main__':
    main()
