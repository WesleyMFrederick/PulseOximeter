import SwiftUI

struct ContentView: View {
    
    @ObservedObject var bluetoothManager = BluetoothManager()
    
    var body: some View {
        Text("Bluetooth Status: \(bluetoothManager.bluetoothState.rawValue)")
    }
}
