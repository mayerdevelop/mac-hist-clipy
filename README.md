# ClipHist - Historico da Area de Transferencia para macOS

Aplicacao nativa macOS que monitora a area de transferencia e exibe um historico via atalho global, similar ao Windows+V do Windows.

## Funcionalidades

- **Cmd+V** continua funcionando normalmente (colar direto)
- **Cmd+Shift+V** abre o painel flutuante com o historico de tudo que foi copiado
- Busca por texto no historico
- Selecao rapida com teclas 1-9
- Icone na barra de menus com acesso rapido
- Suporte a dark mode nativo
- Sem dependencias externas

## Requisitos

- macOS 13 Ventura ou superior
- Xcode 16+ (para build)
- Permissao de Acessibilidade (solicitada na primeira execucao)

## Como Compilar

### Opcao 1: Via Xcode

1. Instale o [XcodeGen](https://github.com/yonaskolb/XcodeGen):
   ```bash
   brew install xcodegen
   ```

2. Gere o projeto Xcode:
   ```bash
   xcodegen generate
   ```

3. Abra `ClipHist.xcodeproj` no Xcode

4. Build e Run (Cmd+R)

### Opcao 2: Via Makefile

```bash
make project   # Gera o .xcodeproj (instala xcodegen se necessario)
make build     # Compila o app
make run       # Compila e abre o app
make clean     # Limpa build e projeto gerado
```

## Uso

1. Ao abrir o app, um icone de clipboard aparece na barra de menus
2. Copie textos normalmente com **Cmd+C** em qualquer aplicativo
3. Pressione **Cmd+Shift+V** para abrir o historico
4. Clique em um item ou pressione **1-9** para colar rapidamente
5. O painel fecha automaticamente apos colar
6. Pressione **Esc** para fechar o painel sem colar

## Permissoes

Na primeira execucao, o app solicita permissao de **Acessibilidade** do macOS. Isso e necessario para:
- Capturar o atalho global Cmd+Shift+V em qualquer app
- Simular Cmd+V para colar no app ativo

Voce pode conceder em: Ajustes do Sistema > Privacidade e Seguranca > Acessibilidade

## Estrutura do Projeto

```
ClipHist/
  Sources/
    ClipHistApp.swift              -- Ponto de entrada, MenuBarExtra
    Models/
      ClipboardItem.swift          -- Modelo de item copiado
      ClipboardStore.swift         -- Armazenamento em memoria
    Services/
      ClipboardMonitor.swift       -- Monitoramento do clipboard
      HotKeyManager.swift          -- Atalho global Cmd+Shift+V
      PasteService.swift           -- Cola no app ativo
      Accessibility.swift          -- Verifica permissoes
    Views/
      ClipboardHistoryPanel.swift  -- Painel flutuante
      ClipboardListView.swift      -- Lista principal
      ClipboardRowView.swift       -- Linha de cada item
      MenuBarView.swift            -- Menu da barra de menus
      SettingsView.swift           -- Preferencias
  Resources/
    Info.plist
    ClipHist.entitlements
    Assets.xcassets/
```

## Licenca

MIT
