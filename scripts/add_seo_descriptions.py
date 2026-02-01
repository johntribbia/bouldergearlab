#!/usr/bin/env python3
"""
Add SEO descriptions to review front matter
"""
import os
import re
from pathlib import Path

def extract_first_paragraph(content):
    """Extract first meaningful paragraph from content"""
    # Remove front matter
    parts = content.split('---', 2)
    if len(parts) >= 3:
        body = parts[2]
    else:
        body = content
    
    # Remove <!--more--> tag
    body = body.replace('<!--more-->', '')
    
    # Split into paragraphs
    paragraphs = [p.strip() for p in body.split('\n\n') if p.strip()]
    
    for para in paragraphs:
        # Skip headings, images, links, empty lines
        if para.startswith('#') or para.startswith('![') or para.startswith('<') or para.startswith('*Article by'):
            continue
        
        # Clean up markdown formatting
        clean = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', para)  # Remove links
        clean = re.sub(r'\*\*([^\*]+)\*\*', r'\1', clean)  # Remove bold
        clean = re.sub(r'\*([^\*]+)\*', r'\1', clean)  # Remove italic
        clean = re.sub(r'`([^`]+)`', r'\1', clean)  # Remove code
        clean = clean.replace('\n', ' ').strip()
        
        if clean and len(clean) > 50:
            # Truncate to ~150-160 characters for SEO
            if len(clean) > 160:
                clean = clean[:157] + '...'
            return clean
    
    return ""

def add_seo_description(file_path):
    """Add SEO description to a review file if missing"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if description is empty
    if 'description: ""' not in content and "description: ''" not in content:
        return False
    
    # Extract title for fallback
    title_match = re.search(r'title:\s*"([^"]+)"', content)
    title = title_match.group(1) if title_match else ""
    
    # Get first paragraph
    description = extract_first_paragraph(content)
    
    # Fallback to title-based description
    if not description and title:
        if "Review" in title:
            description = f"Comprehensive review of the {title.replace(' Review', '')} with testing insights and performance analysis."
        else:
            description = f"Detailed review and analysis of {title}."
    
    if description:
        # Replace empty description
        new_content = re.sub(
            r'description:\s*["\']["\']',
            f'description: "{description}"',
            content
        )
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    
    return False

def main():
    """Process all review files"""
    reviews_dir = Path('/Users/johntribbia/bouldergearlab/content/reviews')
    
    total_files = 0
    total_updated = 0
    
    for review_dir in reviews_dir.iterdir():
        if review_dir.is_dir():
            index_file = review_dir / 'index.md'
            if index_file.exists():
                total_files += 1
                if add_seo_description(index_file):
                    total_updated += 1
                    print(f"✓ Added description to {review_dir.name}")
    
    print(f"\n📊 Summary: Processed {total_files} files, updated {total_updated} descriptions")

if __name__ == '__main__':
    main()
