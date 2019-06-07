# Inception with CoreML

This is the **Inception-v3** neural network running on the shiny new CoreML framework. It uses **Inceptionv3.mlmodel** from [Apple's developer website](https://docs-assets.developer.apple.com/coreml/models/Inceptionv3.mlmodel).

It runs from a live video feed and performs a prediction as often as it can manage. If your device becomes too hot, change the `setUpCamera()` method in **ViewController.swift** to do `videoCapture.fps = 5`.

To use this app, open **Inception.xcodeproj** in Xcode 9 and run it on a device with iOS 11.

![Screenshot](Screenshot.png)

NOTE: The reported "elapsed" time is how long it takes the Inception-v3 neural net to process a single image. The FPS is the actual throughput achieved by the app.
