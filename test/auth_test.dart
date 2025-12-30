
// Importuje potřebné balíčky pro testování a mockování.
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/auth_service.dart'; // Importuje tvůj AuthService
import 'package:provider/provider.dart';

// Importuje vygenerovaný soubor s mocky. Tento soubor se vytvoří po spuštění build_runner.
import 'auth_test.mocks.dart';

// Anotace, která říká build_runneru, aby vygeneroval mock třídy pro AuthService a User.
@GenerateMocks([AuthService, User])
void main() {
  // Deklarujeme proměnné pro naše mock objekty.
  // Názvy tříd pocházejí z vygenerovaného souboru (MockAuthService, MockUser).
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  // setUp se spustí před každým jednotlivým testem.
  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();

    // Musíme také nastavit, co budou vracet gettery našeho falešného uživatele.
    when(mockUser.uid).thenReturn('mock_uid');
    when(mockUser.email).thenReturn('mock.user@example.com');
  });

  // Zde definujeme testovací funkci pro widget.
  testWidgets('AuthFlow Test: Zobrazení emailu přihlášeného uživatele', (WidgetTester tester) async {
    // KROK 1: Nastavení mocku
    // Říkáme našemu falešnému AuthService, aby při jakémkoliv volání streamu `authStateChanges`
    // vrátil stream, který okamžitě vydá náš falešný `mockUser`.
    // Tím simulujeme, že uživatel je již přihlášen.
    when(mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

    // KROK 2: "Nafouknutí" widgetu
    // Zabalíme testovaný widget do Provideru, abychom mu mohli podstrčit náš falešný `mockAuthService`.
    // Dále přidáme MaterialApp, protože widgety jako Scaffold ho vyžadují.
    await tester.pumpWidget(
      Provider<AuthService>.value(
        value: mockAuthService,
        child: const MaterialApp(
          home: AuthenticatedScreen(), // Náš testovaný widget
        ),
      ),
    );

    // KROK 3: Počkáme, až se stream zpracuje a UI se překreslí
    await tester.pump();

    // KROK 4: Ověření výsledku
    // Najdeme widget, který zobrazuje text (email uživatele) a ověříme, že se skutečně zobrazil.
    expect(find.text('Přihlášen jako: mock.user@example.com'), findsOneWidget);
    expect(find.text('UID: mock_uid'), findsOneWidget);
  });
}

// Jednoduchý ukázkový widget, který potřebuje přihlášeného uživatele.
// Tento widget by normálně byl součástí tvé aplikace.
class AuthenticatedScreen extends StatelessWidget {
  const AuthenticatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Získáme AuthService z Provideru. V našem testu to bude MockAuthService.
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      // StreamBuilder poslouchá na změny přihlášení.
      body: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          // Pokud stream ještě nic nevrátil, zobrazíme načítání.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Pokud stream vrátil data (přihlášeného uživatele), zobrazíme jeho info.
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Přihlášen jako: ${user.email ?? 'Neznámý email'}'),
                  Text('UID: ${user.uid}'),
                ],
              ),
            );
          }
          // Pokud uživatel není přihlášen, zobrazíme jinou zprávu.
          return const Center(child: Text('Nikdo není přihlášen.'));
        },
      ),
    );
  }
}
