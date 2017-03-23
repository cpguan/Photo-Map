//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        // Do any additional setup after loading the view.
        let sfRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(sfRegion, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presentCamera(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ?
            .camera : .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Do something with the images (based on your use case)
        self.image = image
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true) { 
            self.performSegue(withIdentifier: "tagSegue", sender: nil)
        }
    }

    func locationsPickedLocation(_ locationsViewController: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        //let annotation = MKPointAnnotation()
        //annotation.title = "Picture!"
        let annotation = PhotoAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        annotation.photo = image
        self.mapView.addAnnotation(annotation)
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(50), height: CGFloat(50)))
        }
        let imageView = annotationView!.leftCalloutAccessoryView as! UIImageView
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = .scaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.image = thumbnail
        
        let detailButton = UIButton(type: .detailDisclosure)
        annotationView!.rightCalloutAccessoryView = detailButton
        annotationView!.image = imageView.image
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! PhotoAnnotation
        image = annotation.photo
        self.performSegue(withIdentifier: "fullImageSegue", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "tagSegue" {
            let vc = segue.destination as! LocationsViewController
            vc.delegate = self
        } else if segue.identifier == "fullImageSegue" {
            let vc = segue.destination as! FullImageViewController
            vc.photo = image
        }
        
    }
    

}
