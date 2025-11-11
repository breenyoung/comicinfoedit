#!/usr/bin/env python3
"""
Comic Book Archive ComicInfo.xml Modifier

Modifies ComicInfo.xml files within CBZ (zip) and CBR (rar) archives.
Supports adding, updating, or removing XML attributes with automatic backup/restore.
"""

import os
import sys
import argparse
import tempfile
import shutil
import zipfile
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List, Tuple, Optional


class ComicInfoModifier:
    def __init__(self, attributes: List[Tuple[str, str]], verbose: bool = False, update_only: bool = False):
        """
        Initialize the modifier.

        Args:
            attributes: List of (attribute_name, value) tuples to modify
            verbose: Enable verbose logging
            update_only: Only update existing attributes, don't create new ones
        """
        self.attributes = attributes
        self.verbose = verbose
        self.update_only = update_only
        self.backup_dir = None

    def log(self, message: str, level: str = 'INFO'):
        """Print log messages."""
        if self.verbose or level == 'ERROR':
            prefix = f"[{level}]"
            print(f"{prefix} {message}")

    def get_comic_files(self, paths: List[str]) -> List[Path]:
        """
        Get all CBZ/CBR files from provided paths.

        Args:
            paths: List of file or directory paths

        Returns:
            List of Path objects for comic files
        """
        comic_files = []

        for path_str in paths:
            path = Path(path_str)

            if not path.exists():
                self.log(f"Path does not exist: {path}", 'ERROR')
                continue

            if path.is_file():
                if path.suffix.lower() in ['.cbz', '.cbr']:
                    comic_files.append(path)
                else:
                    self.log(f"Skipping non-comic file: {path}", 'WARNING')
            elif path.is_dir():
                # Recursively find all CBZ/CBR files
                for ext in ['*.cbz', '*.cbr', '*.CBZ', '*.CBR']:
                    comic_files.extend(path.rglob(ext))

        return sorted(set(comic_files))

    def create_backup(self, file_path: Path) -> Path:
        """
        Create a backup of the original file.

        Args:
            file_path: Path to file to backup

        Returns:
            Path to backup file
        """
        if self.backup_dir is None:
            self.backup_dir = Path(tempfile.mkdtemp(prefix='comic_backup_'))
            self.log(f"Created backup directory: {self.backup_dir}")

        backup_path = self.backup_dir / file_path.name
        shutil.copy2(file_path, backup_path)
        self.log(f"Backed up: {file_path.name}")
        return backup_path

    def restore_backup(self, backup_path: Path, original_path: Path):
        """Restore a file from backup."""
        shutil.copy2(backup_path, original_path)
        self.log(f"Restored from backup: {original_path.name}")

    def extract_cbz(self, cbz_path: Path, extract_dir: Path) -> bool:
        """Extract CBZ file."""
        try:
            with zipfile.ZipFile(cbz_path, 'r') as zip_ref:
                zip_ref.extractall(extract_dir)
            self.log(f"Extracted CBZ: {cbz_path.name}")
            return True
        except Exception as e:
            self.log(f"Failed to extract CBZ {cbz_path.name}: {e}", 'ERROR')
            return False

    def extract_cbr(self, cbr_path: Path, extract_dir: Path) -> bool:
        """Extract CBR file using unrar."""
        try:
            result = subprocess.run(
                ['unrar', 'x', '-o+', str(cbr_path), str(extract_dir)],
                capture_output=True,
                text=True,
                check=False
            )

            if result.returncode != 0:
                self.log(f"unrar error: {result.stderr}", 'ERROR')
                return False

            self.log(f"Extracted CBR: {cbr_path.name}")
            return True
        except FileNotFoundError:
            self.log("unrar command not found. Please install unrar.", 'ERROR')
            return False
        except Exception as e:
            self.log(f"Failed to extract CBR {cbr_path.name}: {e}", 'ERROR')
            return False

    def create_cbz(self, source_dir: Path, output_path: Path) -> bool:
        """Create CBZ file from directory."""
        try:
            with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zip_ref:
                for root, dirs, files in os.walk(source_dir):
                    for file in files:
                        file_path = Path(root) / file
                        arcname = file_path.relative_to(source_dir)
                        zip_ref.write(file_path, arcname)

            self.log(f"Created CBZ: {output_path.name}")
            return True
        except Exception as e:
            self.log(f"Failed to create CBZ {output_path.name}: {e}", 'ERROR')
            return False

    def create_cbr(self, source_dir: Path, output_path: Path) -> bool:
        """Create CBR file from directory using rar."""
        try:
            # Change to source directory for rar command
            original_cwd = os.getcwd()
            os.chdir(source_dir)

            # rar a -r -ep1 output.cbr *
            result = subprocess.run(
                ['rar', 'a', '-r', '-ep1', str(output_path), '*'],
                capture_output=True,
                text=True,
                check=False
            )

            os.chdir(original_cwd)

            if result.returncode != 0:
                self.log(f"rar error: {result.stderr}", 'ERROR')
                return False

            self.log(f"Created CBR: {output_path.name}")
            return True
        except FileNotFoundError:
            self.log("rar command not found. Please install rar.", 'ERROR')
            return False
        except Exception as e:
            self.log(f"Failed to create CBR {output_path.name}: {e}", 'ERROR')
            return False
        finally:
            if os.getcwd() != original_cwd:
                os.chdir(original_cwd)

    def modify_comic_info(self, xml_path: Path) -> Tuple[bool, bool]:
        """
        Modify ComicInfo.xml file.

        Returns:
            Tuple of (success, modified)
        """
        try:
            tree = ET.parse(xml_path)
            root = tree.getroot()

            overall_modified = False

            # Process each attribute
            for attribute, value in self.attributes:
                remove_attribute = value.lower() == 'null'
                element = root.find(attribute)
                modified = False

                if remove_attribute:
                    if element is not None:
                        root.remove(element)
                        modified = True
                        self.log(f"Removed attribute: {attribute}")
                    else:
                        self.log(f"Attribute {attribute} not found (nothing to remove)")
                else:
                    if element is not None:
                        old_value = element.text
                        if old_value != value:
                            element.text = value
                            modified = True
                            self.log(f"Updated {attribute}: '{old_value}' -> '{value}'")
                        else:
                            self.log(f"Attribute {attribute} already has value '{value}'")
                    else:
                        # Attribute doesn't exist
                        if self.update_only:
                            self.log(f"Attribute {attribute} not found (update-only mode, skipping)")
                        else:
                            new_element = ET.SubElement(root, attribute)
                            new_element.text = value
                            modified = True
                            self.log(f"Added attribute {attribute} = '{value}'")

                if modified:
                    overall_modified = True

            if overall_modified:
                # Preserve XML declaration and formatting
                tree.write(xml_path, encoding='utf-8', xml_declaration=True)

            return True, overall_modified
        except ET.ParseError as e:
            self.log(f"XML parsing error: {e}", 'ERROR')
            return False, False
        except Exception as e:
            self.log(f"Error modifying ComicInfo.xml: {e}", 'ERROR')
            return False, False

    def process_file(self, comic_path: Path) -> bool:
        """
        Process a single comic file.

        Returns:
            True if successful, False otherwise
        """
        self.log(f"\nProcessing: {comic_path}")

        # Create backup
        backup_path = self.create_backup(comic_path)

        # Create temporary directory for extraction
        with tempfile.TemporaryDirectory(prefix='comic_extract_') as temp_dir:
            temp_path = Path(temp_dir)

            # Extract based on file type
            is_cbz = comic_path.suffix.lower() == '.cbz'

            if is_cbz:
                if not self.extract_cbz(comic_path, temp_path):
                    self.restore_backup(backup_path, comic_path)
                    return False
            else:  # CBR
                if not self.extract_cbr(comic_path, temp_path):
                    self.restore_backup(backup_path, comic_path)
                    return False

            # Find ComicInfo.xml
            comic_info_path = temp_path / 'ComicInfo.xml'

            if not comic_info_path.exists():
                self.log(f"ComicInfo.xml not found in {comic_path.name}", 'ERROR')
                return False

            # Modify ComicInfo.xml
            success, modified = self.modify_comic_info(comic_info_path)

            if not success:
                self.restore_backup(backup_path, comic_path)
                return False

            if not modified:
                self.log(f"No changes needed for {comic_path.name}")
                return True

            # Create temporary output file
            temp_output = Path(temp_dir) / f"temp_{comic_path.name}"

            # Recreate archive
            if is_cbz:
                if not self.create_cbz(temp_path, temp_output):
                    self.restore_backup(backup_path, comic_path)
                    return False
            else:  # CBR
                if not self.create_cbr(temp_path, temp_output):
                    self.restore_backup(backup_path, comic_path)
                    return False

            # Replace original file
            try:
                shutil.copy2(temp_output, comic_path)
                self.log(f"Successfully updated: {comic_path.name}")
                return True
            except Exception as e:
                self.log(f"Failed to replace original file: {e}", 'ERROR')
                self.restore_backup(backup_path, comic_path)
                return False

    def cleanup(self):
        """Clean up backup directory."""
        if self.backup_dir and self.backup_dir.exists():
            shutil.rmtree(self.backup_dir)
            self.log(f"Cleaned up backup directory: {self.backup_dir}")


