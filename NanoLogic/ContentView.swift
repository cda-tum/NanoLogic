import SwiftUI
import AVKit


let scaling_width = 0.523
let scaling_height = 0.523

struct ContentView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.white
                                            .edgesIgnoringSafeArea(.all)
                    // Hintergrund der vier Bilder in einer 2x2 Struktur
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            NavigationLink(destination: SimulationView()) {
                                Image("simulation")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * scaling_width,
                                           height: geometry.size.height * scaling_height)
                                    .offset(x: -5, y: -28)
                            }
                            .zIndex(1) // Stelle sicher, dass dieses Element klickbar bleibt
                            
                            NavigationLink(destination: NewFieldViewWithImages(fieldName: "Logic Design")) {
                                Image("logic_design")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * scaling_width,
                                           height: geometry.size.height * scaling_height)
                                    .offset(x: -19, y: -28)
                            }
                            .zIndex(1)
                        }
                        
                        HStack(spacing: 0) {
                            NavigationLink(destination: NewFieldView()) {
                                Image("circuit_design")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * scaling_width,
                                           height: geometry.size.height * scaling_height)
                                    .offset(x: -5, y: -32)
                            }
                            .zIndex(1)
                            
                            NavigationLink(destination: AnalysisView()) {
                                Image("analysis")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * scaling_width,
                                           height: geometry.size.height * scaling_height)
                                    .offset(x: -19, y: -32)
                            }
                            .zIndex(1)
                        }
                    }
                    
                    // Neues Bild in der Mitte
                    NavigationLink(destination: MiddleView()) {
                        Image("play_button") // Ersetze durch den Namen deines Bildes
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * scaling_width * 0.25,
                                   height: geometry.size.height * scaling_height * 0.25)
                    }
                    .position(x: geometry.size.width / 2 + 5, y: geometry.size.height / 2) // Zentriert
                    .zIndex(0) // Niedrigerer zIndex, damit die äußeren Bilder Vorrang haben
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MiddleView: View {
    @State private var workingPrinciplePlayer: AVPlayer?
    @State private var manufacturingPlayer: AVPlayer?
    @State private var isWorkingPrinciplePlaying = false
    @State private var isManufacturingPlaying = false
    @State private var isManufacturingVideoFinished = false
    @State private var isWorkingPrincipleVideoFinished = false // New state to track basil video end
    @State private var currentSlideIndex = 0 // Tracks the current slideshow image
    
    private let playbackSpeed: Float = 2.0
    private let videoScaling: CGFloat = 1.5
    private let slideshowImages = ["working_0", "working_1", "working_2", "working_3"] // Slideshow images
    
    var body: some View {
        GeometryReader { geometry in
            TabView {
                // Manufacturing Tab
                ScrollView {
                    VStack(spacing: 20) {
                        // Machine Image Section
                        imageSection(
                            imageName: "machine",
                            caption: "STM/AFM Machine at 4.4 K",
                            maxHeight: geometry.size.height * 0.35
                        )
                        
                        // Video or Tip Image Section
                        if !isManufacturingVideoFinished {
                            videoPlayerSection(
                                player: $manufacturingPlayer,
                                isPlaying: $isManufacturingPlaying,
                                videoName: "stm_sharpening",
                                ending: "mp4",
                                geometry: geometry
                            )
                        } else {
                            VStack(spacing: 20) {
                                imageSection(
                                    imageName: "tip",
                                    caption: "Atomically thin STM Tip",
                                    maxHeight: geometry.size.height * 0.4
                                )
                                Button(action: {
                                    isManufacturingVideoFinished = false
                                    manufacturingPlayer?.seek(to: .zero)
                                    manufacturingPlayer?.play()
                                    manufacturingPlayer?.rate = playbackSpeed
                                    isManufacturingPlaying = true
                                    print("Video stm_sharpening restarted")
                                }) {
                                    Image(systemName: "repeat")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Circle().fill(Color.green))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                .tabItem {
                    Label("Manufacturing", systemImage: "photo.on.rectangle")
                }
                
                // Working Principle Tab with Video and Slideshow
                VStack(spacing: 20) {
                    // Video Section
                    videoPlayerSection(
                        player: $workingPrinciplePlayer,
                        isPlaying: $isWorkingPrinciplePlaying,
                        videoName: "basil",
                        ending: "mp4",
                        geometry: geometry
                    )
                    
                    // Slideshow Section
                    TabView(selection: $currentSlideIndex) {
                        ForEach(0..<slideshowImages.count, id: \.self) { index in
                            Image(slideshowImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: geometry.size.height * 0.35)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: geometry.size.height * 0.4)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
                .tabItem {
                    Label("Working Principle", systemImage: "gear")
                }
            }
        }
        .onAppear(perform: initializePlayers)
        .onDisappear(perform: stopAllPlayers)
    }
    
    // Reusable Image Section
    @ViewBuilder
    private func imageSection(imageName: String, caption: String, maxHeight: CGFloat) -> some View {
        VStack(spacing: 8) {
            if let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: maxHeight)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                Text("Image '\(imageName)' not found")
                    .foregroundColor(.red)
            }
            Text(caption)
                .font(.body)
                .foregroundColor(.gray)
        }
    }
    
    // Reusable Video Player Section
    @ViewBuilder
    private func videoPlayerSection(player: Binding<AVPlayer?>,
                                   isPlaying: Binding<Bool>,
                                   videoName: String,
                                   ending: String,
                                   geometry: GeometryProxy) -> some View {
        VStack(spacing: 10) {
            if let url = Bundle.main.url(forResource: videoName, withExtension: ending) {
                VideoPlayer(player: player.wrappedValue ?? AVPlayer(url: url))
                    .frame(width: min(532 * videoScaling, geometry.size.width * 0.9),
                           height: min(300 * videoScaling, geometry.size.height * 0.5))
                    .cornerRadius(10)
                    .onAppear {
                        print("VideoPlayer loaded: \(videoName).\(ending)")
                        if videoName == "stm_sharpening" {
                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                  object: player.wrappedValue?.currentItem,
                                                                  queue: .main) { _ in
                                isManufacturingVideoFinished = true
                                isPlaying.wrappedValue = false
                                print("Video finished: \(videoName)")
                            }
                        } else if videoName == "basil" {
                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                  object: player.wrappedValue?.currentItem,
                                                                  queue: .main) { _ in
                                isWorkingPrincipleVideoFinished = true
                                isPlaying.wrappedValue = false
                                print("Video finished: \(videoName)")
                                startSlideshowTimer() // Start slideshow when basil finishes
                            }
                        }
                    }
            } else {
                Text("Video not found: \(videoName).\(ending)")
                    .foregroundColor(.red)
                    .onAppear {
                        print("Video not found: \(videoName).\(ending)")
                    }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    guard let player = player.wrappedValue else { print("No player for \(videoName)"); return }
                    if isPlaying.wrappedValue {
                        player.pause()
                        print("Video paused: \(videoName)")
                    } else {
                        player.play()
                        player.rate = playbackSpeed
                        print("Video playing: \(videoName) at rate \(playbackSpeed)")
                    }
                    isPlaying.wrappedValue.toggle()
                }) {
                    Image(systemName: isPlaying.wrappedValue ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Circle().fill(Color.blue))
                }
                
                Button(action: {
                    guard let player = player.wrappedValue else { print("No player for \(videoName)"); return }
                    player.seek(to: .zero)
                    player.play()
                    player.rate = playbackSpeed
                    isPlaying.wrappedValue = true
                    print("Video restarted: \(videoName) at rate \(playbackSpeed)")
                    if videoName == "basil" {
                        isWorkingPrincipleVideoFinished = false // Reset slideshow trigger
                    }
                }) {
                    Image(systemName: "repeat")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Circle().fill(Color.green))
                }
            }
        }
    }
    
    private func initializePlayers() {
        if let workingPrincipleURL = Bundle.main.url(forResource: "basil", withExtension: "mp4") {
            workingPrinciplePlayer = AVPlayer(url: workingPrincipleURL)
            workingPrinciplePlayer?.play()
            workingPrinciplePlayer?.rate = playbackSpeed
            isWorkingPrinciplePlaying = true
            print("Working Principle Player initialized (basil)")
        } else {
            print("Working Principle Video not found (basil.mp4)")
        }
        
        if let manufacturingURL = Bundle.main.url(forResource: "stm_sharpening", withExtension: "mp4") {
            manufacturingPlayer = AVPlayer(url: manufacturingURL)
            manufacturingPlayer?.play()
            manufacturingPlayer?.rate = playbackSpeed
            isManufacturingPlaying = true
            print("Manufacturing Player initialized (stm_sharpening)")
        } else {
            print("Manufacturing Video not found (stm_sharpening.mp4)")
        }
    }
    
    private func stopAllPlayers() {
        workingPrinciplePlayer?.pause()
        manufacturingPlayer?.pause()
        isWorkingPrinciplePlaying = false
        isManufacturingPlaying = false
        print("All players stopped")
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // Start the slideshow timer after the video finishes
    private func startSlideshowTimer() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            withAnimation {
                if isWorkingPrincipleVideoFinished { // Only advance if video is finished
                    currentSlideIndex = (currentSlideIndex + 1) % slideshowImages.count
                } else {
                    timer.invalidate() // Stop timer if video restarts
                }
            }
        }
    }
}

