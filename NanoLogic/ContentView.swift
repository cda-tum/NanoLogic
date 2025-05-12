import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .ignoresSafeArea() // Full-screen background
                    
                    // Responsive LazyVGrid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ],
                        spacing: 8
                    ) {
                        // Navigation tiles with distinct colors
                        NavigationTile(
                            iconName: "gearshape.fill",
                            title: "Simulation",
                            color: .blue,
                            destination: SimulationView(),
                            size: min(geometry.size.width, geometry.size.height) * 0.45
                        )
                        NavigationTile(
                            iconName: "puzzlepiece.fill",
                            title: "Logic Design",
                            color: .green,
                            destination: DesignView(fieldName: "Logic Design"),
                            size: min(geometry.size.width, geometry.size.height) * 0.45
                        )
                        NavigationTile(
                            iconName: "bolt.fill",
                            title: "Circuit Design",
                            color: .orange,
                            destination: CircuitView(),
                            size: min(geometry.size.width, geometry.size.height) * 0.45
                        )
                        NavigationTile(
                            iconName: "chart.bar.fill",
                            title: "Analysis",
                            color: .purple,
                            destination: AnalysisView(),
                            size: min(geometry.size.width, geometry.size.height) * 0.45
                        )
                    }
                    .padding(.all, 12) // Padding for edge spacing
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Reusable NavigationTile view with customizable color
struct NavigationTile<Destination: View>: View {
    let iconName: String
    let title: String
    let color: Color
    let destination: Destination
    let size: CGFloat
    
    @State private var isPressed = false // For tap animation
    
    var body: some View {
        NavigationLink(destination: destination) {
            ZStack {
                // Tile background
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15)) // Subtle background color
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(radius: 3)
                
                // Optional gradient background (uncomment to use)
                /*
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.2), color.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(radius: 3)
                */
                
                // Content: SF Symbol and Text
                VStack(spacing: 8) {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.3, height: size * 0.3)
                        .foregroundColor(color) // Match icon to tile color
                    
                    Text(title)
                        .font(.system(size: size * 0.1, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 12)) // Ensure entire tile is tappable
            .scaleEffect(isPressed ? 0.95 : 1.0) // Tap animation
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .accessibilityLabel(title) // Accessibility
        }
        .buttonStyle(PlainButtonStyle()) // Avoid default button styling
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct SimulationView: View {
    @State private var isSimulating: Bool = false
    @State private var simulationIndex: Double = 0
    @State private var maxSimulationSteps: Double = 3 // Bilder 0-3, also 4 Bilder insgesamt
    @State private var currentLayoutImage: String = "neutral"
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Simulation")
                        .font(.largeTitle)
                        .dynamicTypeSize(.xLarge)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    
                    // Layout image
                    Image(currentLayoutImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(geometry.size.width * 0.9, 400), maxHeight: min(geometry.size.height * 0.5, 400))
                        .padding(.horizontal)
                    
                    // Simulation controls
                    if !isSimulating {
                        Button(action: {
                            startSimulation()
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }) {
                            Text("Simulate")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: min(geometry.size.width * 0.8, 200))
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.vertical)
                    } else {
                        VStack(spacing: 20) {
                            HStack(spacing: 10) {
                                stateButton(index: 0, title: "Ground State", geometry: geometry)
                                stateButton(index: 1, title: "1st Excited", geometry: geometry)
                                stateButton(index: 2, title: "2nd Excited", geometry: geometry)
                                stateButton(index: 3, title: "3rd Excited", geometry: geometry)
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                resetSimulation()
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }) {
                                Text("Reset Simulation")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: min(geometry.size.width * 0.8, 200))
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            .padding(.vertical)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 20) // Extra padding for home indicator
            }
            .ignoresSafeArea(.keyboard) // Prevent keyboard from pushing content
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Helper function for state buttons
    private func stateButton(index: Int, title: String, geometry: GeometryProxy) -> some View {
        Button(action: {
            simulationIndex = Double(index)
            updateSimulationImage()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(maxWidth: min(geometry.size.width * 0.22, 100), minHeight: 44)
                .background(Int(simulationIndex) == index ? Color.blue : Color.gray)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Int(simulationIndex) == index ? Color.blue.opacity(0.8) : Color.clear, lineWidth: 2)
                )
        }
    }
    
    private func startSimulation() {
        isSimulating = true
        simulationIndex = 0
        updateSimulationImage()
    }
    
    private func updateSimulationImage() {
        currentLayoutImage = "\(Int(simulationIndex))"
    }
    
    private func resetSimulation() {
        isSimulating = false
        currentLayoutImage = "neutral"
    }
}

