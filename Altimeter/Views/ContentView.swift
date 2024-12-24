import SwiftUI
import CoreLocation
import CoreMotion

struct ContentView: View {
    @StateObject private var barometricAltimeter = BarometricAltimeter()
    @StateObject private var gpsAltimeter = GPSAltimeter()
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2)
                .ignoresSafeArea()
            
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
                    
                    GPSAltimeterView(altitude: gpsAltimeter.altitude,
                                   accuracy: gpsAltimeter.accuracy,
                                   signalStrength: gpsAltimeter.signalStrength)
                        .frame(width: 150, height: 150)
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
