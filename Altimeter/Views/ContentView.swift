import SwiftUI
import CoreLocation
#if os(iOS)
import CoreMotion
#endif

@available(macOS 10.15, *)
struct ContentView: View {
    @StateObject private var barometricAltimeter = BarometricAltimeter()
    @StateObject private var gpsAltimeter = GPSAltimeter()
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // GPS信号强度指示器
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    ForEach(0..<4) { index in
                        Rectangle()
                            .fill(index < gpsAltimeter.signalStrength ? Color.green : Color.gray)
                            .frame(width: 10, height: CGFloat(index + 1) * 5)
                    }
                }
                .foregroundColor(.white)
                
                // 高度计表盘
                HStack(spacing: 20) {
                    VStack {
                        Text("气压高度")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                        
                        BarometricAltimeterView(altitude: barometricAltimeter.altitude,
                                              referencePressure: barometricAltimeter.pressure)
                            .frame(width: 150, height: 150)
                    }
                    
                    VStack {
                        Text("GPS高度")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                        
                        GPSAltimeterView(altitude: gpsAltimeter.altitude)
                            .frame(width: 150, height: 150)
                    }
                }
                
                // 数据显示
                HStack(spacing: 30) {
                    VStack {
                        Text("气压")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.gray)
                        Text("\(barometricAltimeter.pressure, specifier: "%.1f")")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                        Text("hPa")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("GPS精度")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.gray)
                        Text("\(gpsAltimeter.accuracy, specifier: "%.1f")")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                        Text("米")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            gpsAltimeter.requestAuthorization()
            gpsAltimeter.startUpdating()
            barometricAltimeter.startUpdating()
        }
        .onDisappear {
            gpsAltimeter.stopUpdating()
            barometricAltimeter.stopUpdating()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