struct CircuitView: View {
    @State private var selectedCircuit: String = "mux21"
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var designStage: DesignStage = .initial
    @State private var isComputing: Bool = false
    @State private var computationProgress: CGFloat = 0

    private let circuits = ["mux21", "c17", "majority"]

    private enum DesignStage {
        case initial
        case skeletons
        case final
    }

    private var currentImage: String? {
        switch designStage {
        case .initial: return "only_defects"
        case .skeletons: return "\(selectedCircuit)_without_canvas"
        case .final: return selectedCircuit
        }
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        VStack {
            Text("Circuit Design")
                .font(.largeTitle)
                .padding()

            HStack(spacing: 15) {
                ForEach(circuits, id: \.self) { circuit in
                    Button(action: {
                        selectedCircuit = circuit
                        designStage = .initial
                        scale = 1.0
                        lastScale = 1.0
                    }) {
                        Text(circuit)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: horizontalSizeClass == .compact ? 80 : 100)
                            .background(selectedCircuit == circuit ? Color.blue : Color.gray)
                            .scaleEffect(selectedCircuit == circuit ? 1.05 : 1.0)
                            .animation(.spring(), value: selectedCircuit)
                            .lineLimit(1) // Restrict to one line
                            .minimumScaleFactor(0.8) // Allow text to shrink if needed
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            Spacer()
            GeometryReader { geometry in
                ZStack {
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        if let imageName = currentImage, !isComputing {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: geometry.size.width * 0.8,
                                    height: geometry.size.height * 0.8
                                )
                                .scaleEffect(scale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale *= delta
                                            scale = min(max(scale, 0.5), 3.0)
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                        }
                                )
                        } else {
                            Color.clear
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }

                    if isComputing {
                        VStack(spacing: 25) {
                            ZStack {
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 6)
                                    .frame(width: geometry.size.width * 0.2)
                                Circle()
                                    .trim(from: 0, to: computationProgress)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                    .frame(width: geometry.size.width * 0.2)
                                    .rotationEffect(.degrees(-90))
                            }
                            Text(computationMessage)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }

            VStack {
                Button(action: {
                    startComputation()
                }) {
                    Text(buttonLabel)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Make the button take the full width of its container
                        .frame(height: 50) // Set a consistent height
                        .background(buttonColor)
                        .cornerRadius(10)
                        .minimumScaleFactor(0.8)
                }
                .disabled(isComputing)
                .padding(.horizontal, 20) // Add horizontal padding for spacing
            }
            .padding()

            Spacer()
        }
        .onAppear {
            designStage = .initial
            scale = 1.0
        }
    }

    private var buttonLabel: String {
        switch designStage {
        case .initial: return "Find Placement & Routing for Skeletons"
        case .skeletons: return "On-the-Fly Gate Design"
        case .final: return "Redo"
        }
    }

    private var buttonColor: Color {
        switch designStage {
        case .initial: return .blue
        case .skeletons: return .green
        case .final: return .red
        }
    }

    private var computationMessage: String {
        switch designStage {
        case .initial: return "Computing placement and routing for \(selectedCircuit)..."
        case .skeletons: return "Designing gates on-the-fly for \(selectedCircuit)..."
        case .final: return "Resetting design state for \(selectedCircuit)..."
        }
    }

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

    private func finishComputation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch designStage {
            case .initial: designStage = .skeletons
            case .skeletons: designStage = .final
            case .final:
                designStage = .initial
                scale = 1.0
                lastScale = 1.0
            }
            isComputing = false
        }
    }
}

