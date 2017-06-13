import UIKit
import Vision
import CoreMedia

class ViewController: UIViewController {
  @IBOutlet weak var videoPreview: UIView!
  @IBOutlet weak var predictionLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  let model = Inceptionv3()

  var videoCapture: VideoCapture!
  var request: VNCoreMLRequest!
  var startTime: CFTimeInterval = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    predictionLabel.text = ""
    timeLabel.text = ""

    setUpVision()
    setUpCamera()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print(#function)
  }

  // MARK: - Initialization

  func setUpCamera() {
    videoCapture = VideoCapture()
    videoCapture.delegate = self
    videoCapture.fps = 10
    videoCapture.setUp { success in
      if success {
        // Add the video preview into the UI.
        if let previewLayer = self.videoCapture.previewLayer {
          self.videoPreview.layer.addSublayer(previewLayer)
          self.resizePreviewLayer()
        }
        self.videoCapture.start()
      }
    }
  }

  func setUpVision() {
    guard let visionModel = try? VNCoreMLModel(for: model.model) else {
      print("Error: could not create Vision model")
      return
    }

    request = VNCoreMLRequest(model: visionModel, completionHandler: requestDidComplete)
    request.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop
  }

  // MARK: - UI stuff

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    resizePreviewLayer()
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  func resizePreviewLayer() {
    videoCapture.previewLayer?.frame = videoPreview.bounds
  }

  // MARK: - Doing inference

  typealias Prediction = (String, Double)

  func predict(pixelBuffer: CVPixelBuffer) {
    // Measure how long it takes to predict a single video frame.
    startTime = CACurrentMediaTime()

    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
    try? handler.perform([request])
  }

  func requestDidComplete(request: VNRequest, error: Error?) {
    if let observations = request.results as? [VNClassificationObservation] {

      // The observations appear to be sorted by confidence already, so we
      // take the top 5 and map them to an array of (String, Double) tuples.
      let top5 = observations.prefix(through: 4)
                             .map { ($0.identifier, Double($0.confidence)) }

      DispatchQueue.main.async {
        self.show(results: top5)
      }
    }
  }

  func show(results: [Prediction]) {
    var s: [String] = []
    for (i, pred) in results.enumerated() {
      s.append(String(format: "%d: %@ (%3.2f%%)", i + 1, pred.0, pred.1 * 100))
    }
    predictionLabel.text = s.joined(separator: "\n\n")

    let elapsed = CACurrentMediaTime() - startTime
    timeLabel.text = String(format: "Elapsed %.5f seconds (%.2f FPS)", elapsed, 1/elapsed)
  }
}

extension ViewController: VideoCaptureDelegate {
  func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
    if let pixelBuffer = pixelBuffer {
      // Perform the prediction on VideoCapture's queue.
      predict(pixelBuffer: pixelBuffer)
    }
  }
}
