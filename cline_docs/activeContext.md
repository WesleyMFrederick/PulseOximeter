# Active Context

- Current task: Develop comprehensive data storage strategy for Bluetooth pulse oximeter data.
- Next step: Transition to Execution phase to implement Core Data storage.
- Status: Completed detailed strategy for data storage using Core Data.
- Previous task: Implemented data parsing for Bluetooth pulse oximeter data.
- Action: Developed Core Data model and supporting infrastructure design.
- Resources obtained:
  - FS20F protocol details from `knowledge_base/FS20F/parser.py` and `knowledge_base/FS20F/sample_output.json`
  - Real-world pulse oximeter data patterns from device testing

## Data Storage Strategy
- Selected Core Data for persistence framework due to native iOS integration and SwiftUI compatibility
- Designed data model with separate entities for Recording, ParamReading, and WaveReading
- Established buffered approach for high-frequency wave data to optimize performance
- Planned RecordingManager component to handle data capture, storage, and retrieval

## Implementation Components
1. Core Data Model:
   - Recording entity with metadata (name, timestamps, device info)
   - ParamReading entity for clinical metrics (SpO2, heart rate, perfusion index)
   - WaveReading entity for waveform visualization data (PPG, SpO2 wave)
2. PersistenceController for Core Data stack management
3. RecordingManager for session and data management
4. UI components for recording management and visualization
