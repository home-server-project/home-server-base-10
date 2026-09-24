#!/usr/bin/bash
set -euo pipefail

# Home Server Base owns common host runtime policy inherited by downstream
# appliances. Copy the declarative files into the image, then bake service
# enablement into the immutable system without starting services at build time.
cp -avf /ctx/system_files/. /

systemctl enable systemd-resolved.service
