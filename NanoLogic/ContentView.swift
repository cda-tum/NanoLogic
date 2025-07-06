import SwiftUI
import AVKit

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 1.0
    
    var body: some View {
        ZStack {
            if isActive {
                ContentView()
            } else {
                Color(.systemBackground)
                    .ignoresSafeArea()
                Image("logo-nanotech-toolkit-high")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(50)
                    .accessibilityLabel("Nanotech Toolkit Splash Screen Logo")
                    .opacity(opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isActive = true
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

extension Color {
    static let goldYellow = Color(red: 242/255, green: 176/255, blue: 30/255)
    static let strongRed = Color(red: 198/255, green: 40/255, blue: 40/255)
    static let deepGreen = Color(red: 61/255, green: 122/255, blue: 11/255)
    static let richPurple = Color(red: 142/255, green: 31/255, blue: 130/255)
}

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State private var showInfo: Bool = false
    @State private var showSimulationWelcome: Bool = false
    @State private var navigateToSimulation: Bool = false
    @AppStorage("hasSeenSimulationWelcome") private var hasSeenSimulationWelcome: Bool = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        Image("logo-nanotech-toolkit-high")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width * 0.6)
                            .padding(.top, 50)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .accessibilityLabel("Nanotech Toolkit Logo")
                            .onTapGesture {
                                if let url = URL(string: "https://www.cda.cit.tum.de/research/nanotech/") {
                                    openURL(url)
                                }
                            }

                        Spacer()
                            .frame(minHeight: 8, maxHeight: 20)

                        ZStack {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8)
                                ],
                                alignment: .center,
                                spacing: Gutter()
                            ) {
                                NavigationTile(
                                    iconName: "gearshape.fill",
                                    title: "Simulation",
                                    color: .goldYellow,
                                    destination: SimulationView(),
                                    size: min(geometry.size.width, geometry.size.height) * 0.45
                                )
                                .onTapGesture {
                                    if !hasSeenSimulationWelcome {
                                        showSimulationWelcome = true
                                    } else {
                                        navigateToSimulation = true
                                    }
                                }
                                .accessibilityLabel("Simulation")
                                .accessibilityHint("Tap to view the simulation welcome message before navigating")

                                NavigationTile(
                                    iconName: "puzzlepiece.fill",
                                    title: "Logic Design",
                                    color: .strongRed,
                                    destination: DesignView(fieldName: "Logic Design"),
                                    size: min(geometry.size.width, geometry.size.height) * 0.45
                                )
                                NavigationTile(
                                    iconName: "bolt.fill",
                                    title: "Circuit Design",
                                    color: .deepGreen,
                                    destination: CircuitView(),
                                    size: min(geometry.size.width, geometry.size.height) * 0.45
                                )
                                NavigationTile(
                                    iconName: "chart.bar.fill",
                                    title: "Analysis",
                                    color: .richPurple,
                                    destination: AnalysisView(),
                                    size: min(geometry.size.width, geometry.size.height) * 0.45
                                )
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)

                            Button(action: {
                                showInfo = true
                            }) {
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 50, height: 50)
                                            .shadow(radius: 3)
                                    )
                            }
                            .popover(isPresented: $showInfo) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Silicon Dangling Bond Logic")
                                        .bold()
                                        .font(.title2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    HStack(spacing: 10) {
                                        Image("sidb_tech")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: geometry.size.width * 0.85)
                                            .padding(.vertical, 5)
                                            .accessibilityLabel("Illustration of Silicon Substrate")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    Text("Silicon Dangling Bond Logic is an emerging technology that promises computation on the atomic level with unmatched energy efficiency. Silicon Dangling Bonds are on hydrogen-passivated silicon. With an atomically precise STM tip, hydrogen atoms can be removed, creating a dangling bond that can be charged positively, neutrally, or negatively depending on the electrostatic interaction. This allows for the design of bits, logic gates, and circuits at the atomic scale.")
                                    HStack(spacing: 10) {
                                        Button("Close") {
                                            showInfo = false
                                        }
                                        .font(.callout)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.top, 10)
                                }
                                .padding()
                                .frame(width: geometry.size.width * 0.8)
                            }
                            .accessibilityLabel("Silicon Dangling Bond Logic Overview")
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .sheet(isPresented: $showSimulationWelcome) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Welcome to the Simulation")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                        Text("This simulation visualizes the charge distribution of Silicon Dangling Bonds. Green dots represent negatively charged bonds, while transparent dots indicate neutral ones. Use the 'Simulate' button to explore different energy states. Note: This is a simplified model for educational purposes and may not reflect real-world conditions.")
                            .font(.body)
                        Button("Got It") {
                            hasSeenSimulationWelcome = true
                            showSimulationWelcome = false
                            navigateToSimulation = true
                        }
                        .font(.callout)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                        .accessibilityLabel("Acknowledge simulation welcome message")
                    }
                    .padding()
                    .frame(width: geometry.size.width * 0.9)
                    .presentationDetents([.medium])
                }
                .navigationDestination(isPresented: $navigateToSimulation) {
                    SimulationView()
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.light)
    }

    func Gutter() -> CGFloat {
        return 8
    }
}

