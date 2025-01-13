# Mega-Lucky
Ultimate IO mod for the Lucky Group electronic guitar toy (らっき組 ギター) RK-001, made by People Co., Ltd.  

The guitar toy in question has no external connectors. None at all, not even a headphone jack.
This project adds a 3.5mm line-out, a 6VDC barrel jack power input,
and MIDI in/out through additional 3.5mm TRS jacks.  

## Line out
The line-level audio output is amplified from the DAC output directly.
The DAC is stereo but the built-in volume pot is only mono, so I have chosen to bypass the pot for line-out.
In the future I may look into ways of including the pot without significant physical mods.
There are option jumpers to filter out the strong bass designed for the internal speaker.  

## Power
The power input intercepts the battery connector to allow external 6VDC as an alternative.
The safe range is actually 4.5 to 9 volts, but the built-in regulator will run hotter at higher voltages.
There is no overvoltage protection, but polarity protection and minimal filtering is included.  

## MIDI
The MIDI connections take advantage of some unlabeled test points on the guitar's PCB.
The guitar is based around a Yamaha XU947C0 LSI chip, which integrates a CPU and MIDI synth.
I found that its MIDI input and output pins (same pins as on a DB51XG) are fully functional.
Input may be used as a MIDI synth module combined with line-out, while output implements a basic MIDI guitar controller.
The Mega-Lucky board provides these MIDI in/out connections via type-A\* TRS connectors.  

## Installation
A proper visual installation guide will be made once the full functionality of the mod is verified.  

For now some rough steps:
- Desolder speaker wires, take the main board out.
- Remove two mixing resistors R10,R45 from the main board.
- Add two wires and optional shield to the DAC (IC3) output pins (L closest to pot).
- If reusing original battery connector, desolder it and install on mod board, otherwise use new connector.
- Use the 3D-printed drill guide to mark and drill holes (6.5-7mm for TRS, 8-9mm for DC).
- Solder the audio wires to the marked points on the mod board.
- Carefully wiggle the main board and mod connectors into place, mind the ribbon cables.
- Put M3 washers (0.5mm thick) between the boards at the screw holes and screw everything back in.
- Wire the MIDI pads to the relevant test points\*\*.
- Solder remaining 6 pads to the adjacent pads/pins.
- Resolder speaker wires or add some kind of connector.
- Solder the `HI-BASS` option jumper if desired. DO NOT set the `LOUD` jumpers on v1.0 boards.
- Solder MIDI type jumpers\* for your adapters.
- Extend the battery cable if necessary to reach the new location. Don't plug into old location.\*\*\*

\* MIDI TRS type:
Recommended type A (MIDI standard, KORG, Akai, Make Noise etc).
Alternative type B (Arturia, Novation etc).
You may need extra wire clippings to bridge the jumpers for type B on v1.0 boards.  

\*\* MIDI test points (will add photos later):
Below the big `DY798` text, the second test point down is MIDI out (to `M.TX`).
Further down are 2 more points, furthest to the right is MIDI in (to `M.RX`).  

\*\*\* Battery connector safety:
The original battery connector pads are not disconnected when external DC is used.
Using these may cause extensive damage if external DC is connected with batteries in place.
You must plug the battery cable into the new location on the mod board instead.  

## PCB assembly notes
- Clean out castellated pads with tweezers if produced the cheap way (i.e. not paying for special routing).
- Shave the top-front straight edge of the TRS connectors if new to ensure a proper fit.
- You may wish to leave some connector pins unsoldered to allow realigning during installation.
- Don't populate Q1-Q3, R25-R28, these are experimental alternative MIDI out driver.
- DO NOT set the `LOUD` jumpers on v1.0 boards, this is broken. Leave R19-R22 & C13 unpopulated.