def main():
    parser = argparse.ArgumentParser(
        description='Modify ComicInfo.xml files within CBZ/CBR archives',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Set Series attribute to "Amazing Spider-Man" for all comics in directory
  %(prog)s /path/to/comics --attribute Series="Amazing Spider-Man"

  # Remove the Writer attribute from specific files
  %(prog)s file1.cbz file2.cbr --attribute Writer=null

  # Update Volume for all CBZ files in current directory
  %(prog)s . --attribute Volume=2 -v

  # Update multiple attributes at once
  %(prog)s comic.cbz --attribute Series="Spider-Man" Volume=1 Publisher="Marvel"

  # Mix updates and removals
  %(prog)s *.cbz --attribute Publisher="DC Comics" Writer=null Colorist=null

  # Only update Publisher if it already exists (don't create new attribute)
  %(prog)s /comics --attribute Publisher="Marvel" --update-only
        """
    )

    parser.add_argument(
        'paths',
        nargs='+',
        help='Comic file(s) or directory/directories to process'
    )

    parser.add_argument(
        '-a', '--attribute',
        required=True,
        nargs='+',
        help='XML attribute(s) to modify in key=value format (use value=null to remove). Can specify multiple.'
    )

    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose output'
    )

    parser.add_argument(
        '--update-only',
        action='store_true',
        help='Only update existing attributes, do not create new ones (ignored when removing)'
    )

    parser.add_argument(
        '--keep-backups',
        action='store_true',
        help='Keep backup files after processing (default: delete)'
    )

    args = parser.parse_args()

    # Parse attribute arguments
    attributes = []
    for attr_str in args.attribute:
        if '=' not in attr_str:
            print(f"Error: --attribute must be in key=value format: {attr_str}", file=sys.stderr)
            sys.exit(1)

        key, value = attr_str.split('=', 1)

        if not key:
            print(f"Error: Attribute key cannot be empty: {attr_str}", file=sys.stderr)
            sys.exit(1)

        attributes.append((key, value))

    if not attributes:
        print("Error: At least one attribute must be specified", file=sys.stderr)
        sys.exit(1)

    # Initialize modifier
    modifier = ComicInfoModifier(attributes, args.verbose, args.update_only)

    try:
        # Get all comic files
        comic_files = modifier.get_comic_files(args.paths)

        if not comic_files:
            print("No comic files found to process", file=sys.stderr)
            sys.exit(1)

        modifier.log(f"Found {len(comic_files)} comic file(s) to process")

        # Process each file
        success_count = 0
        fail_count = 0

        for comic_file in comic_files:
            if modifier.process_file(comic_file):
                success_count += 1
            else:
                fail_count += 1

        # Summary
        print(f"\n{'=' * 60}")
        print(f"Processing complete:")
        print(f"  Successfully processed: {success_count}")
        print(f"  Failed: {fail_count}")
        print(f"  Total: {len(comic_files)}")
        print(f"{'=' * 60}")

        # Cleanup
        if not args.keep_backups:
            modifier.cleanup()
        else:
            print(f"Backups saved in: {modifier.backup_dir}")

        sys.exit(0 if fail_count == 0 else 1)

    except KeyboardInterrupt:
        print("\n\nInterrupted by user", file=sys.stderr)
        modifier.cleanup()
        sys.exit(130)
    except Exception as e:
        print(f"\nUnexpected error: {e}", file=sys.stderr)
        modifier.cleanup()
        sys.exit(1)


if __name__ == '__main__':
    main()