struct NavigationTile<Destination: View>: View {
    let iconName: String
    let title: String
    let color: Color
    let destination: Destination
    let size: CGFloat
    
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(radius: 3)
                
                VStack(spacing: 8) {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.3, height: size * 0.3)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.system(size: size * 0.1, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.99 : 1.0)
            .animation(.spring(), value: isPressed)
            .accessibilityLabel(title)
        }
        .buttonStyle(PlainButtonStyle())
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
    @State private var maxSimulationSteps: Double = 3
    @State private var currentLayoutImage: String = "neutral"
    @State private var showInfo: Bool = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Text("Simulation")
                            .font(.largeTitle)
                            .dynamicTypeSize(.xLarge)
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                showInfo = true
                            }) {
                                Image(systemName: "info.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .frame(width: 48, height: 48)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .shadow(radius: 3)
                                    )
                                    .scaleEffect(pulseScale)
                                    .animation(
                                        .easeInOut(duration: 0.4)
                                        .repeatForever(autoreverses: true),
                                        value: pulseScale
                                    )
                                    .accessibilityLabel("Show simulation information")
                                    .accessibilityHint("Tap to learn more about the physical simulation")
                            }
                            .popover(isPresented: $showInfo) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Physical Simulation")
                                        .bold()
                                        .font(.title2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    Text("predicts the charge distribution of the Silicon Dangling Bonds. Green dots indicate negatively charged Silicon Dangling Bonds, while transparent dots represent neutral ones. Press the button to run the simulation and explore charge distributions with varying energy values.")
                                    Button("Close") {
                                        showInfo = false
                                    }
                                    .font(.callout)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.top, 10)
                                }
                                .padding()
                                .frame(width: geometry.size.width * 0.8)
                            }
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                            pulseScale = 1.10
                        }
                        showInfo = true
                    }
                    
                    Image(currentLayoutImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                    
                    if !isSimulating {
                        Button(action: {
                            startSimulation()
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
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                    } else {
                        VStack(spacing: 20) {
                            HStack(spacing: 10) {
                                stateButton(index: 0, title: "Ground State", geometry: geometry)
                                stateButton(index: 1, title: "1st Excited", geometry: geometry)
                                stateButton(index: 2, title: "2nd Excited", geometry: geometry)
                                stateButton(index: 3, title: "3rd Excited", geometry: geometry)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            Button(action: {
                                resetSimulation()
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }) {
                                Text("Reset Simulation")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: geometry.size.width * 0.8)
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)
    }
    
    func stateButton(index: Int, title: String, geometry: GeometryProxy) -> some View {
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
                .frame(maxWidth: geometry.size.width * 0.22, minHeight: 44)
                .background(Int(simulationIndex) == index ? Color.blue : Color.gray)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Int(simulationIndex) == index ? Color.blue.opacity(0.8) : Color.clear, lineWidth: 2)
                )
        }
    }
    
    func startSimulation() {
        isSimulating = true
        simulationIndex = 0
        updateSimulationImage()
    }
    
    func updateSimulationImage() {
        currentLayoutImage = "\(Int(simulationIndex))"
    }
    
    func resetSimulation() {
        isSimulating = false
        currentLayoutImage = "neutral"
    }
}

struct CircuitView: View {
    @State var selectedCircuit: String = "mux21"
    @State var designStage: DesignStage = .initial
    @State var isComputing: Bool = false
    @State var computationProgress: CGFloat = 0
    @State private var showInfo: Bool = false
    @State private var pulseScale: CGFloat = 1.0

    let circuits = ["mux21", "c17", "maj"]

    enum DesignStage {
        case initial
        case skeletons
        case final
    }

