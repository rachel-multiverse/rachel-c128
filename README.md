# Rachel - Commodore 128 Client

A render-only client for the Rachel card game, written in 8502/Z80 assembly for the Commodore 128.

## Requirements

- Commodore 128 (or emulator like VICE x128)
- WiFi modem (e.g., WiFi232 or similar RS-232 adapter)
- Rachel iOS host application

## Building

```bash
make
```

Requires xa65 or similar 6502 cross-assembler.

## Features

- 80-column VDC display for better card visibility
- TCP/IP networking via WiFi modem
- RUBP binary protocol (64-byte messages)
- Full game state rendering

## Architecture

The client runs in C128 native mode using the 80-column VDC display:
- Uses 8502 CPU (C64 compatibility mode not required)
- VDC provides 80x25 text display
- RS-232 user port for WiFi modem connection

## Controls

- Left/Right: Move cursor
- Space: Select/deselect card
- Return: Play selected cards
- D: Draw card
- Q: Quit to connection screen

## Network Protocol

Uses RUBP (Rachel UDP Binary Protocol):
- 64-byte fixed-size messages
- 16-byte header + 48-byte payload
- Big-endian byte order

## License

MIT License - See LICENSE file
