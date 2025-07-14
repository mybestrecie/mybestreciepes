//
//  TimerViewModel.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

import Foundation
//  TimerViewModel.swift
import Foundation
import Combine

@MainActor
class TimerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedTimeInSeconds: Int = 0
    @Published var remainingTime: Int = 0
    @Published var progress: Double = 0.0
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    @Published var customMinutes: Int = 0
        @Published var customSeconds: Int = 0
    @Published var shouldShowFinishAlert: Bool = false
    // MARK: - Private Properties
    private var timerSubscription: AnyCancellable?
    private var initialTime: Int = 0

    init() {
            // Добавляем подписчик, который будет обновлять selectedTimeInSeconds
            // каждый раз, когда меняется customMinutes или customSeconds.
            setupSubscribers()
        }
    
    // MARK: - Computed Properties
    
    // Форматирует оставшееся время в строку MM:SS
    var timeString: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Public Methods
    
    // Запуск таймера
    func start() {
            // Если время не выбрано из пресетов, используем кастомное
            if selectedTimeInSeconds == 0 {
                let totalCustomTime = (customMinutes * 60) + customSeconds
                guard totalCustomTime > 0 else { return }
                selectedTimeInSeconds = totalCustomTime
            }
            
            guard selectedTimeInSeconds > 0 else { return }
            
            initialTime = selectedTimeInSeconds
            remainingTime = selectedTimeInSeconds
            progress = 1.0
            isRunning = true
            isFinished = false
            
            timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.tick()
                }
        }
    
    // Пауза таймера
    func pause() {
        isRunning = false
        timerSubscription?.cancel()
    }
    
    // Возобновление таймера
    func resume() {
        guard remainingTime > 0 else { return }
        isRunning = true
        // Пересоздаем подписку, чтобы таймер пошел снова
        start()
        // Восстанавливаем initialTime, так как start() его сбрасывает
        initialTime = selectedTimeInSeconds
    }
    
    // Сброс таймера
    func reset() {
          isRunning = false
          isFinished = false
          shouldShowFinishAlert = false // <-- Добавляем сброс
          timerSubscription?.cancel()
          selectedTimeInSeconds = 0
          remainingTime = 0
          progress = 0.0
      }
        
    
    // MARK: - Private Methods
    
    // Действие, выполняемое каждую секунду
    private func tick() {
            guard isRunning else { return }
            
            if remainingTime > 0 {
                remainingTime -= 1
                progress = Double(remainingTime) / Double(initialTime)
            } else {
                // Таймер завершен
                isRunning = false
                isFinished = true
                timerSubscription?.cancel()
                
                // --- УСТАНАВЛИВАЕМ ФЛАГ ДЛЯ ПОКАЗА АЛЕРТА ---
                shouldShowFinishAlert = true
                // ---
            }
        }
    
    func switchToCustomTime() {
           if selectedTimeInSeconds != 0 {
               selectedTimeInSeconds = 0
           }
       }
    
    private func setupSubscribers() {
           // Этот подписчик следит за изменением кастомного времени
           // и обновляет общее количество секунд, если не выбран пресет.
           $customMinutes.combineLatest($customSeconds)
               .sink { [weak self] (minutes, seconds) in
                   guard let self = self else { return }
                   // Обновляем общее время только если не выбран пресет
                   if self.selectedTimeInSeconds == 0 {
                       self.remainingTime = (minutes * 60) + seconds
                   }
               }
               .store(in: &cancellables) // <-- Добавьте private var cancellables = Set<AnyCancellable>()
       }
       // <-- Не забудьте добавить эту строку в класс:
       private var cancellables = Set<AnyCancellable>()
}