struct MiddleView_Previews: PreviewProvider {
    static var previews: some View {
        MiddleView()
    }
}

struct SimulationView: View {
    @State private var isSimulating: Bool = false
    @State private var simulationIndex: Double = 0
    @State private var maxSimulationSteps: Double = 3  // Bilder 0-3, also 4 Bilder insgesamt
    @State private var currentLayoutImage: String = "neutral"
    
    var body: some View {
        VStack {
            
            Text("Simulation")
                .font(.largeTitle)
                .padding()
            
            // Layout-Bild oder Simulations-Ergebnisbild
            Image(currentLayoutImage)
                .resizable()
                .scaledToFit()
                .frame(height: 700)
                .padding()
                .padding()
            
            // Simulation-Taste
            if !isSimulating {
                Button(action: {
                    startSimulation()
                }) {
                    Text("Simulate")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                // Buttons für die verschiedenen Zustände erscheinen nur nach dem Simulieren
                VStack {
                    HStack(spacing: 15) {
                        stateButton(index: 0, title: "Ground State")
                        stateButton(index: 1, title: "1st Excited")
                        stateButton(index: 2, title: "2nd Excited")
                        stateButton(index: 3, title: "3rd  Excited")
                    }
                    //.padding()
                    
                    // Reset-Button
                    Button(action: {
                        resetSimulation()
                    }) {
                        Text("Reset Simulation")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
            
            Spacer()
        }
        //.background(Color.black.edgesIgnoringSafeArea(.all))
        //.navigationBarTitle("Circuit Simulation", displayMode: .inline)
    }
    
    // Hilfsfunktion für die Erstellung der Zustandstasten
    private func stateButton(index: Int, title: String) -> some View {
        Button(action: {
            simulationIndex = Double(index)
            updateSimulationImage()
        }) {
            VStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(8)
            }
            .frame(width: 120)
            .background(Int(simulationIndex) == index ? Color.blue : Color.gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Int(simulationIndex) == index ? Color.blue.opacity(0.8) : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private func startSimulation() {
        // Starte die Simulation
        isSimulating = true
        simulationIndex = 0  // Beginne mit dem ersten Simulationsbild (0)
        updateSimulationImage()
    }
    
    private func updateSimulationImage() {
        // Aktualisiere das Bild basierend auf dem ausgewählten Zustand
        // Die Bilder heißen "0", "1", "2", "3"
        currentLayoutImage = "\(Int(simulationIndex))"
    }
    
    private func resetSimulation() {
        // Setze die Simulation zurück
        isSimulating = false
        currentLayoutImage = "neutral"  // Ursprüngliches Layout-Bild
    }
}

struct NewFieldView: View {
    @State private var selectedCircuit: String = "mux21" // Default circuit
    @State private var scale: CGFloat = 1.0 // Zoom scale
    @State private var lastScale: CGFloat = 1.0 // To track the last scale value
    @State private var designStage: DesignStage = .initial // Start with initial stage
    @State private var isComputing: Bool = false // Track computing state
    @State private var computationProgress: CGFloat = 0 // For progress display
    
    // List of circuit options
    private let circuits = ["mux21", "c17", "majority"]
    
    // Enum to represent the design stages
    private enum DesignStage {
        case initial // Show generic defects until computation starts
        case skeletons // After "Find Placement & Routing for Skeletons"
        case final // After "On-the-Fly Gate Design"
    }
    
    // Determine the current image based on stage
    private var currentImage: String? {
        switch designStage {
        case .initial:
            return "only_defects" // Single defect image
        case .skeletons:
            return "\(selectedCircuit)_without_canvas" // Circuit-specific skeletons
        case .final:
            return selectedCircuit // Circuit-specific final design
        }
    }
    
    var body: some View {
        VStack {
            // Title
            Text("Circuit Design")
                .font(.largeTitle)
                .padding()
            
            // Buttons for selecting circuits
            HStack(spacing: 15) {
                ForEach(circuits, id: \.self) { circuit in
                    Button(action: {
                        selectedCircuit = circuit
                        // Stay in .initial, keep showing defect surface
                        scale = 1.0 // Reset zoom
                        lastScale = 1.0
                    }) {
                        Text(circuit)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100)
                            .background(selectedCircuit == circuit ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(isComputing) // Disable when computing
                }
            }
            .padding()
            
            // Centered image with zoom functionality
            Spacer()
            GeometryReader { geometry in
                ZStack {
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        if let imageName = currentImage, !isComputing {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 700, height: 700) // Fixed size for all images
                                .scaleEffect(scale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale *= delta
                                            scale = min(max(scale, 0.5), 3.0) // Limit scale
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                        }
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                        } else {
                            // Placeholder when no image is shown
                            Color.clear
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                    
                    // Computation overlay
                    if isComputing {
                        VStack(spacing: 25) {
                            ZStack {
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 6)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: computationProgress)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                
                                ForEach(0..<8) { i in
                                    let angle = Double(i) * (360.0 / 8.0)
                                    Rectangle()
                                        .fill(Color.blue.opacity(0.8))
                                        .frame(width: 25, height: 3)
                                        .offset(x: 30)
                                        .rotationEffect(.degrees(angle))
                                        .opacity(sin(computationProgress * 10 + Double(i)) * 0.5 + 0.5)
                                }
                                
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 30, height: 30)
                                    .scaleEffect(1.0 + 0.2 * sin(computationProgress * 15))
                            }
                            .rotationEffect(.degrees(isComputing ? 360 : 0))
                            .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false), value: isComputing)
                            
                            VStack(spacing: 12) {
                                Text(computationMessage)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("\(Int(computationProgress * 100))%")
                                    .font(.title2.monospacedDigit())
                                    .foregroundColor(.blue)
                                    .animation(.none, value: computationProgress)
                                
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: 200, height: 8)
                                        .opacity(0.3)
                                        .foregroundColor(.gray)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .frame(width: 200 * computationProgress, height: 8)
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                        .animation(.linear, value: computationProgress)
                                }
                            }
                        }
                    }
                }
            }
            
            // Button based on stage
            VStack {
                Button(action: {
                    startComputation()
                }) {
                    Text(buttonLabel)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300)
                        .background(buttonColor)
                        .cornerRadius(10)
                }
                .disabled(isComputing)
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            designStage = .initial // Start with generic defects
            scale = 1.0
        }
    }
    
