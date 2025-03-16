import CoreBluetooth
import Combine

class BluetoothManager: NSObject, CBCentralManagerDelegate, ObservableObject {
    
    @Published private var centralManager: CBCentralManager!
    @Published var bluetoothState: CBManagerState = .unknown
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
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
        print("Discovered \(peripheral.name ?? "Unknown Device")")
    }
    
    func scanForDevices() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}
