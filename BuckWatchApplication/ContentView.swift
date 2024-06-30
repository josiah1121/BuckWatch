//
//  ContentView.swift
//  BuckWatch
//
//  Created by Josiah Clark on 6/28/24.
//

import SwiftUI
import RealmSwift
import MapKit

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ImageUploadView: View {
    @State private var selectedImage: UIImage?
    @State private var imageName: String = ""
    @State private var animalType: String = "Doe"
    @State private var date = Date()
    @State private var time = Date()
    @State private var trailCamera: String = ""
    @State private var showingImagePicker = false
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var showingAnimalPicker = false
    @State private var showingTrailCameraPicker = false
    @State private var trailCameras: [String] = []

    let animalTypes = ["Doe", "Buck", "Turkey", "Hog"]

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 200, height: 200)
            }

            Button("Select Image") {
                showingImagePicker = true
            }
            .padding()
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }

            DisclosureGroup(isExpanded: $showingAnimalPicker) {
                Picker("Select Animal Type", selection: $animalType) {
                    ForEach(animalTypes, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
            } label: {
                Text("Animal Type: \(animalType)")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            DisclosureGroup(isExpanded: $showingDatePicker) {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
            } label: {
                Text("Select Date: \(formattedDate(date))")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            DisclosureGroup(isExpanded: $showingTimePicker) {
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
            } label: {
                Text("Select Time: \(formattedTime(time))")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            DisclosureGroup(isExpanded: $showingTrailCameraPicker) {
                Picker("Select Trail Camera", selection: $trailCamera) {
                    ForEach(trailCameras, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
            } label: {
                Text("Trail Camera: \(trailCamera)")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)

            Button("Save") {
                saveImageData()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .onAppear(perform: loadTrailCameras)
    }

    private func loadTrailCameras() {
        let realm = try! Realm()
        let cameras = realm.objects(Camera.self)
        trailCameras = cameras.map { $0.name }
        if let firstCamera = trailCameras.first {
                   trailCamera = firstCamera
        }
    }

    private func saveImageData() {
        guard let image = selectedImage else { return }
        let imageData = image.jpegData(compressionQuality: 1.0)

        let realm = try! Realm()
        let imageDataObject = ImageData()
        imageDataObject.imageName = imageName
        imageDataObject.imageData = imageData
        imageDataObject.animalType = animalType
        imageDataObject.date = date
        imageDataObject.time = time
        imageDataObject.trailCamera = trailCamera

        try! realm.write {
            realm.add(imageDataObject)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

struct ImageUploadView_Previews: PreviewProvider {
    static var previews: some View {
        ImageUploadView()
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct ImageListView: View {
    @StateObject private var imageDataStore = ImageDataStore()
    
    var body: some View {
        List {
            ForEach(imageDataStore.images, id: \.id) { image in
                VStack(alignment: .leading) {
                    if let imageData = image.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                    Text(image.animalType)
                        .font(.headline)
                    Text("Date: \(formattedDate(image.date))")
                        .font(.headline)
                    Text("Time: \(formattedTime(image.time))")
                        .font(.subheadline)
                    Text(image.trailCamera)
                        .font(.subheadline)
                }
            }
        }
    }
    private func formattedDate(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           return formatter.string(from: date)
       }
       
       private func formattedTime(_ time: Date) -> String {
           let formatter = DateFormatter()
           formatter.timeStyle = .short
           return formatter.string(from: time)
       }
}

class ImageDataStore: ObservableObject {
    @Published var images: [ImageData] = []
    private var realm: Realm

    init() {
        realm = try! Realm()
        fetchImages()
        printRealmDatabasePath()
    }

    private func fetchImages() {
        let results = realm.objects(ImageData.self)
        images = Array(results)
    }
    
    private func printRealmDatabasePath() {
           if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {
               print("Realm database file path: \(fileURL.path)")
           } else {
               print("Could not find Realm database file path.")
           }
       }
}

struct ImageListView_Previews: PreviewProvider {
    static var previews: some View {
        ImageListView()
    }
}