    var currentImage: String? {
        switch designStage {
        case .initial: return "only_defects"
        case .skeletons: return "\(selectedCircuit)_without_canvas"
        case .final: return selectedCircuit
        }
    }

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        VStack {
            ZStack {
                Text("Circuit Design")
                    .font(.largeTitle)
                    .dynamicTypeSize(.xLarge)
                HStack {
                    Spacer()
                    Button(action: { showInfo = true }) {
                        Image(systemName: "info.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(radius: 3)
                            )
                            .scaleEffect(pulseScale)
                            .animation(
                                .easeInOut(duration: 0.4)
                                .repeatForever(autoreverses: true),
                                value: pulseScale
                            )
                            .accessibilityLabel("Show circuit design information")
                            .accessibilityHint("Tap to learn more about circuit design")
                    }
                    .popover(isPresented: $showInfo) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Circuit Design")
                                .bold()
                                .font(.title2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text("enables the design of circuits that account for atomic defects. The process begins by placing and routing a given logic gate-level layout onto a clocked surface. Standard cells are then designed \"on-the-fly\", integrating atomic defects from the surrounding environment. The result is a circuit that performs correctly despite real atomic-scale imperfections.")
                            Button("Close") {
                                showInfo = false
                            }
                            .font(.callout)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 10)
                        }
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                    }
                }
                .padding(.trailing, 10)
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .center)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    pulseScale = 1.10
                }
                showInfo = true
            }

            HStack(spacing: Gutter()) {
                ForEach(circuits, id: \.self) { circuit in
                    Button(action: {
                        selectedCircuit = circuit
                        designStage = .initial
                    }) {
                        Text(circuit)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: horizontalSizeClass == .compact ? 80 : 100)
                            .background(selectedCircuit == circuit ? Color.blue : Color.gray)
                            .scaleEffect(selectedCircuit == circuit ? 1.05 : 1.0)
                            .animation(.spring(), value: selectedCircuit)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
            GeometryReader { geometry in
                ZStack {
                    if let imageName = currentImage, !isComputing {
                        let imageSize = min(geometry.size.width, geometry.size.height) * 1.0
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                            .accessibilityLabel("Circuit image for \(selectedCircuit), stage \(designStage)")
                    } else {
                        Color.clear
                            .frame(width: geometry.size.width, height: geometry.size.height)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

            VStack {
                Button(action: { startComputation() }) {
                    Text(buttonLabel)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(buttonColor)
                        .cornerRadius(10)
                        .minimumScaleFactor(0.8)
                }
                .disabled(isComputing)
                .padding(.horizontal, 20)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .onAppear {
            designStage = .initial
        }
        .preferredColorScheme(.light)
    }

    var buttonLabel: String {
        switch designStage {
        case .initial: return "Find Placement & Routing for Skeletons"
        case .skeletons: return "On-the-Fly Gate Design"
        case .final: return "Redo"
        }
    }

    var buttonColor: Color {
        switch designStage {
        case .initial: return .blue
        case .skeletons: return .green
        case .final: return .red
        }
    }

    var computationMessage: String {
        switch designStage {
        case .initial: return "Computing placement and routing for \(selectedCircuit)..."
        case .skeletons: return "Designing gates on-the-fly for \(selectedCircuit)..."
        case .final: return "Resetting design state for \(selectedCircuit)..."
        }
    }

    func startComputation() {
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

    func finishComputation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch designStage {
            case .initial: designStage = .skeletons
            case .skeletons: designStage = .final
            case .final:
                designStage = .initial
            }
            isComputing = false
        }
    }

    func Gutter() -> CGFloat {
        return horizontalSizeClass == .compact ? 10 : 15
    }
}

struct DesignView: View {
    var fieldName: String
    @State private var selectedInput: Int = 0
    @State private var stage: Stage = .initial
    @State private var showInfo: Bool = false
    @State private var pulseScale: CGFloat = 1.0

    let binaryLabels = ["00", "01", "10", "11"]
    
    enum Stage {
        case initial
        case neutral
        case simulated
    }
    
    var andOutput: String {
        selectedInput == 3 ? "1" : "0"
    }
    
    var currentImage: String {
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
                    ZStack {
                        Text("Logic Design")
                            .font(.largeTitle)
                            .dynamicTypeSize(.xLarge)
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                showInfo = true
                            }) {
                                Image(systemName: "info.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .frame(width: 48, height: 48)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .shadow(radius: 3)
                                    )
                                    .scaleEffect(pulseScale)
                                    .animation(
                                        .easeInOut(duration: 0.4)
                                        .repeatForever(autoreverses: true),
                                        value: pulseScale
                                    )
                                    .accessibilityLabel("Show logic design information")
                                    .accessibilityHint("Tap to learn more about logic design")
                            }
                            .popover(isPresented: $showInfo) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Logic Design")
                                        .bold()
                                        .font(.title2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    Text("creates standard cells by placing Silicon Dangling Bonds between input and output wires. The algorithm positions the Silicon Dangling Bonds to satisfy the given Boolean function for all input patterns. The design is validated through physical simulation to ensure the correct charge distribution.")
                                    Button("Close") {
                                        showInfo = false
                                    }
                                    .font(.callout)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.top, 10)
                                }
                                .padding()
                                .frame(width: geometry.size.width * 0.8)
                            }
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                            pulseScale = 1.10
                        }
                        showInfo = true
                    }
                    
                    Image(currentImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.9)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                    
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
                                .frame(maxWidth: geometry.size.width * 0.8)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
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
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                        
                    case .simulated:
                        VStack(spacing: 15) {
                            Text("Input Pattern (A, B) for AND Gate")
                                .font(.subheadline)
                                .dynamicTypeSize(.medium)
                                .frame(maxWidth: .infinity, alignment: .center)
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
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("AND Output: \(andOutput)")
                                .font(.subheadline)
                                .dynamicTypeSize(.medium)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 10)
                        }
                        .padding(.vertical)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)
    }
}

