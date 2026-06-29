#!/bin/bash
case $1/$2 in
  post/*)
    # Create the worker script that does the actual work
    cat > /tmp/usb-wake-reset-worker.sh << 'WORKER'
#!/bin/bash
exec > /tmp/usb-wake-reset.log 2>&1
echo "=== Worker started at $(date) ==="

sleep 5

echo "Resetting DAC..."
/usr/bin/usbreset 152a:8750 || true
echo "Resetting PCPanel..."
/usr/bin/usbreset 0483:a3c5 || true

echo "Waiting 45s for firmware recovery..."
sleep 45

for attempt in $(seq 1 10); do
  echo "--- Attempt $attempt at $(date) ---"

  # Set hidraw ACL
  for h in /sys/class/hidraw/hidraw*; do
    parent=$(readlink -f "$h/device/../.." 2>/dev/null)
    echo "$parent" | grep -q "3-4" && setfacl -m u:btw:rw- "/dev/$(basename "$h")"
  done

  # Restart service
  /usr/bin/sudo -u btw XDG_RUNTIME_DIR=/run/user/1000 /usr/bin/systemctl --user restart pcpanel.service || true

  # Monitor 30 seconds continuously
  failed=0
  for sec in $(seq 1 30); do
    sleep 1
    dch=$(/usr/bin/sudo -u btw XDG_RUNTIME_DIR=/run/user/1000 /usr/bin/journalctl --user -u pcpanel.service --since "$((sec+1)) seconds ago" --no-pager 2>/dev/null | grep -c "DCH ERR")
    if [ "$dch" -gt 0 ]; then
      echo "  DCH ERR at second $sec"
      failed=1
      break
    fi
  done

  if [ "$failed" -eq 0 ]; then
    echo "SUCCESS on attempt $attempt!"
    exit 0
  fi
  echo "  Retry in 5s..."
  sleep 5
done
echo "All attempts failed."
WORKER
    chmod +x /tmp/usb-wake-reset-worker.sh

    # Launch as INDEPENDENT systemd service — survives hook death
    /usr/bin/systemd-run --unit=usb-wake-reset-service /tmp/usb-wake-reset-worker.sh
    ;;
esac
