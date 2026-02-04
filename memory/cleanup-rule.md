# Cleanup Rule for Bro

## Golden Rule
**ALWAYS clean up partial/failed installations before trying again.**

## When to Clean
- Before reinstalling the same tool
- After failed installation attempts
- When "weird errors" appear (missing files, version conflicts)

## What to Clean
```bash
# Flutter/Dart installations
rm -rf /Volumes/workspace-drive/instruments/flutter*
rm -rf /Volumes/workspace-drive/instruments/dart*
rm -rf ~/.local/bin/sysctl  # temp workarounds

# Build artifacts
rm -rf project/.dart_tool/build_runner/
rm -rf project/build/

# Failed processes
pkill -9 dart
pkill -9 flutter
```

## Checklist Before New Installation
- [ ] Remove old versions
- [ ] Kill hanging processes  
- [ ] Clear temp workarounds
- [ ] Verify clean state: `ls /path/` should be empty

## Remember
- Disk space is cheap, but conflicts are expensive
- "Maybe I'll need it" → No, you won't. Clean it.
- Better to start fresh than debug ghosts