struct VideoPlayerView: View {
    var videoName: String
    @Binding var player: AVPlayer?
    var width: CGFloat = 600
    var height: CGFloat = 450
    
    var body: some View {
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            VideoPlayer(player: player ?? AVPlayer(url: url))
                .frame(width: width, height: height)
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
    @State var selectedDomain: String = "Temperature Domain"
    @State private var showInfo: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Text("Analysis")
                            .font(.largeTitle)
                            .dynamicTypeSize(.xLarge)
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                showInfo = true
                            }) {
                                Image(systemName: "info.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .frame(width: 48, height: 48)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .shadow(radius: 3)
                                    )
                                    .scaleEffect(pulseScale)
                                    .animation(
                                        .easeInOut(duration: 0.4)
                                        .repeatForever(autoreverses: true),
                                        value: pulseScale
                                    )
                                    .accessibilityLabel("Show analysis information")
                                    .accessibilityHint("Tap to learn more about analysis")
                            }
                            .popover(isPresented: $showInfo) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Analysis")
                                        .bold()
                                        .font(.title2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    Text("evaluates the performance of Silicon Dangling Bond logic under varying conditions. Temperature simulation examines the impact of thermal variations, while Operational Domain Analysis assesses robustness against material imperfections. These evaluation tools help optimize designs for real-world reliability.")
                                    Button("Close") {
                                        showInfo = false
                                    }
                                    .font(.callout)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.top, 10)
                                }
                                .padding()
                                .frame(width: geometry.size.width * 0.8)
                            }
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                            pulseScale = 1.10
                        }
                        showInfo = true
                    }
                    
                    Picker("Select Domain", selection: $selectedDomain) {
                        Text("Temperature").tag("Temperature Domain")
                        Text("Operational").tag("Operational Domain")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: geometry.size.width * 0.9)
                    .padding(.horizontal)
                    
                    Group {
                        if selectedDomain == "Temperature Domain" {
                            TemperatureView()
                        } else if selectedDomain == "Operational Domain" {
                            OperationalDomainView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)
    }
}

struct OperationalDomainView: View {
    @State var gridSearchPlayer: AVPlayer?
    @State var randomPlayer: AVPlayer?
    @State var floodFillPlayer: AVPlayer?
    @State var contourPlayer: AVPlayer?
    @State var isGridSearchPlaying = false
    @State var isRandomPlaying = false
    @State var isFloodFillPlaying = false
    @State var isContourPlaying = false
    @State var selectedVideo: String = "Grid Search"
    @State var epsilonR: Double = 5.5
    @State var lambdaTF: Double = 5.0
    @State var selectedSection: Section = .parameters
    let playbackSpeed: Float = 200.0
    
    enum Section: String, CaseIterable, Identifiable {
        case parameters = "Parameter Dependency"
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
        .preferredColorScheme(.light)
    }
    
    var headerView: some View {
        Text("Operational Domain")
            .font(.title)
            .padding(.top, 10)
    }
    
