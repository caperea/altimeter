import SwiftUI
import CoreLocation
import CoreMotion

class AltimeterManager: NSObject, ObservableObject {
    private let altimeter = CMAltimeter()
    private let locationManager = CLLocationManager()
    
    @Published var barometerAltitude: Double = 0
    @Published var gpsAltitude: Double = 0
    @Published var referencePressure: Double = 1013.25 // 标准大气压
    
    private var referenceAltitude: Double = 0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
                guard let data = data, error == nil else { return }
                self?.barometerAltitude = data.relativeAltitude.doubleValue
                // 更新参考气压
                self?.referencePressure = data.pressure.doubleValue / 10 // 转换为百帕
            }
        }
        
        locationManager.startUpdatingLocation()
    }
}

extension AltimeterManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if referenceAltitude == 0 {
            referenceAltitude = location.altitude
        }
        gpsAltitude = location.altitude - referenceAltitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

struct ContentView: View {
    @StateObject private var altimeterManager = AltimeterManager()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                HStack(spacing: 20) {
                    // 气压计表盘
                    BarometricAltimeterView(
                        altitude: altimeterManager.barometerAltitude,
                        referencePressure: altimeterManager.referencePressure
                    )
                    
                    // GPS表盘
                    GPSAltimeterView(
                        altitude: altimeterManager.gpsAltitude
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
