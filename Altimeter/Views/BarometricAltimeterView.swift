import SwiftUI

struct BarometricAltimeterView: View {
    let altitude: Double
    let referencePressure: Double
    
    // Convert meters to feet
    private var altitudeInFeet: Double {
        altitude * 3.28084
    }
    
    // 三个指针分别表示：
    // 最细最长的三角针：10000英尺
    // 最短最粗的针：1000英尺
    // 中等长度和粗细的针：100英尺
    private var tenThousandPointerAngle: Double {
        (altitudeInFeet * 0.036).truncatingRemainder(dividingBy: 360) // 360°/10000
    }
    
    private var thousandPointerAngle: Double {
        (altitudeInFeet * 0.36).truncatingRemainder(dividingBy: 360) // 360°/1000
    }
    
    private var hundredPointerAngle: Double {
        (altitudeInFeet * 3.6).truncatingRemainder(dividingBy: 360) // 360°/100
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // 气压高度计表盘
            ZStack {
                // 背景
                Circle()
                    .fill(Color(white: 0.1))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                
                // 刻度
                ForEach(0..<100) { i in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: i % 10 == 0 ? 2 : 1,
                              height: i % 10 == 0 ? 15 : 8)
                        .offset(y: -65)
                        .rotationEffect(.degrees(Double(i) * 3.6))
                }
                
                // 数字（每1000英尺一个标记）
                ForEach(0..<10) { i in
                    Text("\(i)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: -50)
                        .rotationEffect(.degrees(Double(i) * 36))
                }
                
                // 100英尺指针（最长）
                AltimeterPointer(width: 1, length: 70, color: .white)
                    .rotationEffect(.degrees(hundredPointerAngle))
                
                // 1000英尺指针（中等）
                AltimeterPointer(width: 2, length: 60, color: .white)
                    .rotationEffect(.degrees(thousandPointerAngle))
                
                // 10000英尺指针（最短）
                AltimeterPointer(width: 3, length: 40, color: .white)
                    .rotationEffect(.degrees(tenThousandPointerAngle))
                
                // 中心点
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                
                // 当前高度显示
                VStack {
                    Text(String(format: "%.1f", altitude))
                        .font(.system(.title2, design: .rounded))
                        .foregroundColor(.white)
                    Text("米")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                }
                .offset(y: 30)
            }
            
            // 气压显示
            HStack {
                Text("气压")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.gray)
                Text(String(format: "%.1f hPa", referencePressure))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

struct AltimeterPointer: View {
    let width: CGFloat
    let length: CGFloat
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length/2)
    }
}

struct KollsmanWindow: View {
    let pressure: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.black)
            .frame(width: 50, height: 20)
            .overlay(
                Text(String(format: "%.1f", pressure))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            )
    }
}

#Preview {
    ZStack {
        Color.black
        BarometricAltimeterView(altitude: 1234.5, referencePressure: 1013.25)
    }
}
