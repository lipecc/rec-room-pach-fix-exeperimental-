# Rec Room on Proton – Compatibility Patch & Performance Notes

## Overview

This repository provides a **compatibility patch** that allows **Rec Room** to launch and run on **Proton / Wine**.

⚠️ **Important:**
The game runs, but performance is **not yet equivalent to native Windows**.
This project focuses on **compatibility and mitigation**, not a full performance fix.

---

## Current Status

* ✅ Game launches successfully
* ✅ No missing DLL errors
* ✅ Initial anti-cheat handshake passes
* ⚠️ Low FPS in some scenes
* ⚠️ Stuttering and unstable frame pacing
* ⚠️ High CPU usage

---

## What This Patch Does

### CoreMessaging Compatibility Fix

The included patch adjusts Wine’s **CoreMessaging** behavior to prevent startup failure.

It:

* Returns expected success states to the game
* Prevents early termination during boot
* Allows the game to reach gameplay

This ensures the game **starts and remains running**.

---

## ⚠️ Important Requirement – Proton Prefix Creation

**The game must be launched at least once before applying this patch.**

This is required because:

* Proton only creates the game prefix (`compatdata`) on the first launch
* The patch script modifies files **inside the Proton prefix**
* These files include Wine DLLs and system components used by Proton

If the game has never been launched, the prefix **does not exist**, and the script will fail or apply nothing.

### Required Steps

1. Install the game
2. Launch it once with Proton (even if it crashes or fails)
3. Close the game
4. Apply the patch
5. Relaunch the game

---

## What This Patch Does NOT Do

* ❌ Does not implement real Windows kernel services
* ❌ Does not remove anti-cheat overhead
* ❌ Does not fully resolve Unity thread scheduling limitations
* ❌ Does not guarantee Windows-level performance

---

## Performance Workaround (Important)

Significant performance improvements (reduced stutter and improved frame pacing) have been observed when launching the game with the following command:

```bash
WINEDLLOVERRIDES="coremessaging=n,b" PROTON_USE_WINED3D=0 DXVK_ASYNC=1 %command%
```

### Explanation

* **WINEDLLOVERRIDES="coremessaging=n,b"**
  Forces Wine’s built-in CoreMessaging implementation and avoids degraded fallback paths that cause excessive CPU usage.

* **PROTON_USE_WINED3D=0**
  Ensures DXVK is used instead of WineD3D, preventing OpenGL fallback.

* **DXVK_ASYNC=1**
  Enables asynchronous shader compilation, reducing stutter and improving frame pacing.

---

## Results

With this workaround:

* ✅ Game remains stable
* ✅ No DLL-related crashes
* ✅ Noticeable reduction in stutter
* ✅ Improved frame pacing
* ⚠️ FPS may still be lower than Windows
* ⚠️ CPU bottlenecks can still occur in complex scenes

This mitigates the “slow-motion” / heavy lag behavior, but does not fully eliminate performance limitations.

---

## Requirements

* Proton Experimental (Bleeding Edge)
* Game must be launched once to generate the Proton prefix
* Clean prefix recommended
* Reinstall may be required after applying the patch

---

## Installation

```bash
chmod +x install_patch.sh
./install_patch.sh
```

After installation:

1. Restart Steam
2. Set Proton Experimental (Bleeding Edge)
3. Add the launch command above
4. Launch the game

---

## Known Limitations

* Performance improvements are limited by Wine/Proton architecture
* Further gains require upstream fixes or official developer support
* Kernel-level Windows behavior cannot be fully replicated in user space

---

## Conclusion

This project demonstrates that **Rec Room can run on Proton**, but also highlights the **architectural limits** of compatibility layers when kernel-level services and anti-cheat systems are involved.

Remaining performance issues are **not user configuration errors**, but **design constraints**.

---

## Disclaimer

This project is **not affiliated** with Rec Room Inc. or Valve.
Use at your own risk.


