#!/bin/bash
# Test script for comic_info_modifier.py

echo "====================================="
echo "Comic Info Modifier - Test Script"
echo "====================================="
echo

# Check if test CBZ exists
if [ ! -f "test_comic.cbz" ]; then
    echo "Error: test_comic.cbz not found!"
    echo "Creating test comic..."
    mkdir -p test_comic
    cat > test_comic/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Title>The Amazing Issue</Title>
  <Series>Test Series</Series>
  <Number>1</Number>
  <Volume>1</Volume>
  <Writer>John Doe</Writer>
  <Penciller>Jane Smith</Penciller>
  <Publisher>Test Publisher</Publisher>
  <Year>2024</Year>
  <Month>1</Month>
  <Genre>Superhero</Genre>
  <Summary>This is a test comic book for demonstration purposes.</Summary>
</ComicInfo>
EOF
    echo "Test comic page" > test_comic/page01.txt
    zip -q test_comic.cbz test_comic/*
    echo "Test comic created!"
fi

# Make a copy for testing
cp test_comic.cbz test_comic_backup.cbz

echo "Test 1: View original ComicInfo.xml"
echo "------------------------------------"
unzip -p test_comic.cbz ComicInfo.xml | head -n 20
echo

echo "Test 2: Update Series attribute"
echo "--------------------------------"
./comic_info_modifier.py test_comic.cbz --attribute Series="Updated Series Name" -v
echo

echo "Test 3: View modified ComicInfo.xml"
echo "------------------------------------"
unzip -p test_comic.cbz ComicInfo.xml | grep -A1 "<Series>"
echo

echo "Test 4: Add new attribute"
echo "-------------------------"
./comic_info_modifier.py test_comic.cbz --attribute LanguageISO="en" -v
echo

echo "Test 5: View with new attribute"
echo "--------------------------------"
unzip -p test_comic.cbz ComicInfo.xml | grep -A1 "<LanguageISO>"
echo

echo "Test 6: Remove attribute"
echo "------------------------"
./comic_info_modifier.py test_comic.cbz --attribute Writer=null -v
echo

echo "Test 7: Verify removal"
echo "----------------------"
if unzip -p test_comic.cbz ComicInfo.xml | grep -q "<Writer>"; then
    echo "ERROR: Writer attribute still present!"
else
    echo "SUCCESS: Writer attribute removed"
fi
echo

# Restore original
echo "Restoring original test file..."
mv test_comic_backup.cbz test_comic.cbz

echo
echo "====================================="
echo "All tests complete!"
echo "====================================="