#!/bin/bash
# Demo of --no-recursive flag

echo "====================================="
echo "Recursive vs Non-Recursive Demo"
echo "====================================="

cd /home/claude
mkdir -p recursive_demo

# Create directory structure with comics at different levels
mkdir -p recursive_demo/root_level
mkdir -p recursive_demo/root_level/subfolder1
mkdir -p recursive_demo/root_level/subfolder2
mkdir -p recursive_demo/root_level/subfolder1/deep_folder

# Create comics at root level
for i in 1 2; do
    mkdir -p recursive_demo/temp_root$i
    cat > recursive_demo/temp_root$i/ComicInfo.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Root Level Comic $i</Title>
</ComicInfo>
EOF
    echo "page" > recursive_demo/temp_root$i/page.jpg
    cd recursive_demo/temp_root$i && zip -q ../root_level/root_comic_$i.cbz * && cd ../..
    rm -rf recursive_demo/temp_root$i
done

# Create comics in subfolder1
for i in 1 2; do
    mkdir -p recursive_demo/temp_sub1_$i
    cat > recursive_demo/temp_sub1_$i/ComicInfo.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Subfolder1 Comic $i</Title>
</ComicInfo>
EOF
    echo "page" > recursive_demo/temp_sub1_$i/page.jpg
    cd recursive_demo/temp_sub1_$i && zip -q ../root_level/subfolder1/sub1_comic_$i.cbz * && cd ../..
    rm -rf recursive_demo/temp_sub1_$i
done

# Create comics in subfolder2
for i in 1; do
    mkdir -p recursive_demo/temp_sub2_$i
    cat > recursive_demo/temp_sub2_$i/ComicInfo.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Subfolder2 Comic $i</Title>
</ComicInfo>
EOF
    echo "page" > recursive_demo/temp_sub2_$i/page.jpg
    cd recursive_demo/temp_sub2_$i && zip -q ../root_level/subfolder2/sub2_comic_$i.cbz * && cd ../..
    rm -rf recursive_demo/temp_sub2_$i
done

# Create comic in deep folder
mkdir -p recursive_demo/temp_deep
cat > recursive_demo/temp_deep/ComicInfo.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Deep Folder Comic</Title>
</ComicInfo>
EOF
echo "page" > recursive_demo/temp_deep/page.jpg
cd recursive_demo/temp_deep && zip -q ../root_level/subfolder1/deep_folder/deep_comic.cbz * && cd ../..
rm -rf recursive_demo/temp_deep

echo
echo "Created directory structure:"
echo "recursive_demo/root_level/"
echo "  ├── root_comic_1.cbz"
echo "  ├── root_comic_2.cbz"
echo "  ├── subfolder1/"
echo "  │   ├── sub1_comic_1.cbz"
echo "  │   ├── sub1_comic_2.cbz"
echo "  │   └── deep_folder/"
echo "  │       └── deep_comic.cbz"
echo "  └── subfolder2/"
echo "      └── sub2_comic_1.cbz"
echo
echo "Total: 6 comics across multiple directory levels"
echo

echo "====================================="
echo "TEST 1: Recursive mode (default)"
echo "====================================="
echo "Command: ./comic_info_modifier.py recursive_demo/root_level --attribute Publisher=\"Test\" -v"
echo

./comic_info_modifier.py recursive_demo/root_level --attribute Publisher="Test" -v 2>&1 | grep -E "(Found|Processing)" | head -20

echo
echo "====================================="
echo "TEST 2: Non-recursive mode"
echo "====================================="
echo "Command: ./comic_info_modifier.py recursive_demo/root_level --attribute Volume=1 --no-recursive -v"
echo

./comic_info_modifier.py recursive_demo/root_level --attribute Volume=1 --no-recursive -v 2>&1 | grep -E "(Found|Processing)" | head -20

echo
echo "====================================="
echo "Comparison:"
echo "====================================="
echo

# Get counts
recursive_count=$(./comic_info_modifier.py recursive_demo/root_level --attribute Format="Digital" 2>&1 | grep "Successfully processed:" | awk '{print $3}')
nonrecursive_count=$(./comic_info_modifier.py recursive_demo/root_level --attribute Format="Comic" --no-recursive 2>&1 | grep "Successfully processed:" | awk '{print $3}')

echo "Recursive mode (default):"
echo "  - Processes ALL 6 comics (including subdirectories)"
echo "  - Found: $recursive_count files"
echo
echo "Non-recursive mode (--no-recursive):"
echo "  - Processes ONLY 2 comics in root_level directory"
echo "  - Found: $nonrecursive_count files"
echo "  - Ignores: subfolder1/ and subfolder2/"
echo

echo "====================================="
echo "Use Cases:"
echo "====================================="
echo
echo "✓ Recursive (default):"
echo "  - Process entire collection"
echo "  - Organize large libraries"
echo "  - Bulk operations on all comics"
echo
echo "✓ Non-recursive (--no-recursive):"
echo "  - Process only current directory"
echo "  - Organize specific folder"
echo "  - Avoid touching subdirectories"
echo "  - Selective processing"
echo

rm -rf recursive_demo

echo "====================================="
echo "Demo complete!"
echo "====================================="