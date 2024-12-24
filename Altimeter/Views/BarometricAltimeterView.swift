import SwiftUI

struct BarometricAltimeterView: View {
    let altitude: Double
    let referencePressure: Double
    
    // 三个指针分别表示：
    // - 长指针：100英尺（约30.48米）
    // - 中指针：1000英尺（约304.8米）
    // - 短指针：10000英尺（约3048米）
    private var hundredsPointerAngle: Double {
        (altitude / 30.48).truncatingRemainder(dividingBy: 1000) * 0.36 // 360/1000
    }
    
    private var thousandsPointerAngle: Double {
        (altitude / 304.8).truncatingRemainder(dividingBy: 100) * 3.6 // 360/100
    }
    
    private var tenThousandsPointerAngle: Double {
        (altitude / 3048).truncatingRemainder(dividingBy: 10) * 36.0 // 360/10
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
            ForEach(0..<100) { i in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: i % 10 == 0 ? 3 : 1,
                           height: i % 10 == 0 ? 15 : 8)
                    .offset(y: -65)
                    .rotationEffect(.degrees(Double(i) * 3.6))
            }
            
            // 数字
            ForEach(0..<10) { i in
                Text("\(i)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: -50)
                    .rotationEffect(.degrees(Double(i) * 36))
            }
            
            // 10000英尺指针（短）
            BarometricPointer(length: 30, width: 4, color: .white)
                .rotationEffect(.degrees(tenThousandsPointerAngle))
            
            // 1000英尺指针（中）
            BarometricPointer(length: 45, width: 3, color: .white)
                .rotationEffect(.degrees(thousandsPointerAngle))
            
            // 100英尺指针（长）
            BarometricPointer(length: 60, width: 2, color: .red)
                .rotationEffect(.degrees(hundredsPointerAngle))
            
            // 中心点
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
            
            // Kollsman窗口
            KollsmanWindow(pressure: referencePressure)
                .offset(x: 40)
        }
        .frame(width: 180, height: 180)
    }
}

struct BarometricPointer: View {
    let length: CGFloat
    let width: CGFloat
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
            .fill(Color(white: 0.15))
            .frame(width: 50, height: 25)
            .overlay(
                Text(String(format: "%.2f", pressure))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
        Color.black
        BarometricAltimeterView(altitude: 1234.5, referencePressure: 1013.25)
    }
}
