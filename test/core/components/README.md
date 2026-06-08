
# 🧪 Widget Testing Guide - TechJobs App

## Visão Geral

Este diretório contém testes de widget para os componentes do TechJobs. Os testes garantem que os componentes funcionam corretamente e detectam regressões durante o desenvolvimento.

## 📁 Estrutura

```
test/
└── core/
    └── components/
        ├── custom_button_test.dart              ✅ 7 testes
        ├── custom_input_field_test.dart         ✅ 9 testes
        ├── custom_app_bar_test.dart.example     📋 Exemplo
        └── README.md                            (este arquivo)
```

## 🚀 Como Executar os Testes

### Executar todos os testes de componentes
```bash
flutter test test/core/components/
```

### Executar teste específico
```bash
flutter test test/core/components/custom_button_test.dart
```

### Executar em watch mode (auto-reload ao salvar)
```bash
flutter test --watch test/core/components/
```

### Gerar relatório de cobertura
```bash
flutter test --coverage test/core/components/
```

## 📖 Padrão de Teste

Todos os testes seguem o padrão **AAA (Arrange-Act-Assert)**:

```dart
testWidgets('Descrição do teste', (WidgetTester tester) async {
  // ARRANGE: Preparar o widget e seus dados
  final controller = TextEditingController();
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CustomInputField(
          controller: controller,
          label: 'Email',
        ),
      ),
    ),
  );

  // ACT: Executar a ação (tap, input, etc)
  await tester.enterText(find.byType(TextField), 'test@example.com');

  // ASSERT: Verificar o resultado
  expect(controller.text, 'test@example.com');
});
```

## 🎯 Criando Novos Testes

### Template Básico

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techjobs/core/components/seu_widget.dart';

void main() {
  group('SeuWidget Tests', () {
    testWidgets('Descrição do teste', (WidgetTester tester) async {
      // Seu teste aqui
    });
  });
}
```

### Dicas Úteis

1. **Use `find` para localizar widgets:**
   ```dart
   find.byType(Button)           // Por tipo
   find.text('Label')            // Por texto
   find.byIcon(Icons.add)        // Por ícone
   find.byKey(Key('myKey'))      // Por key
   ```

2. **Interações com o usuário:**
   ```dart
   await tester.tap(find.byType(Button));
   await tester.enterText(find.byType(TextField), 'text');
   await tester.pumpWidget(...);  // Renderizar/re-renderizar
   await tester.pump();           // Atualizar animações
   ```

3. **Assertions comuns:**
   ```dart
   expect(find.text('text'), findsOneWidget);
   expect(find.text('text'), findsNothing);
   expect(find.text('text'), findsWidgets);
   ```

## ✅ Checklist para Novo Teste

- [ ] Teste tem um nome descritivo
- [ ] Teste cobre um único comportamento
- [ ] Teste usa `MaterialApp` para contexto
- [ ] Teste limpa recursos (controllers, focusNodes)
- [ ] Teste não depende de outros testes
- [ ] Teste passa localmente
- [ ] Teste é adicionado a um `group()`

## 🔗 Referências

- [Flutter Testing Documentation](https://flutter.dev/docs/testing/unit-test)
- [WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)
- [Widget Test Best Practices](https://codewithandrea.com/articles/flutter-widget-testing/)

## 📚 Próximos Testes a Implementar

### Alta Prioridade
- [ ] `custom_app_bar_test.dart` - Testes para AppBar
- [ ] Integration tests - Fluxos de usuário completos
- [ ] `feed_page_test.dart` - Página principal

### Média Prioridade
- [ ] `search_page_test.dart` - Busca de vagas
- [ ] `profile_page_test.dart` - Perfil do usuário
- [ ] Model tests - `job_model_test.dart`

### Baixa Prioridade
- [ ] `candidate_controller_test.dart` - Lógica de negócio
- [ ] State tests - `app_state_test.dart`

## 💡 Troubleshooting

### Teste não encontra widget
```dart
// Verifique se o widget está no widget tree
await tester.pumpWidget(
  MaterialApp(  // ← Necessário para contexto
    home: Scaffold(
      body: SeuWidget(),
    ),
  ),
);
```

### `byHint` não funciona
```dart
// byHint não existe, use byType ao invés
find.byType(TextField)  // ✓ Correto
find.byHint('hint')     // ✗ Não existe
```

### Teste fica muito lento
```dart
// Use --timeout para definir limite de tempo
flutter test --timeout=30s test/core/components/
```

## 📞 Contato

Para dúvidas ou sugestões sobre os testes, abra uma issue no repositório.

---

**Última atualização**: 26 de Maio de 2026
**Status**: ✅ Testes ativos e em manutenção
