import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

// ============================================
// SERVER CONFIGURATION
// Update SERVER_IP whenever your IP changes
// ============================================

const String PHP_API_URL = "https://jungle-professor-flutter.alwaysdata.net/server/api";
const String WEBSOCKET_URL = "wss://jungle-professor-flutter.alwaysdata.net/wss";

// ============================================
// BACKGROUND SLIDESHOW IMAGE LISTS
// Add more images by copying files to the
// images/general, images/jungle, images/city
// folders and adding the filename below
// ============================================

const List<String> kGeneralImages = [
  // Used on: HomePage, LoginPage, SignupPage, WelcomePage, GameSelectionPage
  'images/general/andrea-cau-nV7GJmSq3zc-unsplash.jpg',
  'images/general/boris-smokrovic-DPXytK8Z59Y-unsplash.jpg',
  'images/general/denys-nevozhai-HhmCIJTLuGY-unsplash.jpg',
  'images/general/gary-bendig-6GMq7AGxNbE-unsplash.jpg',
  'images/general/gwen-weustink-I3C1sSXj1i8-unsplash.jpg',
  'images/general/hans-jurgen-mager-Fbdr6gXJBVY-unsplash.jpg',
  'images/general/jonatan-pie-xgTMSz6kegE-unsplash.jpg',
  'images/general/matthew-henry-VviFtDJakYk-unsplash.jpg',
  'images/general/pedro-lastra-Nyvq2juw4_o-unsplash.jpg',
  'images/general/premium_photo-1669725687137-75f7a1377720.jpg',
  'images/general/sid-balachandran-_9a-3NO5KJE-unsplash.jpg',
  'images/general/wexor-tmg-L-2p8fapOA8-unsplash.jpg',
];

const List<String> kJungleImages = [
  // Used on: GamePage when gameType == 'jungle'
  'images/jungle/boris-smokrovic-DPXytK8Z59Y-unsplash.jpg',
  'images/jungle/gary-bendig-6GMq7AGxNbE-unsplash.jpg',
  'images/jungle/gwen-weustink-I3C1sSXj1i8-unsplash.jpg',
  'images/jungle/hans-jurgen-mager-Fbdr6gXJBVY-unsplash.jpg',
  'images/jungle/jonatan-pie-xgTMSz6kegE-unsplash.jpg',
  'images/jungle/premium_photo-1669725687137-75f7a1377720.jpg',
  'images/jungle/sid-balachandran-_9a-3NO5KJE-unsplash.jpg',
  'images/jungle/wexor-tmg-L-2p8fapOA8-unsplash.jpg',
];

const List<String> kCityImages = [
  // Used on: GamePage when gameType == 'city'
  'images/city/andrea-cau-nV7GJmSq3zc-unsplash.jpg',
  'images/city/denys-nevozhai-HhmCIJTLuGY-unsplash.jpg',
  'images/city/matthew-henry-VviFtDJakYk-unsplash.jpg',
  'images/city/pedro-lastra-Nyvq2juw4_o-unsplash.jpg',
];

// ============================================
// GREEN THEME COLORS
// ============================================
const kGreenDark    = Color(0xFF145a32);
const kGreenMid     = Color(0xFF1e8449);
const kGreenBright  = Color(0xFF2ecc71);
const kGreenLight   = Color(0xFFa9dfbf);
const kBgDark       = Color(0xFF0a1a0a);

// ============================================
// BACKGROUND SLIDESHOW WIDGET
// Wrap any screen body with BackgroundSlideshow
// ============================================
class BackgroundSlideshow extends StatefulWidget {
  final Widget child;
  final String type; // 'general', 'jungle', or 'city'

  const BackgroundSlideshow({
    Key? key,
    required this.child,
    this.type = 'general',
  }) : super(key: key);

  @override
  _BackgroundSlideshowState createState() => _BackgroundSlideshowState();
}

class _BackgroundSlideshowState extends State<BackgroundSlideshow> {
  int _currentIndex = 0;
  Timer? _timer;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = widget.type == 'jungle'
        ? kJungleImages
        : widget.type == 'city'
            ? kCityImages
            : kGeneralImages;

    if (_images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _images.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image with crossfade
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 1500),
          child: Container(
            key: ValueKey(_currentIndex),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_images[_currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Dark overlay for readability
        Container(color: Colors.black.withOpacity(0.55)),
        // Page content
        widget.child,
      ],
    );
  }
}

