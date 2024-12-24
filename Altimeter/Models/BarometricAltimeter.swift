import Foundation
#if os(iOS)
import CoreMotion
#endif

class BarometricAltimeter: ObservableObject {
    #if os(iOS)
    private let altimeter = CMAltimeter()
    #endif
    
    @Published var altitude: Double = 0
    @Published var pressure: Double = 1013.25 // Standard atmospheric pressure in hPa
    
    var isAvailable: Bool {
        #if os(iOS)
        return CMAltimeter.isRelativeAltitudeAvailable()
        #else
        return false
        #endif
    }
    
    func startUpdating() {
        #if os(iOS)
        guard isAvailable else { return }
        
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            self?.altitude = data.relativeAltitude.doubleValue
            self?.pressure = data.pressure.doubleValue / 10 // Convert to hPa
        }
        #else
        // Mock implementation for macOS
        altitude = 0
        pressure = 1013.25
        #endif
    }
    
    func stopUpdating() {
        #if os(iOS)
        altimeter.stopRelativeAltitudeUpdates()
        #endif
    }
    
    // 设置参考气压值
    func setReferencePressure(_ pressure: Double) {
        self.pressure = pressure
    }
    
    // 根据气压计算海拔高度（使用国际民航组织大气模型）
    func calculateAltitude(pressure: Double, referencePressure: Double = 1013.25) -> Double {
        return 44330 * (1 - pow(pressure / referencePressure, 1/5.255))
    }
}
