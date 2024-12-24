import SwiftUI
import CoreLocation
import CoreMotion

struct ContentView: View {
    @StateObject private var altimeterManager = AltimeterManager()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    // 气压计表盘
                    AltimeterDialView(
                        title: "气压高度",
                        altitude: altimeterManager.barometerAltitude,
                        dialStyle: .barometer
                    )
                    
                    // GPS表盘
                    AltimeterDialView(
                        title: "GPS高度",
                        altitude: altimeterManager.gpsAltitude,
                        dialStyle: .gps
                    )
                }
                .padding()
                
                Text(String(format: "海拔: %.1f 米", max(altimeterManager.barometerAltitude, altimeterManager.gpsAltitude)))
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            altimeterManager.startUpdating()
        }
    }
}

class AltimeterManager: ObservableObject {
    private let altimeter = CMAltimeter()
    private let locationManager = CLLocationManager()
    
    @Published var barometerAltitude: Double = 0
    @Published var gpsAltitude: Double = 0
    
    init() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
                guard let data = data, error == nil else { return }
                self?.barometerAltitude = data.relativeAltitude.doubleValue
            }
        }
        
        locationManager.startUpdatingLocation()
    }
}

extension AltimeterManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        gpsAltitude = location.altitude
    }
}

struct AltimeterDialView: View {
    let title: String
    let altitude: Double
    let dialStyle: DialStyle
    
    enum DialStyle {
        case barometer
        case gps
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 150, height: 150)
                
                // 刻度
                ForEach(0..<12) { i in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: i % 3 == 0 ? 15 : 8)
                        .offset(y: -70)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
                
                // 指针
                Rectangle()
                    .fill(dialStyle == .barometer ? Color.red : Color.blue)
                    .frame(width: 2, height: 60)
                    .offset(y: -30)
                    .rotationEffect(.degrees(altitudeToAngle(altitude)))
                
                Circle()
                    .fill(dialStyle == .barometer ? Color.red : Color.blue)
                    .frame(width: 16, height: 16)
            }
            
            Text(String(format: "%.1f m", altitude))
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private func altitudeToAngle(_ altitude: Double) -> Double {
        // 将高度映射到0-360度，每圈代表100米
        return (altitude.truncatingRemainder(dividingBy: 100) / 100) * 360
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