    // Computed property for button label based on stage
    private var buttonLabel: String {
        switch designStage {
        case .initial:
            return "Find Placement & Routing for Skeletons"
        case .skeletons:
            return "On-the-Fly Gate Design"
        case .final:
            return "Redo"
        }
    }
    
    // Computed property for button color based on stage
    private var buttonColor: Color {
        switch designStage {
        case .initial:
            return .blue
        case .skeletons:
            return .green
        case .final:
            return .red
        }
    }
    
    // Computation message based on current stage
    private var computationMessage: String {
        switch designStage {
        case .initial:
            return "Computing placement and routing for \(selectedCircuit)..."
        case .skeletons:
            return "Designing gates on-the-fly for \(selectedCircuit)..."
        case .final:
            return "Resetting design state for \(selectedCircuit)..."
        }
    }
    
    // Start the "computation" process
    private func startComputation() {
        isComputing = true
        computationProgress = 0.0
        
        let computationTime = designStage == .skeletons ? 1.0 : 0.5
        
        withAnimation(.linear(duration: computationTime)) {
            computationProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + computationTime + 0.1) {
            finishComputation()
        }
    }
    
    // Finish computation and advance the state
    private func finishComputation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch designStage {
            case .initial:
                designStage = .skeletons // Move to skeletons after computation
            case .skeletons:
                designStage = .final
            case .final:
                designStage = .initial // Back to generic defects
                scale = 1.0 // Reset zoom
                lastScale = 1.0
            }
            