// ============================================
// MAIN
// ============================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  runApp(MyApp(initialRoute: username == null ? '/' : '/welcome'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jungle Professor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBgDark,
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: kGreenDark,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kGreenMid,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          labelStyle: const TextStyle(color: kGreenLight),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kGreenMid),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kGreenBright, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/welcome': (context) => const WelcomePage(),
        '/select_game': (context) => const GameSelectionPage(),
        '/saved_results': (context) => const SavedResultsListPage(),
      },
    );
  }
}

// ============================================
// APP MENU
// ============================================
enum MenuAction { home, signup, login, logout, myResults }

class AppMenu extends StatelessWidget implements PreferredSizeWidget {
  final List<MenuAction> actions;
  final String title;

  const AppMenu({Key? key, required this.title, required this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Text('🌿 ', style: TextStyle(fontSize: 20)),
          Text(title),
        ],
      ),
      backgroundColor: kGreenDark.withOpacity(0.9),
      actions: [
        PopupMenuButton<MenuAction>(
          color: kGreenDark,
          onSelected: (MenuAction action) async {
            switch (action) {
              case MenuAction.home:
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
                break;
              case MenuAction.login:
                Navigator.of(context).pushNamed('/login');
                break;
              case MenuAction.signup:
                Navigator.of(context).pushNamed('/signup');
                break;
              case MenuAction.logout:
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
                break;
              case MenuAction.myResults:
                Navigator.of(context).pushNamed('/saved_results');
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return actions.map((MenuAction choice) {
              String text = '';
              IconData icon = Icons.home;
              switch (choice) {
                case MenuAction.home:
                  text = 'Home';
                  icon = Icons.home;
                  break;
                case MenuAction.login:
                  text = 'Login';
                  icon = Icons.login;
                  break;
                case MenuAction.signup:
                  text = 'Sign Up';
                  icon = Icons.person_add;
                  break;
                case MenuAction.logout:
                  text = 'Logout';
                  icon = Icons.logout;
                  break;
                case MenuAction.myResults:
                  text = 'My Results';
                  icon = Icons.history;
                  break;
              }
              return PopupMenuItem<MenuAction>(
                value: choice,
                child: Row(
                  children: [
                    Icon(icon, color: kGreenBright, size: 18),
                    const SizedBox(width: 10),
                    Text(text, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ============================================
// HOME PAGE
// ============================================
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppMenu(
          title: 'Jungle Professor',
          actions: [MenuAction.login, MenuAction.signup]),
      body: BackgroundSlideshow(
        type: 'general',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌿',
                    style: TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                Text(
                  'Jungle Professor',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: kGreenBright, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'A Universal Home Study Guide\nin a World Safari Game',
                  style: TextStyle(fontSize: 16, color: kGreenLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGreenBright,
                    side: const BorderSide(color: kGreenBright),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('Sign Up',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// LOGIN PAGE
// ============================================
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$PHP_API_URL/login.php'),
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );
      if (mounted) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', data['username']);
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/welcome', (route) => false);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['message'])));
        }
      }
    } catch (e) {
      print("Server error: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Could not connect to server.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppMenu(
          title: 'Login',
          actions: [MenuAction.home, MenuAction.signup]),
      body: BackgroundSlideshow(
        type: 'general',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.45),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: kGreenBright.withOpacity(0.6), width: 1.5),
    boxShadow: [
        BoxShadow(
            color: kGreenBright.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
        ),
    ],
),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌿',
                      style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  const Text('Login',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: kGreenBright)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator(color: kGreenBright)
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: _login,
                              child: const Text('Sign In')),
                        ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text('New here? Sign Up',
                        style: TextStyle(color: kGreenLight)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// SIGNUP PAGE
// ============================================
class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$PHP_API_URL/signup.php'),
        body: {
          'username': _usernameController.text.trim(),
          'email':    _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );
      if (mounted) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', data['username']);
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/welcome', (route) => false);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['message'])));
        }
      }
    } catch (e) {
      print("Server error: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error: Could not connect to server.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppMenu(
          title: 'Sign Up',
          actions: [MenuAction.home, MenuAction.login]),
      body: BackgroundSlideshow(
        type: 'general',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: kGreenBright.withOpacity(0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: kGreenBright.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: kGreenBright),
                  ),
                  const SizedBox(height: 24),

                  // Username
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),

                  _isLoading
                      ? const CircularProgressIndicator(
                          color: kGreenBright)
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signup,
                            child:
                                const Text('Create Account & Play'),
                          ),
                        ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: kGreenLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// WELCOME PAGE
// ============================================
class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String _username = 'Player';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _username = prefs.getString('username') ?? 'Player';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppMenu(
          title: 'Jungle Professor',
          actions: const [MenuAction.myResults, MenuAction.logout]),
      body: BackgroundSlideshow(
        type: 'general',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌿', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                'Welcome, $_username!',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kGreenBright),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready for your next adventure?',
                style: TextStyle(color: kGreenLight, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/select_game'),
                icon: const Icon(Icons.sports_esports),
                label: const Text('Choose Game'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGreenBright,
                  side: const BorderSide(color: kGreenBright),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/saved_results'),
                icon: const Icon(Icons.history),
                label: const Text('My Results',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// GAME SELECTION PAGE
// ============================================
class GameSelectionPage extends StatefulWidget {
  const GameSelectionPage({Key? key}) : super(key: key);
  @override
  _GameSelectionPageState createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage> {
  String _statusMessage = '';
  bool _isFindingGame = false;
  WebSocketChannel? _channel;
  StreamController<String>? _broadcastController;
  StreamSubscription? _streamListener;
  String? _clientId;
  String? _playerIdentifier;
  bool _connectionHandedOff = false;

  @override
  void dispose() {
    if (!_connectionHandedOff) {
      _streamListener?.cancel();
      _broadcastController?.close();
      _channel?.sink.close();
    }
    super.dispose();
  }

  void _findGame(String gameType) {
    setState(() {
      _isFindingGame = true;
      _statusMessage = 'Connecting to game server...';
      _connectionHandedOff = false;
    });

    _channel = WebSocketChannel.connect(Uri.parse(WEBSOCKET_URL));
    _broadcastController = StreamController<String>.broadcast();

    _channel!.stream.listen(
      (message) {
        if (!(_broadcastController?.isClosed ?? true))
          _broadcastController!.add(message);
      },
      onDone: () {
        if (mounted && !_connectionHandedOff) {
          setState(() {
            _isFindingGame = false;
            _statusMessage = 'Connection lost. Please try again.';
          });
        }
        if (!(_broadcastController?.isClosed ?? true))
          _broadcastController!.close();
      },
      onError: (error) {
        if (mounted && !_connectionHandedOff) {
          setState(() {
            _isFindingGame = false;
            _statusMessage = 'Connection error.';
          });
        }
        if (!(_broadcastController?.isClosed ?? true))
          _broadcastController!.addError(error);
      },
    );

    _streamListener = _broadcastController!.stream.listen((message) {
      if (!mounted) return;
      final data = jsonDecode(message);
      final method = data['method'];

      if (method == 'connect') {
        _clientId = data['clientId'];
        setState(() => _statusMessage = 'Finding a $gameType game...');
        _channel!.sink.add(jsonEncode({
          'method': 'find_game',
          'clientId': _clientId,
          'gameType': gameType
        }));
      } else if (method == 'join') {
        _playerIdentifier = data['player'];
        setState(() => _statusMessage = 'Joined! Waiting for players...');
      } else if (method == 'start') {
        _streamListener?.cancel();
        _connectionHandedOff = true;
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(
                channel: _channel!,
                stream: _broadcastController!.stream,
                gameId: data['game']['id'],
                clientId: _clientId!,
                player: _playerIdentifier!,
                gameType: gameType,
                initialGameData: data,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Select a Game'),
        backgroundColor: kGreenDark.withOpacity(0.9),
      ),
      body: BackgroundSlideshow(
        type: 'general',
        child: Center(
          child: _isFindingGame
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: kGreenBright),
                    const SizedBox(height: 20),
                    Text(_statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: kGreenLight, fontSize: 16)),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Choose Your Adventure',
                        style: TextStyle(
                            color: kGreenBright,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kGreenMid,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 18)),
                      onPressed: () => _findGame('jungle'),
                      icon: const Text('🦁',
                          style: TextStyle(fontSize: 24)),
                      label: const Text('Jungle Professor',
                          style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1a5276),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 18)),
                      onPressed: () => _findGame('city'),
                      icon: const Text('🏙️',
                          style: TextStyle(fontSize: 24)),
                      label: const Text('City Tour',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ============================================
// GAME PAGE
// ============================================
class GamePage extends StatefulWidget {
  final WebSocketChannel channel;
  final Stream<String> stream;
  final String gameId;
  final String clientId;
  final String player;
  final String gameType;
  final Map<String, dynamic> initialGameData;

  const GamePage({
    required this.channel,
    required this.stream,
    required this.gameId,
    required this.clientId,
    required this.player,
    required this.gameType,
    required this.initialGameData,
    Key? key,
  }) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late double minDimension = 0;

  StreamSubscription? _gamePageListener;

  String gameStatus = 'playing';
  int currentPlayerIndex = 0;
  Map<String, int> playerSteps = {};
  int totalPlayers = 0;
  String _lastEventText = "Game has started!";

  bool _isPopupVisible = false;
  List<Map<String, dynamic>> _currentResults = [];

  // Question dialog state
  String _questionAnswerError = '';
  bool _isSubmittingAnswer = false;

  // Belongs only to the currently displayed dialog
  StateSetter? _questionDialogSetState;

  // Used to identify the currently displayed question dialog
  int _questionDialogId = 0;

  final List<Color> playerColors = [
    Colors.blue,
    Colors.yellow,
    Colors.red,
    Colors.green,
  ];

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _updateStateFromServer(widget.initialGameData);

    _gamePageListener = widget.stream.listen(
      (message) {
        if (!mounted) return;

        final data = jsonDecode(message);
        final method = data['method'];

        if (method == 'update') {
          _updateStateFromServer(data);
        }

        // ----------------------------------------------------
        // NEW QUESTION
        // ----------------------------------------------------
        else if (method == 'ask_question') {
          _showQuestionPopup(data);
        }

        // ----------------------------------------------------
        // ANSWER RESULT
        // ----------------------------------------------------
        else if (method == 'answer_result') {
          print('[WS IN] answer_result: $data');

          final bool correct = data['correct'] == true;

          if (correct) {
            // Server will send the next ask_question if there
            // is another question — just close this dialog
            _closeQuestionPopup();
          } else {
            // Wrong answer — keep dialog open, show error
            final String errorMessage =
                data['message']?.toString() ??
                    'Incorrect answer. Try again.';

            if (_questionDialogSetState != null) {
              _questionDialogSetState!(() {
                _questionAnswerError = errorMessage;
                _isSubmittingAnswer = false;
              });
            } else {
              setState(() {
                _questionAnswerError = errorMessage;
                _isSubmittingAnswer = false;
              });
            }
          }
        }

        // ----------------------------------------------------
        // GAME OVER
        // ----------------------------------------------------
        else if (method == 'game_over') {
          _closeQuestionPopup();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                results: List<Map<String, dynamic>>.from(
                    data['results']),
                gameType: data['gameType'] ?? widget.gameType,
                player: widget.player,
              ),
            ),
          );
        }
      },

      // WebSocket closed
      onDone: () {
        if (mounted && !_isPopupVisible) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                results: _currentResults,
                gameType: widget.gameType,
                player: widget.player,
              ),
            ),
          );
        }
      },
    );
  }

  // ============================================================
  // CLOSE QUESTION DIALOG
  // ============================================================

  void _closeQuestionPopup() {
    if (!_isPopupVisible) return;

    final int closingDialogId = _questionDialogId;

    _questionDialogSetState = null;
    _isSubmittingAnswer = false;

    if (mounted) {
      setState(() {
        _isPopupVisible = false;
      });
    }

    Navigator.of(context, rootNavigator: true).pop();

    print('[DIALOG] Closed question dialog #$closingDialogId');
  }

  // ============================================================
  // SHOW QUESTION POPUP — handles race condition between
  // questions by waiting for previous dialog to close first
  // ============================================================

  void _showQuestionPopup(Map<String, dynamic> data) {
    if (!mounted) return;

    if (_isPopupVisible) {
      _closeQuestionPopup();
      // Wait for the previous dialog to fully close before
      // opening the next one
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _openDialog(data);
      });
      return;
    }

    _openDialog(data);
  }

  // ============================================================
  // OPEN DIALOG — the actual dialog builder
  // ============================================================

  void _openDialog(Map<String, dynamic> data) {
    if (!mounted) return;

    final int dialogId = ++_questionDialogId;

    setState(() {
      _isPopupVisible = true;
      _questionAnswerError = '';
      _isSubmittingAnswer = false;
    });

    final String question =
        data['question']?.toString() ?? '';
    final String playerAnswering =
        data['playerAnswering']?.toString() ?? '';
    final int qNum =
        int.tryParse(data['questionNumber']?.toString() ?? '') ?? 1;
    final int qTotal =
        int.tryParse(data['totalQuestions']?.toString() ?? '') ?? 1;
    final answerController = TextEditingController();
    final bool amIAnswering = widget.player == playerAnswering;

    print(
      '[DIALOG] Opening question $qNum/$qTotal '
      'for $playerAnswering '
      '(I am ${widget.player}) '
      'dialogId=$dialogId',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext dialogContext,
            StateSetter dialogSetState,
          ) {
            // Only register setter if this is still the
            // current question dialog
            if (dialogId == _questionDialogId) {
              _questionDialogSetState = dialogSetState;
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF0d2b0d),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Question $qNum of $qTotal\n"
                "for ${playerAnswering.toUpperCase()}",
                style: const TextStyle(
                  color: kGreenBright,
                  fontSize: 16,
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ------------------------------------------
                    // THIS PLAYER IS ANSWERING
                    // ------------------------------------------
                    if (amIAnswering) ...[
                      TextField(
                        controller: answerController,
                        autofocus: true,
                        enabled: !_isSubmittingAnswer,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Your Answer',
                          labelStyle: const TextStyle(
                            color: kGreenLight,
                          ),
                          enabledBorder:
                              const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: kGreenLight,
                            ),
                          ),
                          focusedBorder:
                              const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: kGreenBright,
                            ),
                          ),
                        ),
                      ),

                      // Wrong answer error message
                      if (_questionAnswerError.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _questionAnswerError,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ]

                    // ------------------------------------------
                    // OTHER PLAYER IS ANSWERING
                    // ------------------------------------------
                    else
                      const Text(
                        "Waiting for their answer...",
                        style: TextStyle(color: kGreenLight),
                      ),
                  ],
                ),
              ),
              actions: [
                if (amIAnswering)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreenMid,
                    ),
                    onPressed: _isSubmittingAnswer
                        ? null
                        : () {
                            final String answer =
                                answerController.text.trim();

                            if (answer.isEmpty) {
                              dialogSetState(() {
                                _questionAnswerError =
                                    'Please enter an answer.';
                              });
                              return;
                            }

                            dialogSetState(() {
                              _isSubmittingAnswer = true;
                              _questionAnswerError = '';
                            });

                            // Do NOT close dialog here —
                            // server decides if answer is correct
                            _sendAnswer(answer);
                          },
                    child: _isSubmittingAnswer
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit'),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Only clean up if this is still the current dialog
      if (dialogId == _questionDialogId) {
        _questionDialogSetState = null;
        if (mounted) {
          setState(() {
            _isPopupVisible = false;
            _isSubmittingAnswer = false;
          });
        }
      }
      answerController.dispose();
      print(
        '[DIALOG] Dialog #$dialogId closed '
        '(current=$_questionDialogId)',
      );
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _gamePageListener?.cancel();
    widget.channel.sink.close();
    super.dispose();
  }

  // ============================================================
  // UPDATE GAME STATE FROM SERVER
  // ============================================================

  void _updateStateFromServer(Map<String, dynamic> data) {
    final game = data['game'];
    if (game == null || game['state'] == null) return;

    final gameState = game['state'];
    final clients = game['clients'] as List? ?? [];

    if (mounted) {
      setState(() {
        final String previousStatus = gameStatus;

        gameStatus = gameState['status'] ?? 'playing';
        totalPlayers = clients.length;
        currentPlayerIndex =
            gameState['currentPlayerIndex'] ?? 0;
        _lastEventText = gameState['lastEvent'] ?? "Your turn!";

        if (gameState['answeredQuestions'] != null) {
          _currentResults = List<Map<String, dynamic>>.from(
            gameState['answeredQuestions'],
          );
        }

        final newPlayerSteps = <String, int>{};
        for (var client in clients) {
          final String playerKey = client['player'];
          if (gameState[playerKey] != null &&
              gameState[playerKey]['steps'] != null) {
            newPlayerSteps[playerKey] =
                gameState[playerKey]['steps'];
          }
        }
        playerSteps = newPlayerSteps;

        // When quiz ends, server changes status from
        // answering_question -> playing and broadcasts to both
        // players, so both can close their dialogs here
        if (previousStatus == 'answering_question' &&
            gameStatus == 'playing' &&
            _isPopupVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isPopupVisible) {
              _closeQuestionPopup();
            }
          });
        }
      });
    }
  }

  // ============================================================
  // SEND PLAY REQUEST
  // ============================================================

  void _sendPlayRequest() {
    widget.channel.sink.add(
      jsonEncode({
        'method': 'play',
        'clientId': widget.clientId,
        'gameId': widget.gameId,
      }),
    );
  }

  // ============================================================
  // SEND ANSWER
  // ============================================================

  void _sendAnswer(String answer) {
    final payload = {
      'method': 'submit_answer',
      'clientId': widget.clientId,
      'gameId': widget.gameId,
      'answer': answer,
    };
    print('[WS OUT] submit_answer: $payload');
    widget.channel.sink.add(jsonEncode(payload));
  }

  // ============================================================
  // BOARD COORDINATES
  // ============================================================

  Offset calculatePlayerPosition(int steps, String gameType) {
    const Map<int, Offset> jungleCoords = {
      1:  Offset(0.066, 0.863), 2:  Offset(0.237, 0.863),
      3:  Offset(0.345, 0.863), 4:  Offset(0.466, 0.863),
      5:  Offset(0.578, 0.863), 6:  Offset(0.690, 0.863),
      7:  Offset(0.855, 0.863), 8:  Offset(0.855, 0.696),
      9:  Offset(0.855, 0.580), 10: Offset(0.855, 0.470),
      11: Offset(0.855, 0.353), 12: Offset(0.855, 0.239),
      13: Offset(0.855, 0.066), 14: Offset(0.688, 0.066),
      15: Offset(0.578, 0.066), 16: Offset(0.459, 0.066),
      17: Offset(0.343, 0.066), 18: Offset(0.231, 0.066),
      19: Offset(0.060, 0.064), 20: Offset(0.060, 0.235),
      21: Offset(0.056, 0.353), 22: Offset(0.056, 0.466),
      23: Offset(0.056, 0.586), 24: Offset(0.056, 0.695),
      25: Offset(0.214, 0.695), 26: Offset(0.351, 0.709),
      27: Offset(0.459, 0.709), 28: Offset(0.563, 0.709),
      29: Offset(0.701, 0.364), 30: Offset(0.684, 0.224),
      31: Offset(0.561, 0.218), 32: Offset(0.457, 0.224),
      33: Offset(0.343, 0.353), 34: Offset(0.212, 0.574),
    };

    const Map<int, Offset> cityCoords = {
      1:  Offset(0.058, 0.863), 2:  Offset(0.209, 0.860),
      3:  Offset(0.332, 0.860), 4:  Offset(0.459, 0.860),
      5:  Offset(0.585, 0.860), 6:  Offset(0.709, 0.860),
      7:  Offset(0.857, 0.863), 8:  Offset(0.857, 0.697),
      9:  Offset(0.857, 0.584), 10: Offset(0.857, 0.459),
      11: Offset(0.857, 0.333), 12: Offset(0.857, 0.208),
      13: Offset(0.857, 0.064), 14: Offset(0.711, 0.064),
      15: Offset(0.588, 0.064), 16: Offset(0.462, 0.064),
      17: Offset(0.337, 0.064), 18: Offset(0.212, 0.064),
      19: Offset(0.056, 0.064), 20: Offset(0.056, 0.212),
      21: Offset(0.056, 0.335), 22: Offset(0.056, 0.457),
      23: Offset(0.056, 0.584), 24: Offset(0.056, 0.711),
      25: Offset(0.208, 0.715), 26: Offset(0.337, 0.715),
      27: Offset(0.459, 0.715), 28: Offset(0.586, 0.715),
      29: Offset(0.705, 0.335), 30: Offset(0.705, 0.210),
      31: Offset(0.580, 0.210), 32: Offset(0.453, 0.210),
      33: Offset(0.326, 0.210), 34: Offset(0.208, 0.586),
    };

    final coordsMap =
        gameType == 'jungle' ? jungleCoords : cityCoords;

    if (steps > 34) steps = 34;

    int effectiveSteps =
        steps > 0 ? (steps % 34 == 0 ? 34 : steps % 34) : 0;

    final relativeOffset = coordsMap[effectiveSteps];

    if (relativeOffset == null) {
      final initialRelative = gameType == 'jungle'
          ? const Offset(0.066, 0.863)
          : const Offset(0.058, 0.863);
      return Offset(
        initialRelative.dx * minDimension,
        initialRelative.dy * minDimension,
      );
    }

    return Offset(
      relativeOffset.dx * minDimension,
      relativeOffset.dy * minDimension,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.gameType == 'jungle'
        ? kGreenMid
        : const Color(0xFF1a5276);

    final String boardImage = widget.gameType == 'jungle'
        ? 'images/IMG-20240301-WA0006.jpg'
        : 'images/IMG-20240305-WA0002.jpg';

    final String currentPlayerTurn = 'p${currentPlayerIndex + 1}';
    final bool isMyTurn = widget.player == currentPlayerTurn;
    final bool canIRoll = isMyTurn && gameStatus == 'playing';

    String buttonText =
        "Waiting for ${currentPlayerTurn.toUpperCase()}...";
    if (gameStatus != 'playing') {
      buttonText = "Waiting for answer...";
    } else if (canIRoll) {
      buttonText = "🎲 Roll Dice";
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0d2b0d),
            title: const Text(
              'Leave Game?',
              style: TextStyle(color: kGreenBright),
            ),
            content: const Text(
              'Are you sure? This will end the game for all players.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Stay',
                  style: TextStyle(color: kGreenBright),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Leave',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldLeave ?? false) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                results: _currentResults,
                gameType: widget.gameType,
                player: widget.player,
              ),
            ),
          );
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              "Game - You are ${widget.player.toUpperCase()}"),
          backgroundColor: themeColor,
        ),
        body: Stack(
          children: [
            // Game-specific background slideshow
            BackgroundSlideshow(
              type: widget.gameType,
              child: Container(),
            ),

            // Game content on top
            Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      minDimension =
                          constraints.maxWidth < constraints.maxHeight
                              ? constraints.maxWidth
                              : constraints.maxHeight;

                      List<Widget> playerWidgets = [];
                      for (var i = 0; i < totalPlayers; i++) {
                        String playerKey = 'p${i + 1}';
                        int steps = playerSteps[playerKey] ?? 0;
                        Offset position = calculatePlayerPosition(
                            steps, widget.gameType);

                        playerWidgets.add(
                          AnimatedPositioned(
                            left: position.dx,
                            top: position.dy,
                            duration:
                                const Duration(milliseconds: 300),
                            child: Container(
                              height: minDimension * 0.08,
                              width: minDimension * 0.08,
                              decoration: BoxDecoration(
                                color: playerColors[
                                    i % playerColors.length],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Center(
                        child: SizedBox(
                          width: minDimension,
                          height: minDimension,
                          child: Stack(
                            children: [
                              Image.asset(
                                boardImage,
                                fit: BoxFit.contain,
                              ),
                              ...playerWidgets,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    border: Border(
                      top: BorderSide(
                        color: kGreenBright.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _lastEventText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kGreenLight,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              canIRoll ? kGreenMid : Colors.grey[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed:
                            canIRoll ? _sendPlayRequest : null,
                        child: Text(buttonText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// RESULTS PAGE
// ============================================
class ResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> allResults;
  final String gameType;
  final String player;

  const ResultsPage({
    Key? key,
    required List<Map<String, dynamic>> results,
    required this.gameType,
    required this.player,
  })  : allResults = results,
        super(key: key);

  Future<void> _saveResults(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save.')));
      return;
    }

    // Filter to only THIS player's results before saving
    final myResults = player.isNotEmpty
        ? allResults.where((r) => r['player'] == player).toList()
        : allResults;

    if (myResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No results to save.')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$PHP_API_URL/save_results.php'),
        body: {
          'username': username,
          'results_data': jsonEncode(myResults), // Only this player's results
          'game_type': gameType,
        },
      );
      if (context.mounted) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Results saved!')));
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/welcome', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Save failed: ${data['message']}')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving results. Check logs.')));
      }
    }
  }

  void _shareResults(List<Map<String, dynamic>> playerResults) {
    String shareText = "Jungle Professor Game Results:\n\n";
    for (var result in playerResults) {
      shareText += "Q: ${result['question']}\n";
      shareText += "A: ${result['correctAnswer']}\n\n";
    }
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final playerResults = player.isNotEmpty
        ? allResults.where((r) => r['player'] == player).toList()
        : allResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Game Results'),
        backgroundColor: kGreenDark,
        automaticallyImplyLeading: false,
      ),
      body: BackgroundSlideshow(
        type: gameType,
        child: Column(
          children: [
            Expanded(
              child: playerResults.isEmpty
                  ? const Center(
                      child: Text(
                        'You did not answer any questions in this game.',
                        style: TextStyle(color: kGreenLight, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: playerResults.length,
                      itemBuilder: (context, index) {
                        final result = playerResults[index];
                        final bool wasCorrect = result['wasCorrect'];
                        return Card(
                          color: wasCorrect
                              ? const Color(0xFF145a32)
                              : const Color(0xFF641e16),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: Icon(
                                wasCorrect
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: wasCorrect
                                    ? kGreenBright
                                    : Colors.red[300]),
                            title: Text(result['question'],
                                style: const TextStyle(
                                    color: Colors.white)),
                            subtitle: Text(
                              'Your answer: ${result['providedAnswer']}\nCorrect: ${result['correctAnswer']}',
                              style:
                                  const TextStyle(color: kGreenLight),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              color: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _saveResults(context),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Results'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _shareResults(playerResults),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1a5276)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            '/welcome', (route) => false),
                    icon: const Icon(Icons.done),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// SAVED RESULTS LIST PAGE
// ============================================
class SavedResultsListPage extends StatefulWidget {
  const SavedResultsListPage({Key? key}) : super(key: key);
  @override
  _SavedResultsListPageState createState() => _SavedResultsListPageState();
}

class _SavedResultsListPageState extends State<SavedResultsListPage> {
  Future<List<dynamic>>? _savedResultsFuture;

  @override
  void initState() {
    super.initState();
    _savedResultsFuture = _fetchSavedResults();
  }

  Future<List<dynamic>> _fetchSavedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return [];
    try {
      final response = await http.get(
          Uri.parse('$PHP_API_URL/get_results.php?username=$username'));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') return data['data'];
    } catch (e) {
      print("Server error: $e");
      // handle error
    }
    return [];
  }

  void _viewResult(int resultId, String gameType) async {
    try {
      final response = await http.get(
          Uri.parse('$PHP_API_URL/get_single_result.php?id=$resultId'));
      if (context.mounted) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ResultsPage(
              results: List<Map<String, dynamic>>.from(data['data']),
              gameType: gameType,
              player: '',
            ),
          ));
        }
      }
    } catch (e) {
      print("Server error: $e");
      // handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved Results'),
        backgroundColor: kGreenDark,
      ),
      body: BackgroundSlideshow(
        type: 'general',
        child: FutureBuilder<List<dynamic>>(
          future: _savedResultsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: kGreenBright));
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text('You have no saved results.',
                    style: TextStyle(color: kGreenLight, fontSize: 16)),
              );
            }
            final resultsList = snapshot.data!;
            return RefreshIndicator(
              color: kGreenBright,
              onRefresh: () async {
                setState(() {
                  _savedResultsFuture = _fetchSavedResults();
                });
              },
              child: ListView.builder(
                itemCount: resultsList.length,
                itemBuilder: (context, index) {
                  final result = resultsList[index];
                  final String gameTitle = result['game_type'] == 'jungle'
                      ? '🦁 Jungle Professor'
                      : '🏙️ City Tour';
                  final String createdAt =
                      result['created_at'] ?? 'Unknown date';
                  final String score =
                      '${result['correct_answers']}/${result['total_questions']} correct';
                  return Card(
                    color: Colors.black.withOpacity(0.6),
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: Icon(
                        result['game_type'] == 'jungle'
                            ? Icons.park
                            : Icons.location_city,
                        color: kGreenBright,
                      ),
                      title: Text(gameTitle,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Played on $createdAt\n$score',
                        style: const TextStyle(color: kGreenLight),
                      ),
                      onTap: () => _viewResult(
                          int.parse(result['id'].toString()),
                          result['game_type']),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}