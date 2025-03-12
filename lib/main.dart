import 'package:flutter/material.dart';
import 'package:flutter_login_ui2/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage/common_storage.dart';

late SharedPreferences sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    String? themeString = sharedPreferences.getString('theme');
    print(themeString);
    setState(() {
      _themeMode = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _saveTheme(ThemeMode themeMode) async {
    String themeString = themeMode == ThemeMode.dark ? 'dark' : 'light';
    await sharedPreferences.setString('theme', themeString);
  }

  void _changeThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _saveTheme(_themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.green;
                } else if (states.contains(WidgetState.hovered)) {
                  return Colors.yellow;
                } else if (states.contains(WidgetState.disabled)) {
                  return Colors.grey;
                }
                return Colors.blue;
              },
            ),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        themeMode: _themeMode,
        onThemeModeChanged: _changeThemeMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.onThemeModeChanged, required this.themeMode});
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode themeMode;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showPass = true;

  final String _user = "user";
  final String _admin = "admin";
  String? _groupValue;
  bool _rememberMe = false;
  String? _email;
  String? _password;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadState(); // Load the saved state when the widget is created
    }); // Load the saved state when the widget is created
  }

  void _loadState() {
    setState(() {
      _rememberMe = sharedPreferences.getBool('rememberMe') ?? false;
      _groupValue = sharedPreferences.getString('groupValue') ?? "user";
      _email = sharedPreferences.getString('email');
    });
  }

  Future<void> _saveRememberMe(bool value) async {
    await sharedPreferences.setBool('rememberMe', value);
  }

  Future<void> _saveGroupValue(String value) async {
    await sharedPreferences.setString('groupValue', value);
  }

  Future<void> _saveEmail(String value) async {
    await sharedPreferences.setString('email', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login UI'),
        actions: [
          Switch(
            value: widget.themeMode == ThemeMode.dark,
            onChanged: (value) {
              widget.onThemeModeChanged(
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                    initialValue: _rememberMe == true ? _email : '',
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      labelText: _rememberMe ? _email : 'Email',
                      hintText: _rememberMe ? _email : 'Enter your email',
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      } else if (!value.contains('@gmail.com')) {
                        return 'Invalid Email Address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value;
                    }),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    } else if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (onChanged) {
                        setState(() {
                          _rememberMe = onChanged!;
                          _saveRememberMe(_rememberMe);
                        });
                      },
                    ),
                    const Text('Remember me'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('User Type :'),
                    Radio(
                        value: _user,
                        groupValue: _groupValue,
                        onChanged: (onChanged) {
                          setState(
                            () {
                              _groupValue = onChanged!;
                              _saveGroupValue(_groupValue!);
                            },
                          );
                        }),
                    const Text('User'),
                    Radio(
                      value: _admin,
                      groupValue: _groupValue,
                      onChanged: (onChanged) {
                        setState(() {
                          _groupValue = onChanged!;
                          _saveGroupValue(_groupValue!);
                        });
                      },
                    ),
                    const Text(
                      'Admin',
                    )
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _saveRememberMe(_rememberMe);
                      if (_rememberMe) {
                        if (_groupValue == _admin) {
                          rememberMe(_email!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HomeScreen(
                                    email: 'From Session : ${_email!}',
                                    themeMode: widget.themeMode);
                              },
                            ),
                          );
                        } else {
                          _saveEmail(_email!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HomeScreen(
                                  email: 'From Local : ${_email!}',
                                  themeMode: widget.themeMode,
                                );
                              },
                            ),
                          );
                        }
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return HomeScreen(
                                email: "Not Saved",
                                themeMode: widget.themeMode,
                              );
                            },
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
