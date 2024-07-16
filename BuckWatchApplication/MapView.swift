//
//  MapView.swift
//  BuckWatch
//
//  Created by Josiah Clark on 6/28/24.
//
import SwiftUI
import MapKit
import RealmSwift
import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}

struct CameraNamePopup: View {
    @Binding var cameraName: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            Text("New Camera")
                .font(.headline)
                .padding()

            TextField("Enter camera name", text: $cameraName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding()

            HStack {
                Button(action: onSave) {
                    Text("Save")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Button(action: onCancel) {
                    Text("Cancel")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .padding()
    }
}

struct CameraInfoPopup: View {
    var cameraName: String
    var coordinate: CLLocationCoordinate2D
    var totalPictures: Int
    var doeCount: Int
    var buckCount: Int
    var hogCount: Int
    var turkeyCount: Int
    var onDismiss: () -> Void

    var body: some View {
        VStack {
            Text("Camera Info")
                .font(.headline)
                .padding()

            Text("Name: \(cameraName)")
            Text("Coordinates: \(coordinate.latitude), \(coordinate.longitude)")
            Text("Total Pictures: \(totalPictures)")
            Text("Doe Count: \(doeCount)")
            Text("Buck Count: \(buckCount)")
            Text("Hog Count: \(hogCount)")
            Text("Turkey Count: \(turkeyCount)")

            Button("Dismiss") {
                onDismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct IdentifiablePointAnnotation: Identifiable {
    let id = UUID()
    let annotation: MKPointAnnotation
}

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pins: [IdentifiablePointAnnotation]
    @Binding var showingCameraNamePopup: Bool
    @Binding var showingCameraInfoPopup: Bool
    @Binding var cameraName: String
    @Binding var lastPin: MKPointAnnotation?
    @Binding var mapType: MKMapType
    @Binding var selectedCameraInfo: CameraInfo?

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(parent: MapViewRepresentable) {
            self.parent = parent
        }

        @objc func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            if !mapView.annotations.contains(where: { annotation in
                let point = mapView.convert(annotation.coordinate, toPointTo: mapView)
                return point.distance(to: location) < 22 // Hit test radius
            }) {
                let newPin = MKPointAnnotation()
                newPin.coordinate = coordinate
                self.parent.lastPin = newPin // Save reference to the last pin
                self.parent.showingCameraNamePopup = true
            }
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation,
                  let title = annotation.title else { return }
            let realm = try! Realm()
            guard let camera = realm.objects(Camera.self).filter("name == %@", title).first else { return }

            let totalPictures = realm.objects(ImageData.self).filter("trailCamera == %@", camera.name).count
            let doeCount = realm.objects(ImageData.self).filter("trailCamera == %@ AND animalType == %@", camera.name, "Doe").count
            let buckCount = realm.objects(ImageData.self).filter("trailCamera == %@ AND animalType == %@", camera.name, "Buck").count
            let hogCount = realm.objects(ImageData.self).filter("trailCamera == %@ AND animalType == %@", camera.name, "Hog").count
            let turkeyCount = realm.objects(ImageData.self).filter("trailCamera == %@ AND animalType == %@", camera.name, "Turkey").count

            self.parent.selectedCameraInfo = CameraInfo(
                name: camera.name,
                coordinate: CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude),
                totalPictures: totalPictures,
                doeCount: doeCount,
                buckCount: buckCount,
                hogCount: hogCount,
                turkeyCount: turkeyCount
            )
            self.parent.showingCameraInfoPopup = true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.mapType = mapType
        uiView.removeAnnotations(uiView.annotations)
        let annotations = pins.map { $0.annotation }
        uiView.addAnnotations(annotations)
    }
}

struct CameraInfo {
    var name: String
    var coordinate: CLLocationCoordinate2D
    var totalPictures: Int
    var doeCount: Int
    var buckCount: Int
    var hogCount: Int
    var turkeyCount: Int
}



struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var pins: [IdentifiablePointAnnotation] = []
    @State private var selectedCamera: String = "Camera1"
    @State private var showingCameraNamePopup = false
    @State private var showingCameraInfoPopup = false
    @State private var cameraName = ""
    @State private var lastPin: MKPointAnnotation?
    @State private var mapType: MKMapType = .standard
    @State private var selectedCameraInfo: CameraInfo?

    var body: some View {
        VStack {
            Picker("Map Type", selection: $mapType) {
                Text("Standard").tag(MKMapType.standard)
                Text("Satellite").tag(MKMapType.satellite)
                Text("Hybrid").tag(MKMapType.hybrid)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            MapViewRepresentable(
                region: $region,
                pins: $pins,
                showingCameraNamePopup: $showingCameraNamePopup,
                showingCameraInfoPopup: $showingCameraInfoPopup,
                cameraName: $cameraName,
                lastPin: $lastPin,
                mapType: $mapType,
                selectedCameraInfo: $selectedCameraInfo
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                loadPinsFromRealm()
            }
            .sheet(isPresented: $showingCameraNamePopup) {
                CameraNamePopup(cameraName: $cameraName, onSave: {
                    if let lastPin = lastPin {
                        let identifiablePin = IdentifiablePointAnnotation(annotation: lastPin)
                        pins.append(identifiablePin)
                        savePin(lastPin)
                    }
                    showingCameraNamePopup = false
                }, onCancel: {
                    lastPin = nil
                    showingCameraNamePopup = false
                })
            }

            if showingCameraInfoPopup, let cameraInfo = selectedCameraInfo {
                CameraInfoPopup(
                    cameraName: cameraInfo.name,
                    coordinate: cameraInfo.coordinate,
                    totalPictures: cameraInfo.totalPictures,
                    doeCount: cameraInfo.doeCount,
                    buckCount: cameraInfo.buckCount,
                    hogCount: cameraInfo.hogCount,
                    turkeyCount: cameraInfo.turkeyCount,
                    onDismiss: {
                        showingCameraInfoPopup = false
                    }
                )
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 10)
                .padding()
            }
        }
    }

    private func savePin(_ pin: MKPointAnnotation) {
        let realm = try! Realm()
        let camera = Camera()
        camera.name = cameraName
        camera.latitude = pin.coordinate.latitude
        camera.longitude = pin.coordinate.longitude
        
        try! realm.write {
            realm.add(camera)
        }
        cameraName = "" // Reset the camera name for the next input
    }

    private func loadPinsFromRealm() {
        let realm = try! Realm()
        let cameras = realm.objects(Camera.self)
        for camera in cameras {
            let newPin = MKPointAnnotation()
            newPin.coordinate = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
            newPin.title = camera.name
            let identifiablePin = IdentifiablePointAnnotation(annotation: newPin)
            pins.append(identifiablePin)
        }
    }
}


struct MapView2: View {
    @Binding var region: MKCoordinateRegion
    @Binding var pins: [IdentifiablePointAnnotation]
    @Binding var showingCameraNamePopup: Bool
    @Binding var showingCameraInfoPopup: Bool
    @Binding var cameraName: String
    @Binding var lastPin: MKPointAnnotation?
    @Binding var mapType: MKMapType
    @Binding var selectedCameraInfo: CameraInfo?
    var onCameraSelected: (Camera) -> Void

    var body: some View {
        VStack {
            Picker("Map Type", selection: $mapType) {
                Text("Standard").tag(MKMapType.standard)
                Text("Satellite").tag(MKMapType.satellite)
                Text("Hybrid").tag(MKMapType.hybrid)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            MapViewRepresentable2(
                region: $region,
                pins: $pins,
                showingCameraNamePopup: $showingCameraNamePopup,
                showingCameraInfoPopup: $showingCameraInfoPopup,
                cameraName: $cameraName,
                lastPin: $lastPin,
                mapType: $mapType,
                selectedCameraInfo: $selectedCameraInfo,
                onCameraSelected: onCameraSelected
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                loadPinsFromRealm()
            }
        }
    }

    private func loadPinsFromRealm() {
        let realm = try! Realm()
        let cameras = realm.objects(Camera.self)
        for camera in cameras {
            let newPin = MKPointAnnotation()
            newPin.coordinate = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
            newPin.title = camera.name
            let identifiablePin = IdentifiablePointAnnotation(annotation: newPin)
            pins.append(identifiablePin)
        }
    }
}

struct MapViewRepresentable2: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pins: [IdentifiablePointAnnotation]
    @Binding var showingCameraNamePopup: Bool
    @Binding var showingCameraInfoPopup: Bool
    @Binding var cameraName: String
    @Binding var lastPin: MKPointAnnotation?
    @Binding var mapType: MKMapType
    @Binding var selectedCameraInfo: CameraInfo?
    var onCameraSelected: (Camera) -> Void

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable2

        init(parent: MapViewRepresentable2) {
            self.parent = parent
        }

        @objc func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            if !mapView.annotations.contains(where: { annotation in
                let point = mapView.convert(annotation.coordinate, toPointTo: mapView)
                return point.distance(to: location) < 22 // Hit test radius
            }) {
                let newPin = MKPointAnnotation()
                newPin.coordinate = coordinate
                self.parent.lastPin = newPin // Save reference to the last pin
                self.parent.showingCameraNamePopup = true
            }
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation,
                  let title = annotation.title else { return }
            let realm = try! Realm()
            guard let camera = realm.objects(Camera.self).filter("name == %@", title).first else { return }

            let totalPictures = realm.objects(ImageData.self).filter("trailCamera == %@", camera.name).count
            let doeCount = realm.objects(ImageData.self).filter("trailCamera == %@ AND animalType == %@", camera.name, "Doe").count
            let buckCount = realm.objects(ImageData.self).filter("trailCamera == %@ AND animalType == %@", camera.name, "Buck").count
            let hogCount = realm.objects(ImageData.self).filter("trailCamera == %@ AND animalType == %@", camera.name, "Hog").count
            let turkeyCount = realm.objects(ImageData.self).filter("trailCamera == %@ AND animalType == %@", camera.name, "Turkey").count

            self.parent.selectedCameraInfo = CameraInfo(
                name: camera.name,
                coordinate: CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude),
                totalPictures: totalPictures,
                doeCount: doeCount,
                buckCount: buckCount,
                hogCount: hogCount,
                turkeyCount: turkeyCount
            )
            self.parent.showingCameraInfoPopup = true
            self.parent.onCameraSelected(camera)  // Notify the parent view of the selected camera
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.mapType = mapType
        uiView.removeAnnotations(uiView.annotations)
        let annotations = pins.map { $0.annotation }
        uiView.addAnnotations(annotations)
    }
}


struct MapView3: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pins: [IdentifiablePointAnnotation3]
    @Binding var selectedCamera: Camera?

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView3

        init(parent: MapView3) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "camera"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.titleVisibility = .visible
            return annotationView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = .satellite
        mapView.delegate = context.coordinator
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(pins.map { $0.annotation })
    }
}

struct IdentifiablePointAnnotation3: Identifiable {
    let id = UUID()
    let annotation: MKPointAnnotation
}
