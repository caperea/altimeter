import SwiftUI

struct ContentView: View {
    @StateObject private var barometricAltimeter = BarometricAltimeter()
    @StateObject private var gpsAltimeter = GPSAltimeter()
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            VStack {
                Text(String(format: "海拔: %.1f 米", max(barometricAltimeter.altitude, gpsAltimeter.altitude)))
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            gpsAltimeter.requestAuthorization()
            gpsAltimeter.startUpdating()
            barometricAltimeter.startUpdating()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
