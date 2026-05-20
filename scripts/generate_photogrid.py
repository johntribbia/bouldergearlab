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


def find_data_project_images(data_dir, figures_only=True):
    """
    Find chart/figure images from data project folders.
    
    Args:
        data_dir: Path to data-projects directory
        figures_only: If True, only include images inside 'figures/' subdirectories
        
    Returns:
        list: List of image file paths
    """
    images = []
    
    for root, dirs, files in os.walk(data_dir):
        # Skip if figures_only and this path isn't inside a figures/ directory
        if figures_only and 'figures' not in Path(root).parts:
            continue
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
    parser.add_argument(
        '--data-dir', '-d',
        default='content/data-projects',
        help='Path to data-projects directory (default: content/data-projects)'
    )
    parser.add_argument(
        '--data-ratio',
        type=float,
        default=0.25,
        help='Fraction of grid cells to fill with data project charts (default: 0.25)'
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
    data_dir = Path(args.data_dir)
    output_path = Path(args.output)
    
    if not reviews_dir.exists():
        print(f"❌ Reviews directory not found: {reviews_dir}")
        sys.exit(1)
    
    # Create output directory if needed
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    print("\n" + "=" * 60)
    print("  Boulder Gear Lab - Photo Grid Generator")
    print("=" * 60)
    
    # Find review images
    print(f"\n🔍 Searching for images in {reviews_dir}...")
    review_images = find_review_images(str(reviews_dir))
    
    if not review_images:
        print(f"❌ No images found in {reviews_dir}")
        sys.exit(1)
    
    print(f"   Found {len(review_images)} review images")
    
    # Find data project chart images
    data_images = []
    if data_dir.exists() and args.data_ratio > 0:
        print(f"\n🔍 Searching for charts in {data_dir}...")
        data_images = find_data_project_images(str(data_dir))
        print(f"   Found {len(data_images)} data project charts")
    
    # Mix pools: data_ratio of slots go to data charts, rest to reviews
    total_images = cols * rows
    n_data = min(round(total_images * args.data_ratio), len(data_images))
    n_review = total_images - n_data
    
    selected_data = random.sample(data_images, n_data) if n_data > 0 else []
    selected_review = random.sample(review_images, min(n_review, len(review_images)))
    
    # Interleave data charts evenly through the grid
    combined = selected_review[:]
    if selected_data:
        step = max(1, len(combined) // len(selected_data))
        for i, chart in enumerate(selected_data):
            combined.insert(min((i + 1) * step, len(combined)), chart)
    
    print(f"\n   Grid mix: {len(selected_review)} gear photos + {n_data} data charts")
    
    # Create grid
    print(f"\n📸 Creating {cols}x{rows} photogrid ({cols*rows} images)...\n")
    create_photogrid(combined, str(output_path), (cols, rows), args.size)

if __name__ == '__main__':
    main()
