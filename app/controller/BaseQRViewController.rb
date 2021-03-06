class BaseQRViewController < UIViewController
  extend IB
  outlet :messageLabel, UILabel

  attr_accessor :message_qr

  def viewDidLoad
    super
    self.navigationController.navigationBar.translucent = false
    setup_elements
  end

  def setup_elements
    setup_camera
  end

  def setup_camera
    supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]

    session = AVCaptureSession.alloc.init
    session.sessionPreset = AVCaptureSessionPresetHigh

    device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    error = Pointer.new('@')
    input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: error)

    previewLayer = AVCaptureVideoPreviewLayer.alloc.initWithSession(session)
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill


    previewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
    self.view.layer.insertSublayer(previewLayer, atIndex: 0)

    queue = Dispatch::Queue.new('camQueue')
    output = AVCaptureMetadataOutput.alloc.init
    output.setMetadataObjectsDelegate(self, queue: queue.dispatch_object)

    session.addInput(input)
    session.addOutput(output)
    output.metadataObjectTypes = supportedBarCodes
    session.startRunning
    NSLog("session running: #{session.running?}")
    true    
  end

  def showMessage(message)
    @message_qr = "#{metadataObjects[0].stringValue}"
    messageLabel.text = "#{metadataObjects[0].stringValue}"
    self.navigationController.pushViewController(DetailQRViewController, animated: true)
  end

  #MARK :- DELEGATE
  def captureOutput(captureOutput, didOutputMetadataObjects: metadataObjects, fromConnection: connection)
    Dispatch::Queue.main.async do
      NSLog("#{metadataObjects[0].stringValue}")
      showMessage("#{metadataObjects[0].stringValue}")
      return
    end
  end

  def prepareForSegue(segue, sender: sender)
    segue.destinationViewController.qr_text = @message_qr
  end

end