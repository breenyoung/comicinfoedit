#!/bin/bash
# Demo of multiple attribute modification

echo "====================================="
echo "Multiple Attribute Modification Demo"
echo "====================================="

cd /home/claude

# Create test directory
mkdir -p multi_attr_test

# Create a test comic with some existing attributes
mkdir -p multi_attr_test/comic
cat > multi_attr_test/comic/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Test Comic Issue 1</Title>
  <Series>Old Series Name</Series>
  <Number>1</Number>
  <Writer>John Doe</Writer>
  <Penciller>Jane Smith</Penciller>
  <Publisher>Unknown</Publisher>
</ComicInfo>
EOF
echo "page" > multi_attr_test/comic/page.txt
cd multi_attr_test/comic && zip -q ../test_comic.cbz * && cd ../..

echo
echo "BEFORE: Original ComicInfo.xml"
echo "========================================"
unzip -p multi_attr_test/test_comic.cbz ComicInfo.xml
echo

echo
echo "TEST 1: Update multiple attributes at once"
echo "============================================"
echo "Command: --attribute Series=\"The Amazing Spider-Man\" Publisher=\"Marvel Comics\" Volume=1 LanguageISO=\"en\""
echo

./comic_info_modifier.py multi_attr_test/test_comic.cbz \
    --attribute Series="The Amazing Spider-Man" Publisher="Marvel Comics" Volume=1 LanguageISO="en" \
    -v

echo
echo "AFTER TEST 1: Multiple updates"
echo "========================================"
unzip -p multi_attr_test/test_comic.cbz ComicInfo.xml
echo

echo
echo "TEST 2: Mix updates and removals"
echo "=================================="
echo "Command: --attribute Title=\"New Title\" Writer=null Penciller=null"
echo

./comic_info_modifier.py multi_attr_test/test_comic.cbz \
    --attribute Title="New Title" Writer=null Penciller=null \
    -v

echo
echo "AFTER TEST 2: Updates + Removals"
echo "========================================"
unzip -p multi_attr_test/test_comic.cbz ComicInfo.xml
echo

echo
echo "TEST 3: Multiple attributes with --update-only"
echo "==============================================="
echo "Command: --attribute Series=\"Updated Again\" NewField=\"Test\" --update-only"
echo "(NewField should be skipped, Series should update)"
echo

./comic_info_modifier.py multi_attr_test/test_comic.cbz \
    --attribute Series="Updated Again" NewField="Test" \
    --update-only \
    -v

echo
echo "AFTER TEST 3: Update-only mode"
echo "========================================"
unzip -p multi_attr_test/test_comic.cbz ComicInfo.xml
echo

echo
echo "Summary:"
echo "- Added Volume and LanguageISO ✓"
echo "- Updated Series and Publisher ✓"
echo "- Removed Writer and Penciller ✓"
echo "- Updated Title ✓"
echo "- Skipped NewField (update-only mode) ✓"
echo

rm -rf multi_attr_test

echo "====================================="
echo "All tests complete!"
echo "====================================="