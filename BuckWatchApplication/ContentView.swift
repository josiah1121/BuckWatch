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


struct DashboardView: View {
    @ObservedObject var imageDataStore: ImageDataStore
    
    var body: some View {
        VStack(spacing: 20) {
            // Dashboard Title
            Text("Wildlife Photo Stats")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            // Total Images Taken
            HStack {
                Image(systemName: "photo.on.rectangle")
                    .foregroundColor(.blue)
                    .font(.title)
                Text("Total Images Taken:")
                    .font(.headline)
                Spacer()
                Text("\(imageDataStore.totalImages)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Different Animal Types
            HStack {
                Image(systemName: "pawprint.fill")
                    .foregroundColor(.green)
                    .font(.title)
                Text("Different Animal Types:")
                    .font(.headline)
                Spacer()
                Text("\(imageDataStore.differentAnimalTypes.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Average Temperature
            HStack {
                Image(systemName: "thermometer")
                    .foregroundColor(.red)
                    .font(.title)
                Text("Average Temperature:")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f °F", imageDataStore.averageTemperature))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Average Feels Like
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.orange)
                    .font(.title)
                Text("Average Feels Like:")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f °F", imageDataStore.averageFeelsLike))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
        .navigationTitle("Dashboard")
    }
}

struct DashboardView2: View {
    @ObservedObject var imageDataStore: ImageDataStore
    
    var body: some View {
        VStack(spacing: 20) {
            // Weather Information
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "cloud.rain.fill")
                            .foregroundColor(.blue)
                        Text("Temp")
                        Spacer()
                        Text("95°F")
                            .fontWeight(.bold)
                    }
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        Text("Precip.")
                        Spacer()
                        Text("17%")
                            .fontWeight(.bold)
                    }
                    HStack {
                        Image(systemName: "sunrise.fill")
                            .foregroundColor(.yellow)
                        Text("Sunrise")
                        Spacer()
                        Text("5:24 AM")
                            .fontWeight(.bold)
                    }
                    HStack {
                        Image(systemName: "sunset.fill")
                            .foregroundColor(.orange)
                        Text("Sunset")
                        Spacer()
                        Text("7:33 PM")
                            .fontWeight(.bold)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}



struct ImageUploadView: View {
    @StateObject private var imageDataStore = ImageDataStore()
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showAlert = false
    @State private var showPopup = false
    @State private var currentAnimal: ImageData?
    @State private var currentIndex = 0
    @State private var uniqueAnimals: [ImageData] = []
    @State private var animalsByCurrentName: [ImageData] = []
    @State private var selectedTab = "Image"
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var mapPins: [IdentifiablePointAnnotation] = []
    @State private var mapPins2: [IdentifiablePointAnnotation3] = []
    @State private var selectedCamera: Camera?

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Image("Antlers")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(currentAnimal?.imageName ?? "Loading...")
                                .font(.system(size: 20, weight: .bold))
                                .fontWeight(.bold)
                            HStack {
                                Text("Image")
                                    .onTapGesture {
                                        selectedTab = "Image"
                                    }
                                    .font(.headline)
                                    .foregroundColor(selectedTab == "Image" ? .blue : .primary)
                                Spacer()
                                Text("Location")
                                    .onTapGesture {
                                        selectedTab = "Location"
                                    }
                                    .font(.headline)
                                    .foregroundColor(selectedTab == "Location" ? .blue : .primary)
                                Spacer()
                                Text("Harvest")
                                    .onTapGesture {
                                        selectedTab = "Harvest"
                                    }
                                    .font(.headline)
                                    .foregroundColor(selectedTab == "Harvest" ? .blue : .primary)
                            }
                        }
                        Spacer()
                        Menu {
                            ForEach(uniqueAnimals.indices, id: \.self) { index in
                                Button(action: {
                                    updateViewWithAnimal(at: index)
                                }) {
                                    Text(uniqueAnimals[index].imageName)
                                }
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    if selectedTab == "Image" {
                        ImageTabView(currentIndex: $currentIndex, animalsByCurrentName: $animalsByCurrentName, currentAnimal: $currentAnimal)
                    } else if selectedTab == "Location" {
                        LocationTabView(currentAnimal: $currentAnimal, mapRegion: $mapRegion, mapPins: $mapPins2, selectedCamera: $selectedCamera)
                    } else if selectedTab == "Harvest" {
                        Text("Harvest Information")
                            .padding()
                            // Add your Harvest tab content here
                    }

                    Spacer()
                }

                if showPopup {
                    PopupView(showPopup: $showPopup)
                        .transition(.move(edge: .bottom))
                }
            }
            .background(Color(UIColor.systemGray6))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
            .navigationTitle("Dashboard")
            .navigationBarItems(trailing:
                HStack {
                    Menu {
                        Button(action: {
                            withAnimation {
                                showPopup.toggle()
                            }
                        }) {
                            Label("Add New Image", systemImage: "photo")
                        }

                        Button(action: {
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
        .onAppear {
            loadApiKey()
            printRealmDatabasePath()
            loadUniqueAnimals()
            loadPinsFromRealm()
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

    private func printRealmDatabasePath() {
        if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {
            print("Realm database file path: \(fileURL.path)")
        } else {
            print("Could not find Realm database file path.")
        }
    }

    private func loadUniqueAnimals() {
        let realm = try! Realm()
        let distinctAnimals = realm.objects(ImageData.self).distinct(by: ["imageName"])
        uniqueAnimals = Array(distinctAnimals)
        if !uniqueAnimals.isEmpty {
            updateViewWithAnimal(at: 0)
        } else {
            currentAnimal = nil
        }
    }

    private func updateViewWithAnimal(at index: Int) {
        currentAnimal = uniqueAnimals[index]
        loadAnimalsByCurrentName()
        currentIndex = 0
    }

    private func loadAnimalsByCurrentName() {
        guard let currentImageName = currentAnimal?.imageName else { return }
        let realm = try! Realm()
        animalsByCurrentName = Array(realm.objects(ImageData.self).filter("imageName == %@", currentImageName))
    }

    private func loadPinsFromRealm() {
        let realm = try! Realm()
        let cameras = realm.objects(Camera.self)
        for camera in cameras {
            let newPin = MKPointAnnotation()
            newPin.coordinate = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
            newPin.title = camera.name
            let identifiablePin = IdentifiablePointAnnotation(annotation: newPin)
            mapPins.append(identifiablePin)
        }
    }
}

struct ImageTabView: View {
    @Binding var currentIndex: Int
    @Binding var animalsByCurrentName: [ImageData]
    @Binding var currentAnimal: ImageData?

    @State private var showFullScreenImage = false
    @State private var fullScreenImage: UIImage?

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(animalsByCurrentName.indices, id: \.self) { index in
                VStack {
                    if let imageData = animalsByCurrentName[index].imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                            .onTapGesture {
                                fullScreenImage = uiImage
                                showFullScreenImage.toggle()
                            }
                    } else {
                        Text("No Image Available")
                            .padding()
                    }

                    VStack {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(icon: "thermometer.high", iconColor: .red, label: "Temp", value: animalsByCurrentName[index].temperature)
                                InfoRow(icon: "cloud.rain.fill", iconColor: .blue, label: "Precip.", value: animalsByCurrentName[index].precipitation)
                                InfoRow(icon: "sunrise.fill", iconColor: .yellow, label: "Sunrise", value: animalsByCurrentName[index].sunrise)
                                InfoRow(icon: "sunset.fill", iconColor: .orange, label: "Sunset", value: animalsByCurrentName[index].sunset)
                                InfoRow(icon: "wind", iconColor: .green, label: "Wind", value: animalsByCurrentName[index].wind)
                                InfoRow(icon: "moonphase.waxing.gibbous.inverse", iconColor: .gray, label: "Moon", value: animalsByCurrentName[index].moonPhase)
                                InfoRow(icon: "clock.circle.fill", iconColor: .black, label: "Time", value: formattedTime(from: animalsByCurrentName[index].time))
                                InfoRow(icon: "calendar.circle.fill", iconColor: .blue, label: "Date", value: formattedDate(from: animalsByCurrentName[index].date))
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .onChange(of: currentIndex) { newIndex in
            currentAnimal = animalsByCurrentName[newIndex]
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageView(image: $fullScreenImage, isPresented: $showFullScreenImage)
        }
    }

    private func formattedDate(from date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    private func formattedTime(from time: Date?) -> String {
        guard let time = time else { return "N/A" }
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: time)
    }
}

struct FullScreenImageView: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.edgesIgnoringSafeArea(.all)
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("No Image Available")
                    .foregroundColor(.white)
            }
            Button(action: {
                isPresented.toggle()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}


struct LocationTabView: View {
    @Binding var currentAnimal: ImageData?
    @Binding var mapRegion: MKCoordinateRegion
    @Binding var mapPins: [IdentifiablePointAnnotation3]
    @Binding var selectedCamera: Camera?

    var body: some View {
        VStack {
            if let currentAnimal = currentAnimal, let camera = findCamera(by: currentAnimal.trailCamera) {
                MapView3(region: $mapRegion, pins: $mapPins, selectedCamera: $selectedCamera)
                    .onAppear {
                        let cameraLocation = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
                        mapRegion = MKCoordinateRegion(
                            center: cameraLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        addCameraPin(location: cameraLocation, name: camera.name)
                    }
            } else {
                Text("Location information not available.")
                    .padding()
            }
        }
    }

    private func findCamera(by name: String) -> Camera? {
        let realm = try! Realm()
        return realm.objects(Camera.self).filter("name == %@", name).first
    }

    private func addCameraPin(location: CLLocationCoordinate2D, name: String) {
        let cameraAnnotation = MKPointAnnotation()
        cameraAnnotation.coordinate = location
        cameraAnnotation.title = name
        let identifiablePin = IdentifiablePointAnnotation3(annotation: cameraAnnotation)
        mapPins = [identifiablePin]  // Replace existing pins with the new camera pin
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
    @Published var totalImages: Int = 0
    @Published var differentAnimalTypes: Set<String> = []
    @Published var averageTemperature: Double = 0.0
    @Published var averageFeelsLike: Double = 0.0

    private var realm: Realm

    init() {
        realm = try! Realm()
        fetchData()
    }

    func fetchData() {
        let results = realm.objects(ImageData.self)
        images = Array(results)

        totalImages = images.count
        differentAnimalTypes = Set(images.map { $0.animalType })
        averageTemperature = calculateAverageTemperature()
        averageFeelsLike = calculateAverageFeelsLike()
    }

    private func calculateAverageTemperature() -> Double {
        let temperatures = images.compactMap { Double($0.temperature) }
        guard !temperatures.isEmpty else { return 0.0 }
        return temperatures.reduce(0, +) / Double(temperatures.count)
    }

    private func calculateAverageFeelsLike() -> Double {
        let feelsLikeTemperatures = images.compactMap { Double($0.feelsLike) }
        guard !feelsLikeTemperatures.isEmpty else { return 0.0 }
        return feelsLikeTemperatures.reduce(0, +) / Double(feelsLikeTemperatures.count)
    }

    func printRealmDatabasePath() {
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
    @State private var temperature: String = ""
    @State private var feelsLike: String = ""
    @State private var sunrise: String = ""
    @State private var sunset: String = ""
    @State private var wind: String = ""
    @State private var windDirection: Int = 0
    @State private var weatherDescription: String = ""
    @State private var currentMoonPhase: String = ""
    @State private var precipitation: String = ""
    @State private var buckSize: String = ""
    @State private var trailCameras: [String] = []
    @State private var selectedLocation: CLLocationCoordinate2D?

    // Map-related states
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var pins: [IdentifiablePointAnnotation] = []
    @State private var showingCameraNamePopup = false
    @State private var showingCameraInfoPopup = false
    @State private var cameraName = ""
    @State private var lastPin: MKPointAnnotation?
    @State private var mapType: MKMapType = .standard
    @State private var selectedCameraInfo: CameraInfo?
    @State private var selectedCameraFeedback: String = ""

    let questions: [Question] = [
        Question(text: "Upload an image"),
        Question(text: "Animal Type"),
        Question(text: "Animal Name"),
        Question(text: "Buck size"),
        Question(text: "Date & Time"),
        Question(text: "Select Camera Location"),
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
                    if currentQuestionIndex > 0 {
                        Button(action: {
                            withAnimation {
                                currentQuestionIndex -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                        .padding([.top, .leading])
                    }

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
                } else if currentQuestionIndex == 5 {
                    // Map view for selecting camera location
                    VStack {
                        Text("Select Camera Location")
                            .font(.headline)
                            .padding()
                        
                        MapView2(
                            region: $region,
                            pins: $pins,
                            showingCameraNamePopup: $showingCameraNamePopup,
                            showingCameraInfoPopup: $showingCameraInfoPopup,
                            cameraName: $cameraName,
                            lastPin: $lastPin,
                            mapType: $mapType,
                            selectedCameraInfo: $selectedCameraInfo,
                            onCameraSelected: { camera in
                                self.trailCamera = camera.name
                                self.selectedCameraFeedback = "Selected Camera: \(camera.name)"
                            }
                        )
                        .frame(height: 300)

                        if !selectedCameraFeedback.isEmpty {
                            Text(selectedCameraFeedback)
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .padding(.top, 10)
                        }
                    }
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
            .gesture(
                DragGesture().onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation {
                            showPopup = false
                        }
                    }
                }
            )
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: dateTime)
        answers[0] = selectedImage != nil ? "Image Selected" : "No Image"
        answers[1] = animalTypes[selectedAnimalTypeIndex].description
        answers[3] = animalTypes[selectedAnimalTypeIndex].description == "Buck" ? "\(counter)" : ""
        print("Hello")
        print(animalTypes[selectedAnimalTypeIndex].description)
        if animalTypes[selectedAnimalTypeIndex].description == "Buck" {
            buckSize = String(counter)
        }
        print(buckSize)
        answers[4] = formattedDate

        for (index, answer) in answers.enumerated() {
            print("Question \(index + 1): \(answer)")
        }

        fetchWeatherData(latitude: selectedCamera.latitude, longitude: selectedCamera.longitude, dateTime: dateTime) { weatherData in
            DispatchQueue.main.async {
                if let weatherData = weatherData {
                    // Assuming you want to print the first item in the `data` array for demonstration purposes
                    if let firstWeatherDetail = weatherData.data.first {
                        print("Weather Data for \(self.formattedDate(self.selectedDate)) at \(self.formattedTime(self.selectedDate)):")
                        print("Temperature: \(firstWeatherDetail.temp)°F")
                        temperature = String(firstWeatherDetail.temp)
                        print("Feels Like: \(firstWeatherDetail.feelsLike)°F")
                        feelsLike = String(firstWeatherDetail.feelsLike)
                        print("Wind Speed: \(firstWeatherDetail.windSpeed) mph")
                        wind = String(firstWeatherDetail.windSpeed)
                        print("Wind Direction: \(windDirection(degrees: firstWeatherDetail.windDeg))")
                        windDirection = firstWeatherDetail.windDeg
                        print("Precipitation: \(firstWeatherDetail.precipitation ?? 0) mm")
                        precipitation = String(firstWeatherDetail.precipitation ?? 0)
                        print("Weather Description: \(firstWeatherDetail.weather.first?.description ?? "N/A")")
                        weatherDescription = firstWeatherDetail.weather.first?.description ?? "N/A"
                        // Convert Unix timestamps to formatted time
                        let sunriseTime = formattedTime(from: firstWeatherDetail.sunrise)
                        let sunsetTime = formattedTime(from: firstWeatherDetail.sunset)
                        print("Sunrise: \(sunriseTime)")
                        print("Sunset: \(sunsetTime)")
                        sunrise = sunriseTime
                        sunset = sunsetTime
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
                            currentMoonPhase = String(moonPhase)
                        case .failure(let error):
                            print("Failed to fetch moon phase data: \(error.localizedDescription)")
                        }

                        // Save to Realm on the main thread
                        let realm = try! Realm()
                        let imageDataObject = ImageData()
                        imageDataObject.imageName = answers[2]
                        imageDataObject.imageData = imageData
                        imageDataObject.animalType = animalTypes[selectedAnimalTypeIndex].description
                        if animalTypes[selectedAnimalTypeIndex].description == "Buck"
                        {
                            print("We in here")
                            imageDataObject.buckSize = buckSize
                        }
                        print(buckSize)
                        imageDataObject.date = self.selectedDate
                        imageDataObject.time = self.selectedDate
                        imageDataObject.trailCamera = trailCamera
                        imageDataObject.temperature = temperature
                        imageDataObject.feelsLike = feelsLike
                        imageDataObject.precipitation = precipitation
                        imageDataObject.wind = wind
                        imageDataObject.windDirection = windDirection(degrees: windDirection)
                        imageDataObject.sunrise = sunrise
                        imageDataObject.sunset = sunset
                        imageDataObject.weatherDescription = weatherDescription
                        imageDataObject.moonPhase = currentMoonPhase
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
    
    func formattedTime(from unixTimestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
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

struct InfoRow: View {
    var icon: String
    var iconColor: Color
    var label: String
    var value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 20, height: 20) // Added height to match the frame size
            Text(label)
                .frame(width: 80, alignment: .leading)
                .font(.system(size: 12))
            Spacer()
            Text(value)
                .font(.system(size: 12))
                .fontWeight(.bold)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct CustomInfoRow: View {
    var icon: String
    var iconColor: Color
    var label: String
    var value: String

    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20) // Set the custom image to the same size
                .foregroundColor(iconColor)
            Text(label)
                .frame(width: 80, alignment: .leading)
                .font(.system(size: 12))
            Spacer()
            Text(value)
                .font(.system(size: 12))
                .fontWeight(.bold)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

struct LineGraph: View {
    var data: [Double]
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(data.count - 1)
                let maxY = data.max() ?? 1
                path.move(to: CGPoint(x: 0, y: height * (1 - CGFloat(data[0] / maxY))))
                for i in 1..<data.count {
                    let x = stepX * CGFloat(i)
                    let y = height * (1 - CGFloat(data[i] / maxY))
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.orange, lineWidth: 2)
        }
        .frame(height: 100)
    }
}

struct CardView<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack {
            content
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(imageDataStore: ImageDataStore())
    }
}
