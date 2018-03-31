2.93:
- Update Transmission

2.92.2:
- Security update: mitigate dns rebinding attacks against daemon. See: https://github.com/transmission/transmission/pull/468

2.92:
- Add support for ADM 3.0

2.84-r1:
- Recompile package against newer OpenSSL
- Add support for ARM

2.84: Fix peer communication vulnerability (no known exploits) reported by Ben
Hawkes

2.83-r3: All linked libs are now included, unused libs are removed.

2.83-r2: Added default settings.json with whitelist disabled and full file
preallocation enabled (for better performance).

2.83-r1: Included some libs that are / might be required.

Initial release, Transmission 2.83 (14283).
