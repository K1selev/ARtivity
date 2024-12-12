import UIKit

class WaveformView: UIView {
  
  private var samples: [Float] = []
  
  func addSample(value: Float) {
      samples.append(value)
      if samples.count > Int(bounds.width) { // Лимит по ширине графика
          samples.removeFirst()
      }
      setNeedsDisplay()
  }
    func clear() {
        samples.removeAll()  // Очищаем все данные
        setNeedsDisplay()    // Перерисовываем пустой график
    }
  
  override func draw(_ rect: CGRect) {
      guard let context = UIGraphicsGetCurrentContext() else { return }
      context.clear(rect)
      
      let middleY = rect.height / 2
      let maxAmplitude: CGFloat = middleY - 4.0 // Максимальная высота волны
      
      let path = UIBezierPath()
      path.lineWidth = 2.0
      UIColor(named: "mainGreen")?.setStroke()
      
      for (x, sample) in samples.enumerated() {
          let normalizedSample = CGFloat(sample + 50) / 50 // Нормализация значения
          let amplitude = maxAmplitude * normalizedSample
          let y = middleY - amplitude / 2
          path.move(to: CGPoint(x: CGFloat(x), y: y))
          path.addLine(to: CGPoint(x: CGFloat(x), y: y + amplitude))
      }
      
      path.stroke()
  }
}
