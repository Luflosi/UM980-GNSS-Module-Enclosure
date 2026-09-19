[SPDX-FileCopyrightText: 2026 Luflosi <UM980-GNSS-Module-Enclosure@luflosi.de>]::
[SPDX-License-Identifier: GPL-3.0-only]::

# Enclosure for Unicore UM980 GNSS Module

## A small 3D printed enclosure for a Unicore UM980 module.

[Model on Printables.com](https://www.printables.com/model/1845424-um980-gnss-module-enclosure)

![Front view of the enclosure](Picture%20front.avif)
![Top view of the enclosure](Picture%20top.avif)

I bought this module on AliExpress.
It came with headers, which I unsoldered.

This design is not perfect (yet? Contributions welcome).

Flaws of the design:

- The antenna hole is slightly too small
- The antenna hole is slightly too close to the USB port, causing the two connectors to touch when the antenna connector is rotated in a certain way
- The antenna hole has a hex cutout, which is supposed to catch a part of the antenna connector and prevent it from rotating but it is too small and way too shallow
- The hole for the threaded insert only has two layers of plastic between the threaded insert and the bottom
- One of the standoffs has a square cutout to make room for the antenna connector on the PCB (a through-hole component). The square cutout is too small

The code for the heat-set insert standoff studs was made by [RonRN18](https://www.thingiverse.com/RonRN18/designs) and published at [Thingiverse: OpenSCAD Heat-set Insert Standoff Stud modules](https://www.thingiverse.com/thing:5849866). I modified the code and removed code which was not needed for my use-case.


## License
The license is the GNU GPLv3 (GPL-3.0-only).
