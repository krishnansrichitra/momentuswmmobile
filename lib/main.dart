import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';
import 'screens/receiving/receiving_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void openMenu(BuildContext context,String menuName) {
    if (menuName == "Receiving") {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const ReceivingPage(),
        ),
      );

      return;
    }
    print("Clicked: $menuName");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("WMS Mobile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text("Receiving"),
            subtitle: const Text("Receive by ASN / PO"),
            onTap: () => openMenu( context,  "Receiving"),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text("Putaway"),
            subtitle: const Text("Move stock to storage location"),
            onTap: () => openMenu(context,"Putaway"),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text("Inventory Lookup"),
            subtitle: const Text("Search item, LPN or location"),
            onTap: () => openMenu(context,"Inventory Lookup"),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text("My Tasks"),
            subtitle: const Text("Assigned warehouse tasks"),
            onTap: () => openMenu(context,"My Tasks"),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}


class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String message = "";

  Future<void> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty) {
      setState(() {
        message = "Please enter username";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        message = "Please enter password";
      });
      return;
    }

    setState(() {
      message = "Logging in...";
    });

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiBaseUrl}/wms/api/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          message = "Login successful";
        });

        print("Response: ${response.body}");
        final data = jsonDecode(response.body);
        final token = data["token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt", token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        setState(() {
          message = "Login failed: ${response.statusCode}";
        });

        print("Error: ${response.body}");
      }
    } catch (e) {
      setState(() {
        message = "Unable to connect to server";
      });

      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("WMS Login"),
      ),
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  child: const Text("Login"),
                ),
              ),

              const SizedBox(height: 16),

              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}