    var sectionPickerView: some View {
        Picker("Section", selection: $selectedSection) {
            ForEach(Section.allCases) { section in
                Text(section.rawValue).tag(section)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    var parameterSelectionSection: some View {
        GeometryReader { geometry in
            VStack(spacing: 15) {
                if let svgName = svgFileName {
                    Image(svgName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: max(geometry.size.width * 0.9, 600))
                        .padding(.horizontal)
                        .accessibilityLabel("Charge distribution for ε_r \(String(format: "%.1f", epsilonR)) and λ_tf \(String(format: "%.1f", lambdaTF))")
                } else {
                    Text("No matching PNG found")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                
                VStack(spacing: 10) {
                    VStack(spacing: 8) {
                        Slider(value: $lambdaTF, in: 1.0...10.0, step: 0.5)
                            .frame(width: geometry.size.width * 0.8)
                            .tint(.blue)
                        Text("λ\(Text("tf").font(.footnote).baselineOffset(-5)): \(String(format: "%.1f", lambdaTF))")
                            .font(.subheadline)
                    }
                    
                    VStack(spacing: 8) {
                        Slider(value: $epsilonR, in: 1.0...10.0, step: 0.5)
                            .frame(width: geometry.size.width * 0.8)
                            .tint(.blue)
                        Text("ε\(Text("r").font(.footnote).baselineOffset(-5)): \(String(format: "%.1f", epsilonR))")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.1)
            }
            .padding(.vertical, 10)
        }
        .frame(minHeight: 500)
    }

    var algorithmSimulationSection: some View {
        VStack(spacing: 15) {
            adaptiveAlgorithmButtons
            videoSection
        }
        .padding(.top, 10)
    }
    
    var adaptiveAlgorithmButtons: some View {
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
    func algorithmButton(for video: String) -> some View {
        Button(action: { selectedVideo = video }) {
            Text(video)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(selectedVideo == video ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selectedVideo == video ? .white : .black)
                .cornerRadius(8)
        }
    }
    
    var videoSection: some View {
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
    
    var svgFileName: String? {
        let epsilonStr = String(format: "%.1f", epsilonR).replacingOccurrences(of: ".", with: "_")
        let lambdaStr = String(format: "%.1f", lambdaTF).replacingOccurrences(of: ".", with: "_")
        let fileName = "charge_eps_\(epsilonStr)_lambda_\(lambdaStr)"
        return fileName
    }
    
    @ViewBuilder
    func videoPlayerSection(player: Binding<AVPlayer?>, isPlaying: Binding<Bool>, videoName: String) -> some View {
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
    func playPauseButton(player: Binding<AVPlayer?>, isPlaying: Binding<Bool>, videoName: String) -> some View {
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
    func repeatButton(player: Binding<AVPlayer?>, isPlaying: Binding<Bool>, videoName: String) -> some View {
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
    
    func initializePlayers() {
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
    
    func stopAllPlayers() {
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
    @State var temperature: Double = 1
    @State var cxImageName: String = "cx_1"
    @State var nandImageName: String = "nand_1"
    @State var selectedImage: ImageSelection = .crossing
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
                
                sliderSection
                
                Picker("Select Image", selection: $selectedImage) {
                    ForEach(ImageSelection.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                imageSection
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .onAppear {
            updateImages(forTemperature: Int(temperature))
        }
        .preferredColorScheme(.light)
    }
    
    var sliderSection: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                ZStack(alignment: .center) {
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .green, .yellow, .orange, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(7.5)
                    .frame(height: 10)
                    .padding(.horizontal, 5)

                    Slider(value: Binding(
                        get: { self.temperature },
                        set: { newValue in
                            self.temperature = newValue
                            self.updateImages(forTemperature: Int(newValue))
                        }
                    ), in: 1...400, step: 5)
                    .tint(.white.opacity(0.8))
                    .frame(width: geometry.size.width * 0.8)
                }

                Text("Temperature: \(Int(temperature)) K")
                    .font(.subheadline)
                    .padding(.vertical, 5)
            }
            .padding(.horizontal, geometry.size.width * 0.1)
        }
        .frame(height: 60)
    }
    
    var imageSection: some View {
        VStack {
            if selectedImage == .crossing {
                singleImageView(name: cxImageName, size: imageSize)
            } else {
                singleImageView(name: nandImageName, size: imageSize)
            }
        }
        .padding(.top, 20)
    }
    
    func singleImageView(name: String, size: CGFloat) -> some View {
        VStack(spacing: 5) {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size, maxHeight: size)
                .padding(.vertical, 5)
                .accessibilityLabel("Image of \(selectedImage.rawValue) at temperature \(Int(temperature)) K")
        }
    }
    
    func updateImages(forTemperature temp: Int) {
        cxImageName = "cx_\(temp)"
        nandImageName = "nand_\(temp)"
    }
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var imageSize: CGFloat {
        isCompact ? 300 : 500
    }
}

#Preview {
    ContentView()
}
