import CoreBluetooth
import Combine

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {

    @Published private var centralManager: CBCentralManager!
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var selectedDevice: CBPeripheral?
    @Published var isRecording: Bool = false
    @Published var spo2: Double = 98.0
    @Published var heartRate: Int = 72
    
    // New properties for data capture
    private var discoveredServices: [CBService] = []
    private var discoveredCharacteristics: [CBUUID: CBCharacteristic] = [:]
    private var rawDataLog: [String: [String: Any]] = [:]

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        let timestamp = Date()
        print("\(timestamp): Central Manager willRestoreState: \(dict)")
    }
        
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        let timestamp = Date()
        print("\(timestamp): Central Manager didUpdateState: \(central.state)")
        switch central.state {
        case .unknown:
            print("Central state is .unknown")
        case .resetting:
            print("Central state is .resetting")
        case .unsupported:
            print("Central state is .unsupported")
        case .unauthorized:
            print("Central state is .unauthorized")
        case .poweredOff:
            print("Central state is .poweredOff")
        case .poweredOn:
            print("Central state is .poweredOn")
            // Start scanning for devices here
            scanForDevices()
            break
        @unknown default:
            print("Central state is @unknown")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let timestamp = Date()
        print("\(timestamp): Discovered \(peripheral.name ?? "Unknown Device") - ID: \(peripheral.identifier)")
        
        // Print advertisement data to help identify the device
        print("\(timestamp): Advertisement data for \(peripheral.name ?? "Unknown Device"):")
        for (key, value) in advertisementData {
            print("   \(key): \(value)")
        }
        print("\(timestamp): RSSI: \(RSSI)")
        
        if !discoveredDevices.contains(peripheral) {
            discoveredDevices.append(peripheral)
        }
    }

    func scanForDevices() {
        let timestamp = Date()
        print("\(timestamp): Scanning for devices...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func connect(device: CBPeripheral) {
        let timestamp = Date()
        print("\(timestamp): Connecting to \(device.name ?? "Unknown Device")...")
        centralManager.connect(device, options: nil)
        selectedDevice = device
        device.delegate = self  // Set peripheral delegate
    }

    func disconnect() {
        let timestamp = Date()
        print("\(timestamp): Disconnecting from \(selectedDevice?.name ?? "Unknown Device")...")
        if let device = selectedDevice {
            centralManager.cancelPeripheralConnection(device)
            selectedDevice = nil
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let timestamp = Date()
        print("\(timestamp): Connected to \(peripheral.name ?? "Unknown Device")")
        
        // After connection, we need to discover services
        print("\(timestamp): Starting service discovery for \(peripheral.name ?? "Unknown Device")")
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let timestamp = Date()
        print("\(timestamp): Failed to connect to \(peripheral.name ?? "Unknown Device") with error: \(String(describing: error))")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let timestamp = Date()
        print("\(timestamp): Disconnected from \(peripheral.name ?? "Unknown Device") with error: \(String(describing: error))")
    }

    func startRecording() {
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
    }

    // Services and characteristics discovery
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let timestamp = Date()
        print("\(timestamp): Discovered services for \(peripheral.name ?? "Unknown Device")")
        guard let services = peripheral.services else {
            print("\(timestamp): No services discovered for \(peripheral.name ?? "Unknown Device")")
            return
        }
        
        for service in services {
            // Log discovered service
            print("\(timestamp): Discovered service: \(service.uuid)")
            discoveredServices.append(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let timestamp = Date()
        print("\(timestamp): Discovered characteristics for service \(service.uuid) of peripheral \(peripheral.name ?? "Unknown Device")")
        guard let characteristics = service.characteristics else {
            print("\(timestamp): No characteristics discovered for service \(service.uuid) of peripheral \(peripheral.name ?? "Unknown Device")")
            return
        }
        
        for characteristic in characteristics {
            // Log discovered characteristic
            print("\(timestamp): Discovered characteristic: \(characteristic.uuid) for service: \(service.uuid)")
            discoveredCharacteristics[characteristic.uuid] = characteristic
            
            // Enable notifications if the characteristic has notify property
            if characteristic.properties.contains(.notify) {
                print("\(timestamp): Enabling notifications for characteristic: \(characteristic.uuid)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            // Read value if the characteristic has read property
            if characteristic.properties.contains(.read) {
                print("\(timestamp): Reading value for characteristic: \(characteristic.uuid)")
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    // Receive data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let timestamp = Date()
        print("\(timestamp): Updated value for characteristic: \(characteristic.uuid)")
        guard let data = characteristic.value else {
            print("\(timestamp): Characteristic \(characteristic.uuid) has no data")
            return
        }
        
        // Log raw data
        let hexString = data.map { String(format: "%02x", $0) }.joined()
        print("\(timestamp): Received data for \(characteristic.uuid): \(hexString)")
        
        // Store raw data
        var characteristicData = rawDataLog[characteristic.uuid.uuidString] ?? [:]
        characteristicData["lastValue"] = data
        characteristicData["timestamp"] = Date()
        characteristicData["hexString"] = hexString
        rawDataLog[characteristic.uuid.uuidString] = characteristicData
        
        // Attempt to parse based on known characteristics
        parseCharacteristicValue(characteristic, data: data)
    }
    
    // Notification subscription status
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let timestamp = Date()
        if let error = error {
            print("\(timestamp): Error changing notification state for \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            print("\(timestamp): Notification state updated for \(characteristic.uuid). Notifications enabled: \(characteristic.isNotifying)")
        }
    }
    
    // Data parsing logic
    private func parseCharacteristicValue(_ characteristic: CBCharacteristic, data: Data) {
        // Constants for protocol parsing
        let TOKEN_START: UInt8 = 0xFE
        let TYPE_PO_PARAM: UInt8 = 0x55
        let TYPE_PO_WAVE: UInt8 = 0x56
        let LEN_PO_PARAM = 10
        let LEN_PO_WAVE = 8
        
        let timestamp = Date()
        
        // Validate minimum data length and start token
        guard data.count >= 3,
              data[0] == TOKEN_START else {
            print("\(timestamp): Invalid data format or insufficient length")
            return
        }
        
        // Determine message type and length
        let messageType = data[2]
        let messageLength = data[1]
        
        // Validate message type and length
        guard (messageType == TYPE_PO_PARAM && messageLength == LEN_PO_PARAM) ||
              (messageType == TYPE_PO_WAVE && messageLength == LEN_PO_WAVE) else {
            print("\(timestamp): Unrecognized message type or length")
            return
        }
        
        // Parse based on message type
        switch messageType {
        case TYPE_PO_PARAM:
            // Parameter data parsing (pulse rate, SpO2, perfusion index)
            let pulseRateBytes: [UInt8] = [data[4], data[3]]
            let pulseRateRaw = Int16(bytes: pulseRateBytes, endian: .little)
            let spo2Value = data[5]
            
            let piBytes: [UInt8] = [data[7], data[6]]
            let piRaw = Int16(bytes: piBytes, endian: .little)
            let perfusionIndex = Double(piRaw) / 1000.0
            
            // Check for invalid values
            if pulseRateRaw != 511 {
                heartRate = Int(pulseRateRaw)
            }
            
            if spo2Value != 127 {
                spo2 = Double(spo2Value)
            }
            
            print("\(timestamp): PARAM - HR: \(heartRate), SpO2: \(spo2), PI: \(perfusionIndex)")
            
        case TYPE_PO_WAVE:
            // Waveform data parsing
            let ppgValue = data[3]
            let spo2WaveVal = data[5]
            let sensorOff = (data[4] >> 1) & 1 == 1
            
            print("\(timestamp): WAVE - PPG: \(ppgValue), SpO2 Wave: \(spo2WaveVal), Sensor Off: \(sensorOff)")
            
        default:
            print("\(timestamp): Unhandled message type")
        }
    }
    
    // Get discovered data for debug view
    func getDiscoveredServicesInfo() -> String {
        return discoveredServices.map { "Service: \($0.uuid.uuidString)" }.joined(separator: "\n")
    }
    
    func getDiscoveredCharacteristicsInfo() -> String {
        return discoveredCharacteristics.values.map {
            "Characteristic: \($0.uuid.uuidString)\nProperties: \(describeProperties($0.properties))"
        }.joined(separator: "\n")
    }
    
    func getRawDataLog() -> [String: [String: Any]] {
        return rawDataLog
    }
    
    private func describeProperties(_ properties: CBCharacteristicProperties) -> String {
        var descriptions: [String] = []
        
        if properties.contains(.broadcast) { descriptions.append("Broadcast") }
        if properties.contains(.read) { descriptions.append("Read") }
        if properties.contains(.writeWithoutResponse) { descriptions.append("Write Without Response") }
        if properties.contains(.write) { descriptions.append("Write") }
        if properties.contains(.notify) { descriptions.append("Notify") }
        if properties.contains(.indicate) { descriptions.append("Indicate") }
        if properties.contains(.authenticatedSignedWrites) { descriptions.append("Authenticated Signed Writes") }
        
        return descriptions.joined(separator: ", ")
    }
}

// Extension to help with signed short conversion
extension Int16 {
    init(bytes: [UInt8], endian: Endianness = .little) {
        switch endian {
        case .little:
            self = Int16(bytes[1]) << 8 | Int16(bytes[0])
        case .big:
            self = Int16(bytes[0]) << 8 | Int16(bytes[1])
        }
    }
    
    enum Endianness {
        case little
        case big
    }
}
