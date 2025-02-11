
---

#### 2. `bin/usbip_bind_all.sh`

```bash
#!/bin/bash
# /usr/local/bin/usbip_bind_all.sh
# This script enumerates USB devices and binds any that are not already exported.
#
# It uses the output of "usbip list -l" to extract bus IDs.
#
# Note: In a production system you may wish to refine the matching so that
# internal hubs or non-exportable devices are skipped.

usbip list -l | grep "busid" | while read -r line; do
    # Example line format:
    #   - busid 1-1.2 (0403:6001) [USB Serial Converter]
    bus=$(echo "$line" | awk '{print $3}')
    # Check if the device is already exported (the word "exported" appears)
    if echo "$line" | grep -q "exported"; then
        echo "Device $bus already exported – skipping."
    else
        echo "Binding USB device at busid $bus ..."
        usbip bind -b "$bus"
    fi
done
