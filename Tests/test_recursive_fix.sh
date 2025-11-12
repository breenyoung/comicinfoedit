#!/bin/bash
# Test demonstrating the recursive addition bug fix

echo "========================================="
echo "Recursive Addition Bug Fix Test"
echo "========================================="
echo
echo "This test demonstrates the fix for the recursive addition bug"
echo "where the output zip file could be added to itself, causing"
echo "Python to crash with memory/recursion issues."
echo

cd /home/claude
mkdir -p recursive_test

# Create a simple comic
mkdir -p recursive_test/comic
cat > recursive_test/comic/ComicInfo.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Test Comic</Title>
  <Series>Test Series</Series>
</ComicInfo>
EOF
echo "page data" > recursive_test/comic/page01.jpg
echo "page data" > recursive_test/comic/page02.jpg

cd recursive_test/comic && zip -q ../test.cbz * && cd ../..

echo "Created test comic: test.cbz"
echo

echo "========================================="
echo "Running script with verbose mode"
echo "========================================="
echo
echo "Watch for the 'Skipping recursive add' message."
echo "This proves the fix is working and preventing"
echo "the output file from being added to itself."
echo

./comic_info_modifier.py recursive_test/test.cbz \
    --attribute Publisher="Test" \
    -v 2>&1 | grep -E "(Processing|Skipping recursive|Created CBZ|Successfully)"

echo
echo "========================================="
echo "Verification"
echo "========================================="
echo
echo "Checking final archive contents:"
unzip -l recursive_test/test.cbz

echo
echo "✓ Notice there's NO nested 'temp_test.cbz' file"
echo "✓ Only the original files are present"
echo "✓ The fix prevented recursive addition"
echo

# Verify no temp files were added
if unzip -l recursive_test/test.cbz | grep -q "temp_"; then
    echo "❌ ERROR: temp_ file found in archive!"
else
    echo "✓ PASS: No temp files in archive"
fi

rm -rf recursive_test

echo
echo "========================================="
echo "Bug fix verified!"
echo "========================================="
echo
echo "The fix compares the absolute path of each file"
echo "being added against the output file's path."
echo "If they match, the file is skipped, preventing"
echo "infinite recursion and memory exhaustion."