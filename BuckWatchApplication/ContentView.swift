//
//  ContentView.swift
//  BuckWatch
//
//  Created by Josiah Clark on 6/28/24.
//

import SwiftUI
import RealmSwift
import MapKit
import SceneKit


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
    @State private var showingImagePicker = false
    @State private var showAlert = false
    @State private var showPopup = false
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                }
                if showPopup {
                    PopupView(showPopup: $showPopup)
                        .transition(.move(edge: .bottom))
                }
            }
            .padding()
            .navigationTitle("Dashboard")
            .navigationBarItems(trailing:
                Menu {
                    Button(action: {
                        // Handle Add New Image action
                        withAnimation {
                            showPopup.toggle()
                        }
                    }) {
                        Label("Add New Image", systemImage: "photo")
                    }

                    Button(action: {
                        // Handle Take Picture action
                        showAlert = true
                    }) {
                        Label("Take Picture", systemImage: "camera")
                    }

                    Button(action: {
                        // Handle Add New Trail Camera Location action
                    }) {
                        Label("Add New Trail Camera Location", systemImage: "location")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                }
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Take Picture"),
                    message: Text("This will open the camera to take a picture."),
                    primaryButton: .default(Text("OK"), action: {
                        // Handle camera opening action
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
        .padding()
        .onAppear {
            loadApiKey()
        }
    }
    
    private func loadApiKey() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let key = config["WEATHER_API_KEY"] as? String {
            weatherApiKey = key
        }
        if let path2 = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config2 = NSDictionary(contentsOfFile: path2),
           let key2 = config2["MOON_API_KEY"] as? String {
            moonApiKey = key2
        }
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

struct AnimalType: Identifiable {
    let id = UUID()
    let modelName: String // Name of the 3D model file
    let description: String
}

struct Question: Identifiable {
    let id = UUID()
    let text: String
}


struct PopupView: View {
    @Binding var showPopup: Bool
    @State private var counter = 0
    @State private var currentQuestionIndex = 0
    @State private var answers = [String](repeating: "", count: 5)
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedDate = Date()
    @State private var selectedAnimalTypeIndex = 0
    @State private var imageName: String = ""
    @State private var animalType: String = "Doe"
    @State private var date = Date()
    @State private var stringDate: String = ""
    @State private var time = Date()
    @State private var trailCamera: String = ""
    @State private var trailCameras: [String] = []

    let questions: [Question] = [
        Question(text: "Upload an image"),
        Question(text: "Animal Type"),
        Question(text: "Animal Name"),
        Question(text: "Buck size"),
        Question(text: "Date & Time"),
        // Add more questions as needed
    ]

    let animalTypes: [AnimalType] = [
        AnimalType(modelName: "BuckWatch.usdz", description: "Buck"),
        AnimalType(modelName: "HogWatch.usdz", description: "Hog"),
        AnimalType(modelName: "BuckWatch.usdz", description: "Mouse"),
        AnimalType(modelName: "HogWatch.usdz", description: "Hamster"),
        AnimalType(modelName: "BuckWatch.usdz", description: "Rabbit"),
        AnimalType(modelName: "HogWatch.usdz", description: "Fox"),
        // Add more animal types as needed
    ]

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        withAnimation {
                            showPopup.toggle()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                    }
                    .padding([.top, .leading])
                    Spacer()

                    if currentQuestionIndex < questions.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentQuestionIndex += 1

                                if questions[currentQuestionIndex].text == "Buck size" && animalTypes[selectedAnimalTypeIndex].description != "Buck" {
                                    currentQuestionIndex += 1
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                        .padding([.top, .trailing])
                    }
                }

                Text(questions[currentQuestionIndex].text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                if currentQuestionIndex == 0 {
                    Image(systemName: "photo.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)

                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("Select Image")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $selectedImage)
                    }

                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(10)
                            .padding()
                    }
                } else if currentQuestionIndex == 1 {
                    // Swipe functionality for "Animal Type" question with 3D models
                    VStack {
                        TabView(selection: $selectedAnimalTypeIndex) {
                            ForEach(0..<animalTypes.count) { index in
                                VStack {
                                    Model3DView(modelName: animalTypes[index].modelName)
                                        .frame(width: 200, height: 200)
                                    Text(animalTypes[index].description)
                                        .font(.title)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 300)

                        // Page indicator dots
                        HStack {
                            ForEach(0..<animalTypes.count) { index in
                                Circle()
                                    .fill(index == selectedAnimalTypeIndex ? Color.blue : Color.gray)
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .padding(.top, 10)
                    }
                } else if currentQuestionIndex == 2 {
                    // Animal Name question with SF Symbol
                    VStack {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)

                        TextField("Your answer here...", text: Binding(
                            get: {
                                if answers.indices.contains(currentQuestionIndex) {
                                    return answers[currentQuestionIndex]
                                } else {
                                    return ""
                                }
                            },
                            set: { newValue in
                                if answers.indices.contains(currentQuestionIndex) {
                                    answers[currentQuestionIndex] = newValue
                                } else {
                                    answers.append(newValue)
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                } else if currentQuestionIndex == 3 && animalTypes[selectedAnimalTypeIndex].description == "Buck" {
                    // 3D model with rotation for "Buck size" question
                    VStack {
                        Model3DView(modelName: "BuckWatch.usdz", allowRotation: true)
                            .frame(width: 200, height: 200)

                        Text("Buck size")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 20)

                        HStack {
                            Button(action: {
                                if counter > 0 {
                                    counter -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.red)
                            }

                            Text("\(counter)")
                                .font(.title)
                                .padding(.horizontal, 20)

                            Button(action: {
                                counter += 1
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                } else if currentQuestionIndex == 3 || currentQuestionIndex == 4 {
                    // Date & Time Picker for "Date & Time" question
                    DatePicker("Select Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                } else {
                    TextField("Your answer here...", text: Binding(
                        get: {
                            if answers.indices.contains(currentQuestionIndex) {
                                return answers[currentQuestionIndex]
                            } else {
                                return ""
                            }
                        },
                        set: { newValue in
                            if answers.indices.contains(currentQuestionIndex) {
                                answers[currentQuestionIndex] = newValue
                            } else {
                                answers.append(newValue)
                            }
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }

                if currentQuestionIndex == questions.count - 1 || (currentQuestionIndex == 4 && animalTypes[selectedAnimalTypeIndex].description != "Buck") {
                    Button(action: {
                        saveImageData()
                        withAnimation {
                            showPopup.toggle()
                        }
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .onAppear {
                loadTrailCameras()
            }
        }
    }

    private func printSelections() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedDate)
        let minute = calendar.component(.minute, from: selectedDate)
        let date = calendar.startOfDay(for: selectedDate)
        let dateTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
        let stringDate = formatDateToString(date: dateTime)
        print("dateTime: \(dateTime)")
        print("stringDate: \(stringDate)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: dateTime)

        answers[0] = selectedImage != nil ? "Image Selected" : "No Image"
        answers[1] = animalTypes[selectedAnimalTypeIndex].description
        answers[3] = animalTypes[selectedAnimalTypeIndex].description == "Buck" ? "\(counter)" : ""
        answers[4] = formattedDate

        for (index, answer) in answers.enumerated() {
            print("Question \(index + 1): \(answer)")
        }
    }

    private func saveImageData() {
        guard let image = selectedImage else { return }
        let imageData = image.jpegData(compressionQuality: 1.0)
        let dateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedDate),
            minute: Calendar.current.component(.minute, from: selectedDate),
            second: 0, of: selectedDate)!
        let realm = try! Realm()
        guard let selectedCamera = realm.objects(Camera.self).filter("name == %@", trailCamera).first else {
            print("Camera not found")
            return
        }

        fetchWeatherData(latitude: selectedCamera.latitude, longitude: selectedCamera.longitude, dateTime: dateTime) { weatherData in
            DispatchQueue.main.async {
                if let weatherData = weatherData {
                    // Assuming you want to print the first item in the `data` array for demonstration purposes
                    if let firstWeatherDetail = weatherData.data.first {
                        print("Weather Data for \(self.formattedDate(self.selectedDate)) at \(self.formattedTime(self.selectedDate)):")
                        print("Temperature: \(firstWeatherDetail.temp)°F")
                        print("Feels Like: \(firstWeatherDetail.feelsLike)°F")
                        print("Wind Speed: \(firstWeatherDetail.windSpeed) mph")
                        print("Wind Direction: \(windDirection(degrees: firstWeatherDetail.windDeg))")
                        print("Precipitation: \(firstWeatherDetail.precipitation ?? 0) mm")
                        print("Weather Description: \(firstWeatherDetail.weather.first?.description ?? "N/A")")
                    } else {
                        print("No weather details available")
                    }
                } else {
                    print("Failed to fetch weather data")
                }

                let stringDate = formatDateToString(date: dateTime)
                fetchMoonPhase(latitude: selectedCamera.latitude, longitude: selectedCamera.longitude, date: stringDate) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let moonPhase):
                            // Process and combine weather data with moon phase data
                            print("Moon Phase: \(moonPhase)")
                        case .failure(let error):
                            print("Failed to fetch moon phase data: \(error.localizedDescription)")
                        }

                        // Save to Realm on the main thread
                        let realm = try! Realm()
                        let imageDataObject = ImageData()
                        imageDataObject.imageName = answers[2]
                        imageDataObject.imageData = imageData
                        imageDataObject.animalType = animalTypes[selectedAnimalTypeIndex].description
                        imageDataObject.date = self.selectedDate
                        imageDataObject.time = self.selectedDate
                        imageDataObject.trailCamera = "Slay"
                        do {
                            try realm.write {
                                realm.add(imageDataObject)
                            }
                            print("Image data saved to Realm successfully")
                        } catch {
                            print("Failed to write to Realm: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    private func windDirection(degrees: Int) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N"]
        let index = Int((Double(degrees) / 22.5).rounded()) % 16
        return directions[index]
    }

    private func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
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

    private func loadTrailCameras() {
        let realm = try! Realm()
        let cameras = realm.objects(Camera.self)
        trailCameras = cameras.map { $0.name }
        if let firstCamera = trailCameras.first {
            trailCamera = firstCamera
        }
    }
}



struct Model3DView: UIViewRepresentable {
    var modelName: String
    var allowRotation: Bool = false

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        if let scene = SCNScene(named: modelName) {
            printNodeHierarchy(node: scene.rootNode)
            if allowRotation {
                addRotationAnimation(to: scene.rootNode)
            }
            sceneView.scene = scene
        } else {
            print("Failed to load the scene from \(modelName)")
        }
        sceneView.allowsCameraControl = !allowRotation // Disable rotation for other models
        sceneView.autoenablesDefaultLighting = true
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    private func addRotationAnimation(to node: SCNNode) {
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.fromValue = SCNVector4(0, 0, 1, 0)  // Rotate around the Y-axis
        rotation.toValue = SCNVector4(0, 0, 1, Float.pi * 2)
        rotation.duration = 10
        rotation.repeatCount = .infinity
        node.addAnimation(rotation, forKey: "rotation")
        
        for child in node.childNodes {
            addRotationAnimation(to: child)
        }
    }
    
    private func printNodeHierarchy(node: SCNNode, depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)\(node.name ?? "Unnamed Node")")
        for child in node.childNodes {
            printNodeHierarchy(node: child, depth: depth + 1)
        }
    }
    
    private func scaleModel(node: SCNNode, scale: Float) {
        node.scale = SCNVector3(scale, scale, scale)
        
        for child in node.childNodes {
            scaleModel(node: child, scale: scale)
        }
    }
}
