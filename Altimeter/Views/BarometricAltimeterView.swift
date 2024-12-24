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
        ZStack {
            // 背景表盘
            Circle()
                .fill(Color(white: 0.1))
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            
            // 10000英尺标志（黑白条纹扇形）
            if altitudeInFeet < 10000 {
                StripedArcShape(startAngle: -60, endAngle: 60, stripeCount: 12)
                    .fill(Color.white)
                    .frame(width: 160, height: 160)
                    .offset(y: -20)
            }
            
            // 刻度
            ForEach(0..<36) { i in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: i % 3 == 0 ? 2 : 1,
                           height: i % 3 == 0 ? 15 : 10)
                    .offset(y: -90)
                    .rotationEffect(.degrees(Double(i) * 10))
            }
            
            // 数字 (0-9，每个数字代表1000英尺)
            ForEach(0..<10) { i in
                Text("\(i)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: -75)
                    .rotationEffect(.degrees(Double(i) * 36))
            }
            
            // 10000英尺指针（最细最长，带三角形）
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 85)
                Triangle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
            }
            .rotationEffect(.degrees(tenThousandPointerAngle))
            
            // 1000英尺指针（最短最粗）
            Rectangle()
                .fill(Color.white)
                .frame(width: 3, height: 60)
                .rotationEffect(.degrees(thousandPointerAngle))
            
            // 100英尺指针（中等长度和粗细）
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: 75)
                .rotationEffect(.degrees(hundredPointerAngle))
            
            // 中心帽
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
            
            // Kollsman窗口
            KollsmanWindow(pressure: referencePressure)
                .offset(x: 60)
        }
        .frame(width: 200, height: 200)
    }
}

struct StripedArcShape: Shape {
    let startAngle: Double
    let endAngle: Double
    let stripeCount: Int
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let stripeAngle = (endAngle - startAngle) / Double(stripeCount)
        
        var path = Path()
        
        for i in 0..<stripeCount {
            if i % 2 == 0 { // 只绘制偶数条纹
                let start = startAngle + Double(i) * stripeAngle
                let end = start + stripeAngle
                
                path.move(to: center)
                path.addArc(center: center,
                           radius: radius,
                           startAngle: .degrees(start),
                           endAngle: .degrees(end),
                           clockwise: false)
                path.closeSubpath()
            }
        }
        
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
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
