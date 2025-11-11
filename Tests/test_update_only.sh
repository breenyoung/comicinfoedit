#!/bin/bash
# Test script for --update-only flag

echo "====================================="
echo "Testing --update-only Flag"
echo "====================================="
echo

# Create test directory
mkdir -p update_only_test
cd update_only_test

# Create first comic WITH Publisher attribute
echo "Creating test_with_publisher.cbz..."
mkdir -p comic1
cat > comic1/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic With Publisher</Title>
  <Series>Test Series</Series>
  <Publisher>Original Publisher</Publisher>
</ComicInfo>
EOF
echo "Test page" > comic1/page01.txt
cd comic1 && zip -q ../test_with_publisher.cbz * && cd ..

# Create second comic WITHOUT Publisher attribute
echo "Creating test_without_publisher.cbz..."
mkdir -p comic2
cat > comic2/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Comic Without Publisher</Title>
  <Series>Test Series</Series>
</ComicInfo>
EOF
echo "Test page" > comic2/page01.txt
cd comic2 && zip -q ../test_without_publisher.cbz * && cd ..

echo
echo "====================================="
echo "Test 1: Normal mode (creates attribute)"
echo "====================================="
echo

echo "Before: test_without_publisher.cbz"
unzip -p test_without_publisher.cbz ComicInfo.xml
echo

../comic_info_modifier.py test_without_publisher.cbz --attribute Publisher="New Publisher" -v

echo
echo "After: test_without_publisher.cbz"
unzip -p test_without_publisher.cbz ComicInfo.xml
echo

# Restore for next test
rm test_without_publisher.cbz
cd comic2 && zip -q ../test_without_publisher.cbz * && cd ..

echo
echo "====================================="
echo "Test 2: Update-only mode (skips creation)"
echo "====================================="
echo

echo "Comics before update-only test:"
echo "- test_with_publisher.cbz HAS Publisher"
echo "- test_without_publisher.cbz DOES NOT have Publisher"
echo

../comic_info_modifier.py *.cbz --attribute Publisher="Marvel Comics" --update-only -v

echo
echo "Results:"
echo "--------"
echo "test_with_publisher.cbz (should be updated):"
unzip -p test_with_publisher.cbz ComicInfo.xml | grep -A1 "Publisher"
echo

echo "test_without_publisher.cbz (should be unchanged):"
if unzip -p test_without_publisher.cbz ComicInfo.xml | grep -q "Publisher"; then
    echo "ERROR: Publisher was created (should have been skipped)"
else
    echo "SUCCESS: Publisher attribute not created (as expected)"
fi

echo
echo "====================================="
echo "Test 3: Update-only with existing attribute"
echo "====================================="
echo

echo "Before:"
unzip -p test_with_publisher.cbz ComicInfo.xml | grep "Publisher"

../comic_info_modifier.py test_with_publisher.cbz --attribute Publisher="DC Comics" --update-only -v

echo
echo "After:"
unzip -p test_with_publisher.cbz ComicInfo.xml | grep "Publisher"

# Cleanup
cd ..
rm -rf update_only_test

echo
echo "====================================="
echo "All update-only tests complete!"
echo "====================================="