            isComputing = false
        }
    }
}

// New Field View with Images for Logic Design
struct NewFieldViewWithImages: View {
    var fieldName: String
    @State private var isWorking: Bool = false // Default to Non-Working
    @State private var selectedInput: Int = 0 // Input selection: 0, 1, 2, 3
    @State private var stage: Stage = .initial // Tracks the current stage
    
    // Binary labels for buttons (input patterns)
    private let binaryLabels = ["00", "01", "10", "11"]
    
    // Enum to represent the stages
    private enum Stage {
        case initial // Shows ..._without_canvas_sidbs
        case neutral // Shows ..._neutral after "Distribute SiDBs"
        case simulated // Shows toggleable inputs after "Simulate"
    }
    
    // Compute AND gate output based on selected input and working state
    private var andOutput: String {
        if isWorking {
            // Working AND gate: output is 1 only when input is "11" (index 3)
            return selectedInput == 3 ? "1" : "0"
        } else {
            // Non-working AND gate: incorrect output for "01" (index 1) and "10" (index 2)
            switch selectedInput {
            case 1: return "1" // Incorrect: should be 0
            case 2: return "1" // Incorrect: should be 0
            case 3: return "1" // Correct: 1 AND 1 = 1
            default: return "0" // Correct for "00"
            }
        }
    }
    
