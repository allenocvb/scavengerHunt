//
//  HuntDetailViewController.swift
//  scavenger-hunt2
//
//  Created by Allen Odoom on 3/3/24.
//

import UIKit
import MapKit
import PhotosUI

class HuntDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var hunt: Hunt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.layer.cornerRadius = 12
        
        updateUI()
        updateMapView()
        
        mapView.register(HuntAnnotationView.self, forAnnotationViewWithReuseIdentifier: HuntAnnotationView.identifier)
        
        // Do any additional setup after loading the view.
    }
    
    private func updateUI(){
        titleLabel.text = hunt.title
        descriptionLabel.text = hunt.description
        
        //let color: UIColor = hunt.isComplete ? .systemBlue : .tertiaryLabel
        mapView.isHidden = !hunt.isComplete
    }
    
    
    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            PHPhotoLibrary.requestAuthorization(for: .readWrite){ [weak self] status in
                switch status {
                case .authorized:
                    // The user authorized access to their photo library
                    // show picker (on main thread)
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    // show settings alert (on main thread)
                    DispatchQueue.main.async {
                        // Helper method to show settings alert
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            // Show photo picker
            presentImagePicker()
        }
    }
    
    private func presentImagePicker() {
        // TODO: Create, configure and present image picker.
        // Create a configuration object
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        
        // Set the filter to only images as options (i.e. no videos, etc.).
        config.filter = .images
        
        // Request the original file format. Fastest method as it avoids transcording.
        config.preferredAssetRepresentationMode = .current
        
        // only allow 1 image to be selected at a time.
        config.selectionLimit = 1
        
        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)
        
        // Set the Picker delegate so we can recieve whatever image the user picks
        picker.delegate = self
        
        // Present the picker
        present(picker, animated: true)
    }
    
    func updateMapView() {
        // TODO: Set map viewing region and scale

        // TODO: Add annotation to map view
        
        // Make sure the task has image location.
        guard let imageLocation = hunt.imageLocation else { return }

        
        // Get the coordinate from the image location. This is the latitude/longitude of the location
        let coordinate = imageLocation.coordinate

        
        // Set the map view's region based on the coordinate of the image.
        // The span represents the map's "zoom level". A smaller value yields a more "zoomed in" map area, while a larger value is more "zoomed out".
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        
        // Add an annotation to the map view based on image loctaion
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

extension HuntDetailViewController {

    /// Presents an alert notifying user of photo library access requirement with an option to go to Settings in order to update status.
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    /// Show an alert for the given error
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}

extension HuntDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss the picker
        picker.dismiss(animated: true)
        
        // Get the selected image asset (we can grab the 1st item in the array since we only allowed a selction limit of 1)
        let result = results.first
        
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }
        print("Image location coordinate: \(location.coordinate)")
        
        // Make sure we have a non-nil item provider
        guard let provider = result?.itemProvider,
              // Make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else {return}
        
        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            // Handle any errors
            if let error = error {
                DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
                
            }
            
            // Make sure we can cast the return object to a UIImage
            guard let image = object as? UIImage else {return}
            
            print("We have an image!")
            
            // UI updates should be done on main thread, hence the use of 'DispatchQueue.main.async'
            DispatchQueue.main.async { [weak self] in
                // Set the picked image and location on the task
                self?.hunt.set(image, with: location)
                
                // Update the UI since we've updated the task
                self?.updateUI()
                
                // Update the map view since we now have an image and location
                self?.updateMapView()
            }
        }
    }

    
}

extension HuntDetailViewController: MKMapViewDelegate {
    // Implement mapView(_:viewFor:) delegate method.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Dequeue the annotation view for the specified reuse identifier and annotation.
            // Cast the dequeued annotation view to your specific custom annotation view class, `TaskAnnotationView`
            // 💡 This is very similar to how we get and prepare cells for use in table views.
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: HuntAnnotationView.identifier, for: annotation) as? HuntAnnotationView else {
                fatalError("Unable to dequeue TaskAnnotationView")
            }

            // Configure the annotation view, passing in the task's image.
            annotationView.configure(with: hunt.image)
            return annotationView
    }
}
