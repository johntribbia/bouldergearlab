#!/usr/bin/env python3
"""
Photo Grid Generator for Boulder Gear Lab

Randomly selects images from review folders and creates a composite grid image.
Useful for creating dynamic hero/banner images for the homepage.

Usage:
    python3 generate_photogrid.py [--output path/to/output.jpg] [--size 1200] [--grid 3x3]
"""

import os
import sys
import random
import argparse
from pathlib import Path
from PIL import Image

def find_review_images(reviews_dir):
    """
    Find all images in review folders.
    
    Args:
        reviews_dir: Path to reviews directory
        
    Returns:
        list: List of image file paths
    """
    images = []
    
    for root, dirs, files in os.walk(reviews_dir):
        for file in files:
            if file.lower().endswith(('.jpg', '.jpeg', '.png', '.gif')):
                images.append(os.path.join(root, file))
    
    return images

def create_photogrid(images, output_path, grid_size=(3, 3), total_width=1200):
    """
    Create a composite image grid from random images.
    
    Args:
        images: List of image file paths
        output_path: Path where to save the grid image
        grid_size: Tuple (cols, rows) for grid layout
        total_width: Total width of output image in pixels
    """
    cols, rows = grid_size
    total_images = cols * rows
    
    if len(images) < total_images:
        print(f"⚠️  Found only {len(images)} images, need {total_images} for {cols}x{rows} grid")
        print("   Reducing grid size...")
        # Adjust grid to fit available images
        if len(images) >= 6:
            cols, rows = 2, 3
        elif len(images) >= 4:
            cols, rows = 2, 2
        else:
            cols, rows = 2, 1
        total_images = cols * rows
    
    # Randomly select images
    selected_images = random.sample(images, min(total_images, len(images)))
    
    # Calculate cell size
    cell_width = total_width // cols
    cell_height = cell_width  # Square cells
    
    # Create blank canvas
    grid = Image.new('RGB', (total_width, cell_height * rows), color=(240, 240, 240))
    
    # Paste images into grid
    for idx, img_path in enumerate(selected_images):
        try:
            # Open and resize image
            img = Image.open(img_path)
            
            # Convert to RGB if necessary (handles PNG with transparency, etc)
            if img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Resize to fit cell while maintaining aspect ratio
            img.thumbnail((cell_width, cell_height), Image.Resampling.LANCZOS)
            
            # Calculate position to center image in cell
            col = idx % cols
            row = idx // cols
            x = col * cell_width + (cell_width - img.width) // 2
            y = row * cell_height + (cell_height - img.height) // 2
            
            # Paste image
            grid.paste(img, (x, y))
            
            print(f"  ✓ {Path(img_path).parent.name}/{Path(img_path).name}")
            
        except Exception as e:
            print(f"  ✗ Failed to process {img_path}: {e}")
    
    # Save grid
    grid.save(output_path, 'JPEG', quality=85, optimize=True)
    file_size = os.path.getsize(output_path) / 1024 / 1024  # Convert to MB
    print(f"\n✅ Photogrid saved to {output_path}")
    print(f"   Size: {grid.width}x{grid.height}px, {file_size:.2f}MB")

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Generate a photogrid from random review images"
    )
    parser.add_argument(
        '--output', '-o',
        default='static/img/photogrid.jpg',
        help='Output path for photogrid (default: static/img/photogrid.jpg)'
    )
    parser.add_argument(
        '--size', '-s',
        type=int,
        default=1200,
        help='Total width of output image in pixels (default: 1200)'
    )
    parser.add_argument(
        '--grid', '-g',
        default='3x3',
        help='Grid layout as COLSxROWS (default: 3x3)'
    )
    parser.add_argument(
        '--reviews-dir', '-r',
        default='content/reviews',
        help='Path to reviews directory (default: content/reviews)'
    )
    
    args = parser.parse_args()
    
    # Parse grid size
    try:
        cols, rows = map(int, args.grid.split('x'))
    except ValueError:
        print(f"❌ Invalid grid format: {args.grid}. Use COLSxROWS (e.g., 3x3)")
        sys.exit(1)
    
    # Resolve paths
    reviews_dir = Path(args.reviews_dir)
    output_path = Path(args.output)
    
    if not reviews_dir.exists():
        print(f"❌ Reviews directory not found: {reviews_dir}")
        sys.exit(1)
    
    # Create output directory if needed
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    print("\n" + "=" * 60)
    print("  Boulder Gear Lab - Photo Grid Generator")
    print("=" * 60)
    
    # Find images
    print(f"\n🔍 Searching for images in {reviews_dir}...")
    images = find_review_images(str(reviews_dir))
    
    if not images:
        print(f"❌ No images found in {reviews_dir}")
        sys.exit(1)
    
    print(f"   Found {len(images)} images\n")
    
    # Create grid
    print(f"📸 Creating {cols}x{rows} photogrid ({cols*rows} images)...\n")
    create_photogrid(images, str(output_path), (cols, rows), args.size)

if __name__ == '__main__':
    main()