    // Determine if the output is incorrect (for non-working mode)
    private var isOutputIncorrect: Bool {
        !isWorking && (selectedInput == 1 || selectedInput == 2)
    }
    
    // Determine the current image based on stage
    private var currentImage: String {
        switch stage {
        case .initial:
            return "\(isWorking ? "working" : "non_working")_without_canvas_sidbs"
        case .neutral:
            return "\(isWorking ? "working" : "non_working")_neutral"
        case .simulated:
            return "\(isWorking ? "working" : "non_working")_\(selectedInput)"
        }
    }
    
    var body: some View {
        VStack {
            Text("Logic Design")
                .font(.largeTitle)
                .padding(.top, 20)
            
            // Working/Non-Working Picker
            Picker("Mode", selection: $isWorking) {
                Text("Non-Working")
                    .font(.system(size: 55)) // Increase font size here
                    .tag(false)
                Text("Working")
                    .font(.system(size: 55)) // Increase font size here
                    .tag(true)
            }
            .pickerStyle(.segmented)
            .frame(height: 50)
            .padding()
            
            // Image display
            Image(currentImage)
                .resizable()
                .scaledToFit()
                .frame(height: 600)
                .padding()
            
            // Controls based on stage
            switch stage {
            case .initial:
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        stage = .neutral
                    }
                }) {
                    Text("Distribute 4 SiDBs")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
            case .neutral:
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        stage = .simulated
                    }
                }) {
                    Text("Simulate")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
            case .simulated:
                VStack(spacing: 20) {
                    Text("Input Pattern (A, B) for AND Gate")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    HStack(spacing: 15) {
                        ForEach(0..<4) { index in
                            Button(action: {
                                selectedInput = index
                            }) {
                                Text(binaryLabels[index])
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 60)
                                    .background(selectedInput == index ? Color.blue : Color.gray)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Display AND gate output with incorrect indication
                    HStack {
                        Text("AND Output: \(andOutput)")
                            .font(.title2)
                            .foregroundColor(isOutputIncorrect ? .red : .black)
                        
                        if isOutputIncorrect {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            
            Spacer()
        }
    }
}

struct VideoPlayerView: View {
    var videoName: String
    @Binding var player: AVPlayer?
    var width: CGFloat = 600 // Default width
    var height: CGFloat = 450 // Default height
    
    var body: some View {
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            VideoPlayer(player: player ?? AVPlayer(url: url))
                .frame(width: width, height: height) // Use external dimensions
                .background(Color.black.opacity(0))
                .cornerRadius(10)
                .padding()
                .onAppear {
                    print("VideoPlayerView appeared - Video: \(videoName).mp4")
                }
        } else {
            Text("Video not found: \(videoName).mp4")
                .foregroundColor(.red)
                .onAppear {
                    print("VideoPlayerView: Failed to load video: \(videoName).mp4")
                }
        }
    }
}

// Analysis View
struct AnalysisView: View {
    @State private var selectedDomain: String = "Temperature Domain"
    
    var body: some View {
        VStack {
            Text("Analysis")
                .font(.largeTitle)
                .padding(.top, 20)
            Picker("Select Domain", selection: $selectedDomain) {
                Text("Temperature Domain")
                    .font(.system(size: 70, weight: .medium, design: .rounded))
                    .tag("Temperature Domain")
                Text("Operational Domain")
                    .font(.system(size: 70, weight: .medium, design: .rounded))
                    .tag("Operational Domain")
                Text("Defect Influence")
                    .font(.system(size: 70, weight: .medium, design: .rounded))
                    .tag("Defect Influence")
            }
            .pickerStyle(.segmented)
            .frame(height: 60)
            .padding()
            
            if selectedDomain == "Temperature Domain" {
                NewFieldViewWithTemperature()
            } else if selectedDomain == "Operational Domain" {
                OperationalDomainView()
            } else {
                DefectInfluenceView() // Static image view
            }
            
            Spacer()
        }
    }
}

struct OperationalDomainView: View {
    @State private var gridSearchPlayer: AVPlayer?
    @State private var randomPlayer: AVPlayer?
    @State private var floodFillPlayer: AVPlayer?
    @State private var contourPlayer: AVPlayer?
    @State private var isGridSearchPlaying = false
    @State private var isRandomPlaying = false
    @State private var isFloodFillPlaying = false
    @State private var isContourPlaying = false
    @State private var selectedVideo: String = "Grid Search"
    @State private var epsilonR: Double = 5.5 // Default epsilon_r
    @State private var lambdaTF: Double = 5.0 // Default lambda_tf
    @State private var selectedSection: Section = .parameters // Default to parameter selection
    private let playbackSpeed: Float = 200.0
    
    enum Section: String, CaseIterable, Identifiable {
        case parameters = "Physical Parameter Dependency"
        case algorithms = "Operational Domain"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            sectionPickerView
            contentView
            Spacer()
        }
        .onAppear(perform: initializePlayers)
        .onDisappear(perform: stopAllPlayers)
    }
    
    private var headerView: some View {
        Text("Operational Domain")
            .font(.title)
            .padding(.top, 10)
    }
    
    private var sectionPickerView: some View {
        Picker("Section", selection: $selectedSection) {
            ForEach(Section.allCases) { section in
                Text(section.rawValue).tag(section)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if selectedSection == .parameters {
                    parameterSelectionSection
                } else {
                    algorithmSimulationSection
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private var parameterSelectionSection: some View {
        VStack(spacing: 20) {
            imageView
                .frame(maxWidth: 580, maxHeight: 580, alignment: .center)
            HStack(spacing: 40) { // Stack sliders horizontally below the image
                // Lambda TF Slider and Text
                VStack(spacing: 10) {
                    Slider(value: $lambdaTF, in: 1.0...10.0, step: 0.5)
                        .frame(width: 200)
                    Text("λ\(Text("tf").font(.footnote).baselineOffset(-5)): \(String(format: "%.1f", lambdaTF))")
                        .font(.headline)
                }
                
                // Epsilon R Slider and Text
                VStack(spacing: 10) {
                    Slider(value: $epsilonR, in: 1.0...10.0, step: 0.5)
                        .frame(width: 200)
                    Text("ε\(Text("r").font(.footnote).baselineOffset(-5)): \(String(format: "%.1f", epsilonR))")
                        .font(.headline)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 10)
    }
    
    private var imageView: some View {
        VStack {
            if let svgName = svgFileName {
                Image(svgName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 900, maxHeight: 900)
                    .padding()
            } else {
                Text("No matching PNG found")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var algorithmSimulationSection: some View {
        VStack(spacing: 20) {
            algorithmButtons
            videoSection
        }
        .padding(.top, 10)
    }
    
    private var algorithmButtons: some View {
        HStack(spacing: 10) {
            ForEach(["Grid Search", "Random Sampling", "Flood Fill", "Contour Tracing"], id: \.self) { video in
                algorithmButton(for: video)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func algorithmButton(for video: String) -> some View {
        Button(action: { selectedVideo = video }) {
            Text(video)
                .font(.headline)
                .frame(width: video == "Flood Fill" ? 120 : 140, height: 70)
                .background(selectedVideo == video ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selectedVideo == video ? .white : .black)
                .cornerRadius(10)
        }
    }
    
    private var videoSection: some View {
        Group {
            if selectedVideo == "Grid Search" {
                videoPlayerSection(player: $gridSearchPlayer, isPlaying: $isGridSearchPlaying, videoName: "grid")
            } else if selectedVideo == "Random Sampling" {
                videoPlayerSection(player: $randomPlayer, isPlaying: $isRandomPlaying, videoName: "random")
            } else if selectedVideo == "Flood Fill" {
                videoPlayerSection(player: $floodFillPlayer, isPlaying: $isFloodFillPlaying, videoName: "flood_fill")
            } else {
                videoPlayerSection(player: $contourPlayer, isPlaying: $isContourPlaying, videoName: "contour")
            }
        }
    }
    
    private var svgFileName: String? {
        let epsilonStr = String(format: "%.1f", epsilonR).replacingOccurrences(of: ".", with: "_")
        let lambdaStr = String(format: "%.1f", lambdaTF).replacingOccurrences(of: ".", with: "_")
        let fileName = "charge_eps_\(epsilonStr)_lambda_\(lambdaStr)"
        return fileName
    }
    
    let scaling = 1.1
    
    @ViewBuilder
    private func videoPlayerSection(player: Binding<AVPlayer?>, isPlaying: Binding<Bool>, videoName: String) -> some View {
        VStack(spacing: 0) {
            VideoPlayer(player: player.wrappedValue)
                .frame(width: 543 * scaling, height: 407 * scaling)
                .padding()
            
            HStack(spacing: 10) {
                Spacer()
                playPauseButton(player: player, isPlaying: isPlaying, videoName: videoName)
                repeatButton(player: player, isPlaying: isPlaying, videoName: videoName)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func playPauseButton(player: Binding<AVPlayer?>, isPlaying: Binding<Bool>, videoName: String) -> some View {
        Button(action: {
            guard let player = player.wrappedValue else { print("No player for \(videoName)"); return }
            if isPlaying.wrappedValue {
                player.pause()
                print("Video paused")
            } else {
                player.play()
                player.rate = playbackSpeed
                print("Video playing at rate: \(playbackSpeed)")
            }
            isPlaying.wrappedValue.toggle()
        }) {
            Image(systemName: isPlaying.wrappedValue ? "pause.fill" : "play.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(Color.blue))
        }
    }
    
    @ViewBuilder
    private func repeatButton(player: Binding<AVPlayer?>, isPlaying: Binding<Bool>, videoName: String) -> some View {
        Button(action: {
            guard let player = player.wrappedValue else { print("No player for \(videoName)"); return }
            player.seek(to: .zero)
            player.play()
            player.rate = playbackSpeed
            isPlaying.wrappedValue = true
            print("Video restarted at rate: \(playbackSpeed)")
        }) {
            Image(systemName: "repeat")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(Color.green))
        }
    }
    
    private func initializePlayers() {
        if let gridSearchURL = Bundle.main.url(forResource: "grid", withExtension: "mp4") {
            gridSearchPlayer = AVPlayer(url: gridSearchURL)
            print("Grid Search player initialized")
        } else {
            print("Grid Search video not found")
        }
        if let randomURL = Bundle.main.url(forResource: "random", withExtension: "mp4") {
            randomPlayer = AVPlayer(url: randomURL)
            print("Random player initialized")
        } else {
            print("Random video not found")
        }
        if let floodFillURL = Bundle.main.url(forResource: "flood_fill", withExtension: "mp4") {
            floodFillPlayer = AVPlayer(url: floodFillURL)
            print("Flood Fill player initialized")
        } else {
            print("Flood Fill video not found")
        }
        if let contourURL = Bundle.main.url(forResource: "contour", withExtension: "mp4") {
            contourPlayer = AVPlayer(url: contourURL)
            print("Contour player initialized")
        } else {
            print("Contour video not found")
        }
    }
    
    private func stopAllPlayers() {
        gridSearchPlayer?.pause()
        randomPlayer?.pause()
        floodFillPlayer?.pause()
        contourPlayer?.pause()
        isGridSearchPlaying = false
        isRandomPlaying = false
        isFloodFillPlaying = false
        isContourPlaying = false
    }
}
// Temperature Domain View
struct NewFieldViewWithTemperature: View {
    @State private var temperature: Double = 1
    @State private var cxImageName: String = "cx_1"
    @State private var nandImageName: String = "nand_1"
    @State private var selectedImage: ImageSelection = .both // Default to showing both
    
    enum ImageSelection: String, CaseIterable, Identifiable {
        case crossing = "Crossing"
        case nand = "NAND"
        case both = "Both"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 20) { // Main spacing between sections
            Text("Temperature Simulation")
                .font(.title)
                .padding(.top, 10)
            
            VStack {
                Slider(value: Binding(
                    get: { self.temperature },
                    set: { newValue in
                        self.temperature = newValue
                        self.updateImages(forTemperature: Int(newValue))
                    }
                ), in: 1...400, step: 5)
                .frame(width: 300, height: 30)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .green, .yellow, .orange, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(15)
                    .frame(height: 15)
                )
                
                Text("Temperature: \(Int(temperature)) K")
                    .font(.headline)
                    .padding(.vertical, 5)
            }
            
            // Picker to select which image(s) to show
            Picker("Select Image", selection: $selectedImage) {
                ForEach(ImageSelection.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Conditional layout based on selection with extra padding
            if selectedImage == .both {
                HStack(spacing: 15) {
                    VStack {
                        Text("Crossing") // Only shown when both are selected
                            .font(.headline)
                        Image(cxImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 340, height: 340) // Smaller size for both
                            .padding(.vertical, 5)
                    }
                    
                    VStack {
                        Text("NAND") // Only shown when both are selected
                            .font(.headline)
                        Image(nandImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 340, height: 340) // Smaller size for both
                            .padding(.vertical, 5)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40) // Increased distance from picker/slider
            } else if selectedImage == .crossing {
                VStack {
                    Image(cxImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 500) // Original size for single
                        .padding(.vertical, 5)
                }
                .padding(.top, 40) // Increased distance from picker/slider
            } else if selectedImage == .nand {
                VStack {
                    Image(nandImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 500) // Original size for single
                        .padding(.vertical, 5)
                }
                .padding(.top, 40) // Increased distance from picker/slider
            }
            
            Spacer()
        }
        .onAppear(perform: {
            updateImages(forTemperature: Int(temperature))
        })
    }
    
    private func updateImages(forTemperature temp: Int) {
        cxImageName = "cx_\(temp)"
        nandImageName = "nand_\(temp)"
    }
}

struct DefectInfluenceView: View {
    @State private var defectPlayer: AVPlayer?
    @State private var isPlaying = false
    private let playbackSpeed: Float = 1 // Adjust speed if needed
    private let videoName = "defect_influence" // Replace with your video file name (without extension)
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Defect Influence")
                .font(.title)
                .padding(.top, 10)
            
            VideoPlayer(player: defectPlayer)
                .frame(width: 600*1.2, height: 531*1.2) // Match OperationalDomainView size, adjust as needed
                .padding()
            
            HStack(spacing: 10) {
                Spacer()
                playPauseButton
                repeatButton
                Spacer()
            }
            
            Spacer()
        }
        .onAppear(perform: initializePlayer)
        .onDisappear(perform: stopPlayer)
    }
    
    private var playPauseButton: some View {
        Button(action: {
            guard let player = defectPlayer else { print("No player for defect video"); return }
            if isPlaying {
                player.pause()
                print("Defect video paused")
            } else {
                player.play()
                player.rate = playbackSpeed * 1
                print("Defect video playing at rate: \(playbackSpeed)")
            }
            isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(Color.blue))
        }
    }
    
    private var repeatButton: some View {
        Button(action: {
            guard let player = defectPlayer else { print("No player for defect video"); return }
            player.seek(to: .zero)
            player.play()
            player.rate = playbackSpeed * 1
            isPlaying = true
            print("Defect video restarted at rate: \(playbackSpeed)")
        }) {
            Image(systemName: "repeat")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(Color.green))
        }
    }
    
    private func initializePlayer() {
        if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            defectPlayer = AVPlayer(url: videoURL)
            print("Defect video player initialized")
        } else {
            print("Defect video file '\(videoName).mp4' not found")
        }
    }
    
    private func stopPlayer() {
        defectPlayer?.pause()
        isPlaying = false
    }
}


// Preview
#Preview {
    ContentView()
}
