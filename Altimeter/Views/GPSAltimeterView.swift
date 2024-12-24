import SwiftUI

struct GPSAltimeterView: View {
    let altitude: Double
    
    private var altitudeAngle: Double {
        // 每圈代表100米
        (altitude.truncatingRemainder(dividingBy: 100) / 100) * 360
    }
    
    var body: some View {
        ZStack {
            // 背景表盘
            Circle()
                .fill(Color(white: 0.1))
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            
            // 刻度
            ForEach(0..<50) { i in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: i % 5 == 0 ? 2 : 1,
                           height: i % 5 == 0 ? 15 : 8)
                    .offset(y: -65)
                    .rotationEffect(.degrees(Double(i) * 7.2))
            }
            
            // 数字（每20米一个标记）
            ForEach(0..<5) { i in
                Text("\(i * 20)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: -50)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            
            // GPS指针
            GPSPointer(color: .blue)
                .rotationEffect(.degrees(altitudeAngle))
            
            // 中心点
            Circle()
                .fill(Color.blue)
                .frame(width: 12, height: 12)
            
            // 数字显示
            Text(String(format: "%.1f m", altitude))
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
                .offset(y: 30)
        }
        .frame(width: 180, height: 180)
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
        GPSAltimeterView(altitude: 1234.5)
    }
}
