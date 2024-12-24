import Foundation
import CoreLocation

class GPSAltimeter: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var altitude: Double = 0
    @Published var accuracy: Double = 0
    @Published var signalStrength: Int = 0 // 0-4, 0表示无信号
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0.1 // 0.1米更新一次
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 直接使用海拔高度
        altitude = location.altitude
        
        // 更新精度
        accuracy = location.verticalAccuracy
        
        // 更新信号强度（基于水平精度）
        let horizontalAccuracy = location.horizontalAccuracy
        switch horizontalAccuracy {
        case ...5: // 非常精确
            signalStrength = 4
        case 5..<10:
            signalStrength = 3
        case 10..<15:
            signalStrength = 2
        case 15..<20:
            signalStrength = 1
        default:
            signalStrength = 0
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        signalStrength = 0
    }
}
