# Pulse Oximeter iOS App

## Project Overview
This iOS application connects to a Wellue Model FS20F Bluetooth pulse oximeter to record, visualize, and analyze blood oxygen levels and heart rate data. Designed primarily for surfing athletes during breath training sessions, this app addresses limitations in existing freediving applications by providing flexibility to record readings without preset routines.

## Purpose
The application enables surfing athletes to:
- Monitor blood oxygen saturation (SpO2) and heart rate in real-time
- Record training sessions with accurate timestamped data
- Review historical session data to track progress
- Analyze performance patterns during breath training

## Features

### Current Implementation
- ✅ Bluetooth device scanning and connection
- ✅ Real-time display of SpO2 and heart rate values
- ✅ Recording start/stop functionality
- ✅ Bluetooth protocol parsing for Wellue FS20F

### In Progress
- 🔄 Core Data implementation for persistent storage
- 🔄 Recording management (browse, rename, delete sessions)
- 🔄 Data visualization with line graphs

### Planned Features
- 📊 Enhanced data visualization with interactive controls
- 🔍 Statistical analysis of training sessions
- 🔄 Export functionality for sharing data

## Technical Details

### Bluetooth Protocol

The Wellue FS20F pulse oximeter communicates using a custom Bluetooth protocol with the following structure:

#### Message Format
All messages follow this format:
```
[Start Token (0xFE)] [Length] [Type] [Payload...] [Checksum]
```

#### Parameter Message (Type 0x55)
Contains clinical measurements including:
- Heart rate (beats per minute)
- SpO2 (oxygen saturation percentage)
- Perfusion index (signal strength)

Parsing details:
- Heart rate is encoded as a 16-bit value (little-endian)
- SpO2 is a single byte percentage value
- Perfusion index is a 16-bit value divided by 1000

#### Waveform Message (Type 0x56)
Contains high-frequency visualization data:
- PPG (photoplethysmogram) waveform value
- SpO2 waveform value
- Sensor status flags

These messages arrive at approximately 60Hz and are used for continuous waveform visualization.

### Data Architecture

The application uses Core Data with a model comprising:
- Recording entity: Session metadata (timestamps, name, device info)
- ParamReading entity: Clinical metrics (SpO2, heart rate, perfusion index)
- WaveReading entity: Waveform visualization data (PPG, SpO2 wave)

## Development Status
This application is currently a proof of concept under active development. The foundational Bluetooth connectivity and data parsing are implemented, with data persistence and visualization features in progress.

## Technical Environment
- Target device: iPhone running iOS 18.31
- Development device: Macbook Air running macOS 14
- Development tools:
  - Xcode 16.1 (16B40)
  - VS Code 1.98.1
  - [Cline](https://github.com/cline/cline) with [CRCT](https://github.com/RPG-fan/Cline-Recursive-Chain-of-Thought-System-CRCT-) (Cline Recursive Chain of Thought) modification for AI-assisted development
  - Python (for auxiliary development needs)
- Hardware: Wellue Model FS20F pulse oximeter (Bluetooth-enabled, runs on 2 AAA batteries)

## Future Development
Future iterations will focus on enhancing the visualization capabilities, adding statistical analysis features, and potentially enabling remote sharing with coaches.

## License
[Include appropriate license information]