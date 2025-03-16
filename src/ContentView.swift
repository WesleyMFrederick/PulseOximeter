import SwiftUI

struct ContentView: View {
    
    @ObservedObject var bluetoothManager = BluetoothManager.init()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Bluetooth Status: \(bluetoothManager.bluetoothState.rawValue)")
                if let selectedDevice = bluetoothManager.selectedDevice {
                    Text("Connected to: \(selectedDevice.name ?? "Unknown Device")")
                    Text("SpO2: \(bluetoothManager.spo2, specifier: "%.1f")%")
                    Text("Heart Rate: \(bluetoothManager.heartRate) bpm")
                    Button("Disconnect") {
                        bluetoothManager.disconnect()
                    }
                    if bluetoothManager.isRecording {
                        Text("Recording...")
                        Button("Stop Recording") {
                            bluetoothManager.stopRecording()
                        }
                    } else {
                        Button("Start Recording") {
                            bluetoothManager.startRecording()
                        }
                    }
                    
                    NavigationLink(destination: DebugView(bluetoothManager: bluetoothManager)) {
                        Text("Debug View")
                    }
                } else {
                    List(bluetoothManager.discoveredDevices, id: \.self) { device in
                        HStack {
                            Text(device.name ?? "Unknown Device")
                            Spacer()
                            Button("Connect") {
                                bluetoothManager.connect(device: device)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pulse Oximeter")
        }
    }
}

struct DebugView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Section(header: Text("Bluetooth Status").font(.headline)) {
                    Text("Status: \(bluetoothManager.bluetoothState.rawValue)")
                    if let device = bluetoothManager.selectedDevice {
                        Text("Connected to: \(device.name ?? "Unknown Device")")
                    } else {
                        Text("Not connected")
                    }
                }
                
                Section(header: Text("Discovered Services").font(.headline)) {
                    Text(bluetoothManager.getDiscoveredServicesInfo())
                        .font(.system(.body, design: .monospaced))
                }
                
                Section(header: Text("Discovered Characteristics").font(.headline)) {
                    Text(bluetoothManager.getDiscoveredCharacteristicsInfo())
                        .font(.system(.body, design: .monospaced))
                }
                
                Section(header: Text("Raw Data").font(.headline)) {
                    ForEach(Array(bluetoothManager.getRawDataLog().keys.sorted()), id: \.self) { key in
                        VStack(alignment: .leading) {
                            Text("Characteristic: \(key)")
                                .font(.subheadline)
                                .bold()
                            if let data = bluetoothManager.getRawDataLog()[key] {
                                if let hexString = data["hexString"] as? String {
                                    Text("Hex: \(hexString)")
                                        .font(.system(.caption, design: .monospaced))
                                }
                                if let timestamp = data["timestamp"] as? Date {
                                    Text("Last update: \(timestamp, formatter: dateFormatter)")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
            .padding()
        }
    }
    
    // Date formatter for timestamps
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }
}
