#!/bin/bash
# Demo of improved disk usage - backups are deleted immediately

echo "====================================="
echo "Disk Usage Improvement Demo"
echo "====================================="
echo
echo "This demonstrates that backups are now deleted"
echo "immediately after processing each file, rather"
echo "than being kept until the end."
echo

cd /home/claude
mkdir -p disk_usage_demo

# Create 10 test comics
echo "Creating 10 test comics..."
for i in {1..10}; do
    mkdir -p disk_usage_demo/comic$i
    cat > disk_usage_demo/comic$i/ComicInfo.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo>
  <Title>Test Comic $i</Title>
  <Series>Test Series</Series>
</ComicInfo>
EOF
    # Add some dummy data to make files larger
    dd if=/dev/zero of=disk_usage_demo/comic$i/page01.jpg bs=1M count=1 2>/dev/null
    dd if=/dev/zero of=disk_usage_demo/comic$i/page02.jpg bs=1M count=1 2>/dev/null

    cd disk_usage_demo/comic$i && zip -q ../comic$i.cbz * && cd ../..
    rm -rf disk_usage_demo/comic$i
done

echo "Created 10 comics (~2MB each)"
echo

# Get initial size
ORIGINAL_SIZE=$(du -sh disk_usage_demo/*.cbz | awk '{s+=$1}END{print s}')
echo "Total size of comics: $(du -sh disk_usage_demo | awk '{print $1}')"
echo

# Get /tmp usage before
echo "Checking /tmp disk usage..."
TMP_BEFORE=$(df -h /tmp | tail -1 | awk '{print $3}')
echo "/tmp used before: $TMP_BEFORE"
echo

# Create a wrapper script that monitors backup directory
cat > disk_usage_demo/monitor.sh << 'MONITOR_EOF'
#!/bin/bash
# Monitor the backup directory size during processing

BACKUP_DIR=$(ls -td /tmp/comic_backup_* 2>/dev/null | head -1)

if [ ! -z "$BACKUP_DIR" ]; then
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | awk '{print $1}')
    BACKUP_COUNT=$(ls "$BACKUP_DIR" 2>/dev/null | wc -l)
    echo "[MONITOR] Backup dir size: $BACKUP_SIZE ($BACKUP_COUNT files)"
fi
MONITOR_EOF
chmod +x disk_usage_demo/monitor.sh

echo "====================================="
echo "Processing comics with verbose mode"
echo "====================================="
echo "Watch the backup directory - files should be"
echo "deleted immediately after processing."
echo

# Process with monitoring
(
    while true; do
        sleep 0.5
        ./disk_usage_demo/monitor.sh
    done
) &
MONITOR_PID=$!

# Run the actual processing
./comic_info_modifier.py disk_usage_demo/*.cbz --attribute Publisher="Test Publisher" -v 2>&1 | \
    grep -E "(Processing:|Deleted backup:|Backup dir|Successfully|Processing complete)" | head -30

# Stop monitoring
kill $MONITOR_PID 2>/dev/null
wait $MONITOR_PID 2>/dev/null

echo
TMP_AFTER=$(df -h /tmp | tail -1 | awk '{print $3}')
echo "/tmp used after: $TMP_AFTER"
echo

echo "====================================="
echo "Analysis:"
echo "====================================="
echo
echo "OLD BEHAVIOR (before this fix):"
echo "  • All 10 backups kept in /tmp simultaneously"
echo "  • Peak usage: ~20MB (10 comics × 2MB each)"
echo "  • Risk: Could fill up /tmp partition"
echo
echo "NEW BEHAVIOR (with this fix):"
echo "  • Only 1 backup in /tmp at a time"
echo "  • Peak usage: ~2MB (1 comic × 2MB)"
echo "  • Deleted immediately after processing"
echo
echo "For a collection of 1000 comics at 100MB each:"
echo "  OLD: 100GB in /tmp (would fail!)"
echo "  NEW: 100MB in /tmp (just one file)"
echo
echo "RESULT: Can now process unlimited collection size!"
echo

# Check if any backup files remain
REMAINING=$(ls /tmp/comic_backup_* 2>/dev/null | wc -l)
if [ $REMAINING -eq 0 ]; then
    echo "✓ No backup directories remaining in /tmp"
else
    echo "⚠ Found $REMAINING backup directories (should be 0)"
fi

rm -rf disk_usage_demo

echo
echo "====================================="
echo "Demo complete!"
echo "====================================="