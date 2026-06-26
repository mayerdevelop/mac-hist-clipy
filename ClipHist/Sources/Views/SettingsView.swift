import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @AppStorage("maxItems") private var maxItems: Int = 100
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false

    var body: some View {
        Form {
            Section("Geral") {
                Toggle("Iniciar com o sistema", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) {
                        updateLaunchAtLogin(launchAtLogin)
                    }

                Picker("Maximo de itens no historico:", selection: $maxItems) {
                    Text("25").tag(25)
                    Text("50").tag(50)
                    Text("100").tag(100)
                    Text("200").tag(200)
                    Text("500").tag(500)
                }
            }

            Section("Permissoes") {
                HStack {
                    if Accessibility.isTrusted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Acessibilidade concedida")
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Acessibilidade necessaria")
                        Spacer()
                        Button("Solicitar") {
                            Accessibility.requestIfNeeded()
                        }
                    }
                }
            }

            Section("Atalho") {
                HStack {
                    Text("Abrir historico:")
                    Spacer()
                    Text("⌘ ⇧ V")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }

            Section("Sobre") {
                HStack {
                    Text("ClipHist")
                        .font(.headline)
                    Spacer()
                    Text("v1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 350)
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}
