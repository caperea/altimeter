import SwiftUI

struct GPSAltimeterView: View {
    let altitude: Double
    let accuracy: Double
    let signalStrength: Int
    
    private var altitudeAngle: Double {
        // 每10米一圈
        (altitude.truncatingRemainder(dividingBy: 10) / 10) * 360
    }
    
    private var displayAltitude: Double {
        // 确保高度为正数
        max(altitude, 0)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // GPS信号强度指示器
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                ForEach(0..<4) { index in
                    Rectangle()
                        .fill(index < signalStrength ? Color.green : Color.gray)
                        .frame(width: 10, height: CGFloat(index + 1) * 5)
                }
            }
            .foregroundColor(.white)
            
            // 高度计表盘
            ZStack {
                // 背景表盘
                Circle()
                    .fill(Color(white: 0.1))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                
                // 刻度（每1米一个刻度，每5米一个大刻度）
                ForEach(0..<50) { i in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: i % 5 == 0 ? 2 : 1,
                               height: i % 5 == 0 ? 15 : 8)
                        .offset(y: -65)
                        .rotationEffect(.degrees(Double(i) * 7.2))
                }
                
                // 数字（每1米一个标记）
                ForEach(0..<10) { i in
                    Text("\(i)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: -50)
                        .rotationEffect(.degrees(Double(i) * 36))
                }
                
                // GPS指针
                GPSPointer(color: .red)
                    .rotationEffect(.degrees(altitudeAngle))
                
                // 中心点
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                
                // 数字显示
                VStack {
                    Text(String(format: "%.1f", displayAltitude))
                        .font(.system(.title2, design: .rounded))
                        .foregroundColor(.white)
                    Text("m")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                }
                .offset(y: 30)
            }
            .frame(width: 180, height: 180)
            
            // GPS精度显示
            HStack {
                Text("精度")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.gray)
                Text(String(format: "±%.1fm", accuracy))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

struct GPSPointer: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // 指针主体
            Rectangle()
                .fill(color)
                .frame(width: 2, height: 70)
                .offset(y: -35)
            
            // 指针尾部
            Rectangle()
                .fill(color)
                .frame(width: 2, height: 20)
                .offset(y: 10)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        GPSAltimeterView(altitude: 1234.5, accuracy: 5.0, signalStrength: 3)
    }
}
