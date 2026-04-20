#!/usr/bin/env python3
"""
Search Hyprland documentation and configuration variables.

This script searches local markdown documentation files that were downloaded
from the Hyprland wiki using jina.ai markdown converter.
"""

import sys
import os
from typing import List, Dict
from pathlib import Path

# Get script directory and docs location
SCRIPT_DIR = Path(__file__).parent
DOCS_DIR = SCRIPT_DIR.parent / "references" / "docs"

# Local documentation files
DOC_FILES = {
    "variables": "variables.md",
    "keywords": "keywords.md",
    "binds": "binds.md",
    "animations": "animations.md",
    "dispatchers": "dispatchers.md",
    "window_rules": "window-rules.md",
    "monitors": "monitors.md",
}

# Original URLs for reference
WIKI_URLS = {
    "variables": "https://wiki.hypr.land/Configuring/Variables/",
    "keywords": "https://wiki.hypr.land/Configuring/Keywords/",
    "binds": "https://wiki.hypr.land/Configuring/Binds/",
    "animations": "https://wiki.hypr.land/Configuring/Animations/",
    "dispatchers": "https://wiki.hypr.land/Configuring/Dispatchers/",
    "window_rules": "https://wiki.hypr.land/Configuring/Window-Rules/",
    "monitors": "https://wiki.hypr.land/Configuring/Monitors/",
}


def load_doc_content(filename: str) -> str:
    """Load content from a local markdown file."""
    doc_path = DOCS_DIR / filename
    try:
        with open(doc_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        return f"Error: Documentation file not found: {doc_path}"
    except Exception as e:
        return f"Error reading {doc_path}: {e}"


def search_in_content(content: str, query: str, section_name: str) -> List[str]:
    """Search for a query in the content and return matching sections."""
    results = []
    lines = content.split('\n')

    # Search case-insensitively
    query_lower = query.lower()

    for i, line in enumerate(lines):
        if query_lower in line.lower():
            # Get context: 2 lines before and 10 lines after for better markdown context
            start = max(0, i - 2)
            end = min(i + 10, len(lines))
            context_lines = lines[start:end]
            result = f"\n[{section_name}] Match found:\n" + '\n'.join(context_lines)
            results.append(result)

    return results


def search_all_docs(query: str) -> Dict[str, List[str]]:
    """Search all Hyprland documentation for the query."""
    all_results = {}

    for section, filename in DOC_FILES.items():
        print(f"Searching {section}...", file=sys.stderr)
        content = load_doc_content(filename)

        if content.startswith("Error"):
            all_results[section] = [content]
        else:
            matches = search_in_content(content, query, section)
            if matches:
                all_results[section] = matches

    return all_results


def list_sections():
    """List all available documentation sections."""
    print("Available Hyprland documentation sections:")
    print(f"\nLocal docs directory: {DOCS_DIR}")
    print("\nSections:")
    for section, filename in DOC_FILES.items():
        url = WIKI_URLS.get(section, "")
        doc_path = DOCS_DIR / filename
        exists = "✓" if doc_path.exists() else "✗"
        print(f"  {exists} {section}: {filename}")
        if url:
            print(f"      Source: {url}")


def main():
    if len(sys.argv) < 2:
        print("Usage: search_hyprland_docs.py <search_query>")
        print("       search_hyprland_docs.py --list  (list all documentation sections)")
        print("\nExample: search_hyprland_docs.py 'general:gaps_in'")
        print("Example: search_hyprland_docs.py 'border_size'")
        print("Example: search_hyprland_docs.py 'slidevert'")
        sys.exit(1)

    if sys.argv[1] == "--list":
        list_sections()
        sys.exit(0)

    query = sys.argv[1]
    print(f"Searching Hyprland documentation for: '{query}'", file=sys.stderr)
    print("=" * 60, file=sys.stderr)

    results = search_all_docs(query)

    if not results:
        print(f"\nNo results found for '{query}'")
        print("\nTip: Try searching for:")
        print("  - Config variable names (e.g., 'gaps_in', 'border_size')")
        print("  - Keywords (e.g., 'monitor', 'bind', 'exec')")
        print("  - Feature names (e.g., 'animations', 'blur', 'slidevert')")
        sys.exit(1)

    print(f"\nFound {len(results)} section(s) with matches:\n")

    for section, matches in results.items():
        print(f"\n{'='*60}")
        print(f"SECTION: {section.upper()}")
        print(f"URL: {WIKI_URLS[section]}")
        print('='*60)
        for match in matches:
            print(match)
            print('-' * 40)

    print(f"\n\nSearch complete. Found matches in {len(results)} section(s).")


if __name__ == "__main__":
    main()
