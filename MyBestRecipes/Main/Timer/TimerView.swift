//
//  TimerView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

//  TimerView.swift
import SwiftUI

struct TimerView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = TimerViewModel()
    
    private let timePresets: [Int] = [300, 600, 900, 1800]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 30) { // Увеличим немного отступ
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.appAccent)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                TimerCircleView(
                    // Отображаем либо оставшееся время, либо начальное кастомное
                    progress: viewModel.progress,
                    timeString: viewModel.isRunning || viewModel.isFinished ? viewModel.timeString : String(format: "%02d:%02d", viewModel.customMinutes, viewModel.customSeconds)
                )
                .padding(.horizontal, 40)
                
                TimerControlsView(
                    isRunning: viewModel.isRunning,
                    isFinished: viewModel.isFinished,
                    canStart: viewModel.selectedTimeInSeconds > 0 || viewModel.customMinutes > 0 || viewModel.customSeconds > 0, // <-- Новое условие
                    onStart: viewModel.start,
                    onPause: viewModel.pause,
                    onReset: viewModel.reset
                )
                
                Spacer()
                
                // Отображаем либо пресеты, либо пикер
                if !viewModel.isRunning && !viewModel.isFinished {
                    TimeSelectorView(
                        presets: timePresets,
                        selectedTime: $viewModel.selectedTimeInSeconds,
                        customMinutes: $viewModel.customMinutes,
                        customSeconds: $viewModel.customSeconds,
                        onCustomTimeChange: viewModel.switchToCustomTime
                    )
                }
                
            
                
                Spacer()
            }
            .padding()
        }
        .alert("Time's up!", isPresented: $viewModel.shouldShowFinishAlert) {
                   Button("OK", role: .cancel) {
                       // Алерт автоматически сбросит shouldShowFinishAlert в false,
                       // но мы можем здесь выполнить дополнительные действия, если нужно.
                   }
               } message: {
                   Text("Your timer has finished running.")
               }
        .preferredColorScheme(.dark)
    }
}

// --- НОВЫЙ УМНЫЙ КОМПОНЕНТ ДЛЯ ВЫБОРА ВРЕМЕНИ ---
struct TimeSelectorView: View {
    let presets: [Int]
    @Binding var selectedTime: Int
    @Binding var customMinutes: Int
    @Binding var customSeconds: Int
    var onCustomTimeChange: () -> Void
    
    var body: some View {
        VStack {
            TimePresetsView(presets: presets, selectedTime: $selectedTime)
            
            // Пикер появляется, только если не выбран ни один пресет
            if selectedTime == 0 {
                CustomTimePicker(
                    minutes: $customMinutes,
                    seconds: $customSeconds,
                    onInteraction: onCustomTimeChange
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
}

// --- КОМПОНЕНТ ДЛЯ ПИКЕРА ---
struct CustomTimePicker: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    var onInteraction: () -> Void

    let minuteRange = 0...59
    let secondRange = 0...59

    var body: some View {
        HStack(spacing: 0) {
            Picker("Minutes", selection: $minutes) {
                ForEach(minuteRange, id: \.self) { minute in
                    Text("\(minute)").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .onChange(of: minutes) { _ in onInteraction() }

            Text("min")
                .font(.headline)
                .foregroundColor(.appSecondaryText)

            Picker("Seconds", selection: $seconds) {
                ForEach(secondRange, id: \.self) { second in
                    Text("\(second)").tag(second)
                }
            }
            .pickerStyle(.wheel)
            .onChange(of: seconds) { _ in onInteraction() }

            Text("sec")
                .font(.headline)
                .foregroundColor(.appSecondaryText)
        }
        .frame(height: 150)
        .padding(.horizontal)
    }
}

// --- ОБНОВЛЕНИЕ СУЩЕСТВУЮЩИХ КОМПОНЕНТОВ ---

// Обновляем TimerCircleView, чтобы он корректно отображал время до старта
struct TimerCircleView: View {
    let progress: Double
    let timeString: String
    
    var body: some View {
        ZStack {
            Circle().stroke(Color.appCardBackground, lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress) // Используем .linear для плавной анимации
            
            Text(timeString)
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundColor(.appPrimaryText)
        }
    }
}

// Обновляем TimerControlsView, чтобы кнопка Start была неактивна, если время 0
struct TimerControlsView: View {
    let isRunning: Bool
    let isFinished: Bool
    let canStart: Bool // <-- Новое свойство
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: onReset) { Image(systemName: "arrow.counterclockwise.circle.fill") }
                .font(.system(size: 50))
                .foregroundColor(.appSecondaryText)
                .opacity(isFinished || isRunning ? 1.0 : 0.0)
                .animation(.easeInOut, value: isFinished || isRunning)
            
            Button(action: isRunning ? onPause : onStart) {
                ZStack {
                    Circle().fill(Color.appAccent)
                        .shadow(color: .appAccent.opacity(0.5), radius: 10, y: 5)
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.black)
                }
            }
            .frame(width: 80, height: 80)
            .disabled(isFinished || (!isRunning && !canStart)) // <-- Обновленное условие
            .opacity(isFinished || (!isRunning && !canStart) ? 0.5 : 1.0)
            
            Circle().fill(Color.clear).frame(width: 50, height: 50)
                .opacity(isFinished || isRunning ? 1.0 : 0.0)
                .animation(.easeInOut, value: isFinished || isRunning)
        }
    }
}


struct TimePresetsView: View {
    let presets: [Int]
    @Binding var selectedTime: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Select time")
                .font(.headline)
                .foregroundColor(.appSecondaryText)
            
            HStack(spacing: 16) {
                ForEach(presets, id: \.self) { timeInSeconds in
                    Button(action: {
                        withAnimation {
                            selectedTime = timeInSeconds
                        }
                    }) {
                        Text("\(timeInSeconds / 60) min")
                            .fontWeight(.bold)
                            .padding()
                            .background(selectedTime == timeInSeconds ? Color.appAccent : Color.appCardBackground)
                            .foregroundColor(selectedTime == timeInSeconds ? .black : .appPrimaryText)
                            .clipShape(Capsule())
                            .frame(height: 100)
                    }
                }
            }
        }
    }
}


struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
