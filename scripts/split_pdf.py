#!/usr/bin/env python3
"""Split a PDF into single-page PDFs based on page selections.

Usage:
    python split_pdf.py <input.pdf> <pages>

Pages syntax:
    3          → page 3
    1,3,5      → pages 1, 3, and 5
    1-5        → pages 1 through 5
    1-3,5,7-9  → pages 1,2,3,5,7,8,9

Each selected page is saved as a separate single-page PDF.
"""

import sys
import os
import subprocess
from pathlib import Path


def parse_pagespec(spec: str) -> list[int]:
    """Parse a page specification string into a sorted list of 1-based page numbers."""
    pages = []
    for part in spec.split(","):
        part = part.strip()
        if "-" in part:
            start, end = part.split("-", 1)
            pages.extend(range(int(start), int(end) + 1))
        else:
            pages.append(int(part))
    return sorted(set(pages))


def get_pdf_page_count(path: Path) -> int:
    """Return the number of pages in a PDF using qpdf."""
    result = subprocess.run(
        ["qpdf", "--show-npages", str(path)],
        capture_output=True,
        text=True,
    )
    if result.returncode not in (0, 3):  # 3 = warnings only
        raise RuntimeError(f"qpdf failed: {result.stderr.strip()}")
    return int(result.stdout.strip())


def extract_page(input_path: Path, page: int, output_path: Path):
    """Extract a single page from a PDF using qpdf."""
    result = subprocess.run(
        [
            "qpdf",
            str(input_path),
            "--pages",
            ".",
            str(page),
            "--",
            str(output_path),
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode not in (0, 3):  # 3 = warnings only
        raise RuntimeError(f"qpdf failed: {result.stderr.strip()}")


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <input.pdf> <pages>")
        print("Example: {} document.pdf 1-5,7,10-12".format(sys.argv[0]))
        sys.exit(1)

    input_path = Path(sys.argv[1])
    pagespec = sys.argv[2]

    if not input_path.exists():
        print(f"Error: File not found: {input_path}")
        sys.exit(1)

    try:
        pages = parse_pagespec(pagespec)
    except ValueError as e:
        print(f"Error parsing page spec: {e}")
        sys.exit(1)

    try:
        total_pages = get_pdf_page_count(input_path)
    except Exception as e:
        print(f"Error reading PDF: {e}")
        sys.exit(1)

    invalid = [p for p in pages if p < 1 or p > total_pages]
    if invalid:
        print(f"Error: Invalid page numbers (PDF has {total_pages} pages): {invalid}")
        sys.exit(1)

    stem = input_path.stem
    output_dir = input_path.parent

    for p in pages:
        output_path = output_dir / f"{stem}_page_{p}.pdf"
        try:
            extract_page(input_path, p, output_path)
            print(f"Written: {output_path}")
        except Exception as e:
            print(f"Error extracting page {p}: {e}")
            sys.exit(1)


if __name__ == "__main__":
    main()
