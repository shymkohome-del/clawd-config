## SUPERNEW Implementation

**Status:** Implemented and ready for use

**Components:**
- Handoff: `memory/HANDOFF-SUPERNEW.md` - recovery point
- Soft Reset: Save → Clear → Reload cycle

**How it works:**
1. User says "supernew" → handoff file created
2. Full context saved to files
3. Agent clears internal context
4. Reloads from files
5. Fresh session with preserved knowledge

**Test:** Say "supernew" - agent should save context and reload.
