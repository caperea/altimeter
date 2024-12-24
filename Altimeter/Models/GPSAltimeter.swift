import Foundation
import CoreLocation

class GPSAltimeter: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var referenceAltitude: Double = 0
    
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
        locationManager.distanceFilter = 1.0 // 1米更新一次
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
        
        // 设置初始参考高度
        if referenceAltitude == 0 {
            referenceAltitude = location.altitude
        }
        
        // 更新相对高度
        altitude = location.altitude - referenceAltitude
        
        // 更新精度
        accuracy = location.verticalAccuracy
        
        // 更新信号强度（基于水平精度）
        updateSignalStrength(horizontalAccuracy: location.horizontalAccuracy)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("GPS error: \(error.localizedDescription)")
        signalStrength = 0
    }
    
    private func updateSignalStrength(horizontalAccuracy: Double) {
        // 基于水平精度估算信号强度
        switch horizontalAccuracy {
        case ...5: // 非常精确
            signalStrength = 4
        case 5...10:
            signalStrength = 3
        case 10...30:
            signalStrength = 2
        case 30...100:
            signalStrength = 1
        default:
            signalStrength = 0
        }
    }
    
    // 重置参考高度
    func resetReferenceAltitude() {
        referenceAltitude = 0
    }
}