struct DesignView: View {
    var fieldName: String
    @State private var selectedInput: Int = 0
    @State private var stage: Stage = .initial
    
    private let binaryLabels = ["00", "01", "10", "11"]
    
    private enum Stage {
        case initial
        case neutral
        case simulated
    }
    
    private var andOutput: String {
        selectedInput == 3 ? "1" : "0"
    }
    
    private var currentImage: String {
        switch stage {
        case .initial:
            return "working_without_canvas_sidbs"
        case .neutral:
            return "working_neutral"
        case .simulated:
            return "working_\(selectedInput)"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Logic Design")
                        .font(.largeTitle)
                        .dynamicTypeSize(.xLarge)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    
                    // Image display
                    Image(currentImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geometry.size.width * 0.9, maxHeight: geometry.size.height * 0.5)
                        .padding(.horizontal)
                    
                    // Controls based on stage
                    switch stage {
                    case .initial:
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                stage = .neutral
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }) {
                            Text("Design AND Gate")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: geometry.size.width * 0.3, maxHeight: 100)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        .padding(.vertical)
                        .accessibilityLabel("Design AND gate")
                        
                    case .neutral:
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                stage = .simulated
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }) {
                            Text("Simulate")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: geometry.size.width * 0.8)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.vertical)
                        
                    case .simulated:
                        VStack(spacing: 15) {
                            Text("Input Pattern (A, B) for AND Gate")
                                .font(.subheadline)
                                .dynamicTypeSize(.medium)
                                .padding(.bottom, 5)
                            
                            HStack(spacing: 10) {
                                ForEach(0..<4) { index in
                                    Button(action: {
                                        selectedInput = index
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }) {
                                        Text(binaryLabels[index])
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .frame(maxWidth: geometry.size.width * 0.2, minHeight: 44)
                                            .background(selectedInput == index ? Color.blue : Color.gray)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            
                            Text("AND Output: \(andOutput)")
                                .font(.subheadline)
                                .dynamicTypeSize(.medium)
                                .padding(.top, 10)
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 20) // Extra padding for home indicator
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitleDisplayMode(.inline)
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

struct AnalysisView: View {
    @State private var selectedDomain: String = "Temperature Domain"
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Analysis")
                        .font(.largeTitle)
                        .dynamicTypeSize(.xLarge)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    
                    // Domain Picker
                    Picker("Select Domain", selection: $selectedDomain) {
                        Text("Temperature").tag("Temperature Domain")
                        Text("Operational").tag("Operational Domain")
                        Text("Defect").tag("Defect Influence")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: geometry.size.width * 0.9)
                    .padding(.horizontal)
                    
                    // Conditional Content
                    Group {
                        if selectedDomain == "Temperature Domain" {
                            TemperatureView()
                        } else if selectedDomain == "Operational Domain" {
                            OperationalDomainView()
                        } else {
                            DefectInfluenceView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(.bottom, 20) // Extra padding for home indicator
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitleDisplayMode(.inline)
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
        ScrollView {
            VStack(spacing: 15) {
                headerView
                sectionPickerView
                
                if selectedSection == .parameters {
                    parameterSelectionSection
                } else {
                    algorithmSimulationSection
                }
                
                Spacer()
            }
            .padding()
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
    }
    
    private var parameterSelectionSection: some View {
        GeometryReader { geometry in
            VStack(spacing: 15) {
                // SVG Image with increased size
                if let svgName = svgFileName {
                    Image(svgName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geometry.size.width * 0.9, maxHeight: geometry.size.height * 0.6) // Increased size
                        .padding(.horizontal)
                        .accessibilityLabel("Charge distribution for ε_r \(String(format: "%.1f", epsilonR)) and λ_tf \(String(format: "%.1f", lambdaTF))")
                } else {
                    Text("No matching PNG found")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                
                // Sliders with responsive width
                VStack(spacing: 10) {
                    // Lambda TF Slider and Text
                    VStack(spacing: 8) {
                        Slider(value: $lambdaTF, in: 1.0...10.0, step: 0.5)
                            .frame(width: min(geometry.size.width * 0.8, 350)) // Responsive width
                            .tint(.blue)
                        Text("λ\(Text("tf").font(.footnote).baselineOffset(-5)): \(String(format: "%.1f", lambdaTF))")
                            .font(.subheadline)
                    }
                    
                    // Epsilon R Slider and Text
                    VStack(spacing: 8) {
                        Slider(value: $epsilonR, in: 1.0...10.0, step: 0.5)
                            .frame(width: min(geometry.size.width * 0.8, 350)) // Responsive width
                            .tint(.blue)
                        Text("ε\(Text("r").font(.footnote).baselineOffset(-5)): \(String(format: "%.1f", epsilonR))")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.1) // Dynamic padding
            }
            .padding(.vertical, 10)
        }
        .frame(minHeight: 500) // Ensure enough space for the plot and sliders
    }
    
    private var algorithmSimulationSection: some View {
        VStack(spacing: 15) {
            adaptiveAlgorithmButtons
            videoSection
        }
        .padding(.top, 10)
    }
    
    private var adaptiveAlgorithmButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                algorithmButton(for: "Grid Search")
                algorithmButton(for: "Random Sampling")
            }
            HStack(spacing: 10) {
                algorithmButton(for: "Flood Fill")
                algorithmButton(for: "Contour Tracing")
            }
        }
    }
    
    @ViewBuilder
    private func algorithmButton(for video: String) -> some View {
        Button(action: { selectedVideo = video }) {
            Text(video)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(selectedVideo == video ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selectedVideo == video ? .white : .black)
                .cornerRadius(8)
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
    
    @ViewBuilder
    private func videoPlayerSection(player: Binding<AVPlayer?>, isPlaying: Binding<Bool>, videoName: String) -> some View {
        VStack(spacing: 10) {
            VideoPlayer(player: player.wrappedValue)
                .aspectRatio(4/3, contentMode: .fit)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Spacer()
                playPauseButton(player: player, isPlaying: isPlaying, videoName: videoName)
                repeatButton(player: player, isPlaying: isPlaying, videoName: videoName)
                Spacer()
            }
            .padding(.bottom)
        }
    }
    
    @ViewBuilder
    private func playPauseButton(player: Binding<AVPlayer?>, isPlaying: Binding<Bool>, videoName: String) -> some View {
        Button(action: {
            guard let player = player.wrappedValue else { print("No player for \(videoName)"); return }
            if isPlaying.wrappedValue {
                player.pause()
            } else {
                player.play()
                player.rate = playbackSpeed
            }
            isPlaying.wrappedValue.toggle()
        }) {
            Image(systemName: isPlaying.wrappedValue ? "pause.fill" : "play.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(12)
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
        }) {
            Image(systemName: "repeat")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(12)
                .background(Circle().fill(Color.green))
        }
    }
    
    private func initializePlayers() {
        if let gridSearchURL = Bundle.main.url(forResource: "grid", withExtension: "mp4") {
            gridSearchPlayer = AVPlayer(url: gridSearchURL)
        }
        if let randomURL = Bundle.main.url(forResource: "random", withExtension: "mp4") {
            randomPlayer = AVPlayer(url: randomURL)
        }
        if let floodFillURL = Bundle.main.url(forResource: "flood_fill", withExtension: "mp4") {
            floodFillPlayer = AVPlayer(url: floodFillURL)
        }
        if let contourURL = Bundle.main.url(forResource: "contour", withExtension: "mp4") {
            contourPlayer = AVPlayer(url: contourURL)
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


struct TemperatureView: View {
    @State private var temperature: Double = 1
    @State private var cxImageName: String = "cx_1"
    @State private var nandImageName: String = "nand_1"
    @State private var selectedImage: ImageSelection = .crossing
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    enum ImageSelection: String, CaseIterable, Identifiable {
        case crossing = "Crossing"
        case nand = "NAND"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Temperature Simulation")
                    .font(.title)
                    .padding(.top, 10)
                
                // Slider Section
                sliderSection
                
                // Picker
                Picker("Select Image", selection: $selectedImage) {
                    ForEach(ImageSelection.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Image Display
                imageSection
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .onAppear {
            updateImages(forTemperature: Int(temperature))
        }
    }
    
    private var sliderSection: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                ZStack(alignment: .center) { // Center alignment for thumb
                    // Gradient background for slider track
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .green, .yellow, .orange, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(7.5)
                    .frame(height: 10) // Reduced height for a sleeker look
                    .padding(.horizontal, 5) // Padding to align with slider thumb

                    // Slider control
                    Slider(value: Binding(
                        get: { self.temperature },
                        set: { newValue in
                            self.temperature = newValue
                            self.updateImages(forTemperature: Int(newValue))
                        }
                    ), in: 1...400, step: 5)
                    .tint(.white.opacity(0.8)) // White thumb for contrast
                    .frame(width: min(geometry.size.width * 0.8, 350)) // Dynamic width
                }

                Text("Temperature: \(Int(temperature)) K")
                    .font(.subheadline) // Match button font for consistency
                    .padding(.vertical, 5)
            }
            .padding(.horizontal, geometry.size.width * 0.1) // Dynamic padding
        }
        .frame(height: 60) // Reserve space for slider and text
    }
    
    private var imageSection: some View {
        VStack {
            if selectedImage == .crossing {
                singleImageView(name: cxImageName, size: imageSize)
            } else {
                singleImageView(name: nandImageName, size: imageSize)
            }
        }
        .padding(.top, 20)
    }
    
    private func singleImageView(name: String, title: String? = nil, size: CGFloat) -> some View {
        VStack(spacing: 5) {
            if let title = title {
                Text(title)
                    .font(.headline)
            }
            
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size, maxHeight: size)
                .padding(.vertical, 5)
        }
    }
    
    private func updateImages(forTemperature temp: Int) {
        cxImageName = "cx_\(temp)"
        nandImageName = "nand_\(temp)"
    }
    
    // MARK: - Responsive Layout Helpers
    
    // Check if we're on a compact device (iPhone or smaller iPad)
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    // Size for single image display
    private var imageSize: CGFloat {
        isCompact ? 300 : 500
    }
}


struct DefectInfluenceView: View {
    @State private var defectPlayer: AVPlayer?
    @State private var isPlaying = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let playbackSpeed: Float = 1 // Adjust speed if needed
    private let videoName = "defect_influence" // Replace with your video file name (without extension)
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                VStack(spacing: 15) {
                    Text("Defect Influence")
                        .font(.title)
                        .padding(.top, 10)
                    
                    VideoPlayer(player: defectPlayer)
                        .aspectRatio(600 / 531, contentMode: .fit) // Maintain original aspect ratio
                        .frame(
                            maxWidth: geometry.size.width * 0.9, // 90% of the screen width
                            maxHeight: geometry.size.height * 0.6 // 60% of the screen height
                        )
                        .cornerRadius(12)
                        //.shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                        .padding()
                    
                    HStack(spacing: 20) {
                        Spacer()
                        playPauseButton
                        repeatButton
                        Spacer()
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .frame(minHeight: 500) // Ensure enough space for the video and controls
        }
        .onAppear(perform: initializePlayer)
        .onDisappear(perform: stopPlayer)
    }
    
    private var playPauseButton: some View {
        Button(action: {
            guard let player = defectPlayer else { print("No player for defect video"); return }
            if isPlaying {
                player.pause()
            } else {
                player.play()
                player.rate = playbackSpeed
            }
            isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: buttonSize))
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
            player.rate = playbackSpeed
            isPlaying = true
        }) {
            Image(systemName: "repeat")
                .font(.system(size: buttonSize))
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
    
    // Adjust button size for different devices
    private var buttonSize: CGFloat {
        horizontalSizeClass == .compact ? 24 : 30
    }
}

// Preview
#Preview {
    ContentView()
}
