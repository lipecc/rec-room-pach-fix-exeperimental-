# Rec Room on Proton – Compatibility Patch & Performance Notes

## Overview

This repository provides a **compatibility patch** that allows **Rec Room** to launch on **Proton / Wine**.

⚠️ **Important:**
The game **runs**, but **performance issues remain** (low FPS, stuttering, input latency).
This project focuses on **startup compatibility**, not full performance parity with Windows.

---

## Current Status

* ✅ Game launches successfully
* ✅ No missing DLL errors
* ✅ Initial anti-cheat handshake passes
* ⚠️ Severe FPS drop
* ⚠️ Stuttering and unstable frame times
* ⚠️ High CPU usage

---

## What This Patch Does

### CoreMessaging Compatibility Fix

The included patch modifies Wine behavior related to **CoreMessaging** APIs.

Specifically, it:

* Prevents startup failure caused by missing CoreMessaging responses
* Returns expected success states to the game
* Allows the boot process to complete

This enables the game to **start and reach gameplay**.

---

## What This Patch Does NOT Do

* ❌ Does not implement real Windows kernel services
* ❌ Does not improve GPU performance
* ❌ Does not fix Unity thread scheduling issues
* ❌ Does not remove anti-cheat overhead

The patch avoids crashes but **does not replicate native Windows behavior**.

---

## Why Performance Is Still Poor

### 1. Kernel-Level Expectations

Rec Room relies on Windows services that:

* Exist in kernel space on Windows
* Are emulated in user space on Wine

This causes:

* High CPU overhead
* Excessive context switching
* Thread contention

---

### 2. Unity Engine Behavior

Unity relies heavily on:

* Thread pools
* Synchronization primitives
* Message queues

On Proton:

* Many calls take slower fallback paths
* Frame pacing becomes unstable

---

### 3. Degraded Runtime Mode

By bypassing certain checks:

* The game continues running
* But does so in a degraded compatibility state

This results in:

* CPU bottlenecks
* Low and unstable FPS

---

## Requirements

* Proton Experimental (Bleeding Edge)
* Clean prefix recommended
* Reinstall may be required after applying the patch

---

## Installation

```bash
chmod +x install_patch.sh
./install_patch.sh
```

After installation:

* Restart Steam
* Clear shader cache if needed
* Launch the game using Proton Experimental

---

## Known Limitations

* Performance will not match Windows
* FPS improvements are limited by architecture
* Further gains require upstream Wine/Proton changes or official developer support

---

## Conclusion

This project demonstrates that **Rec Room can run on Proton**, but also highlights the **architectural limits** of compatibility layers when kernel-level services and anti-cheat systems are involved.

The remaining performance issues are **not configuration bugs**, but **fundamental design constraints**.

---

## Disclaimer

This project is **not affiliated** with Rec Room Inc. or Valve.
Use at your own risk.

---
