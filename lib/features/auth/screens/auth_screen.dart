import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Screen for authorization process.
///
/// Contains [IAuthRepository] to do so.
class AuthScreen extends StatefulWidget {
  /// Repository for auth implementation.
  final IAuthRepository authRepository;

  /// Constructor for [AuthScreen].
  const AuthScreen({
    required this.authRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState(authRepository);
}

class _AuthScreenState extends State<AuthScreen> {
  // TODO(task): Implement Auth screen.
  final IAuthRepository authRepository;
  _AuthScreenState(this.authRepository) {}
  bool _hidePass = true;

  final _formKey = GlobalKey<FormState>();
  final _scafoldKey = GlobalKey<ScaffoldState>();

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    checkToken();
  }

  void checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _pushToChat(context, TokenDto(token: token));
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreenAccent,
      key: _scafoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Registration'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const SizedBox(height: 170),
          TextFormField(
            controller: _loginController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
                prefixIcon: Icon(Icons.person),
                labelText: 'Login'),
            validator: (val) => val!.isEmpty ? "Введите логин" : null,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            obscureText: _hidePass,
            maxLength: 15,
            controller: _passwordController,
            decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
                prefixIcon: const Icon(Icons.security),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hidePass = !_hidePass;
                      });
                    },
                    icon: Icon(
                        _hidePass ? Icons.visibility : Icons.visibility_off)),
                labelText: 'Password'),
            validator: (val) => val!.isEmpty ? "Введите пароль" : null,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              onPrimary: Colors.white,
              primary: Colors.green,
              minimumSize: Size(88, 36),
              //padding: EdgeInsets.symmetric(horizontal: 40),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            onPressed: _submitForm,
            child: const Text(
              'Далее',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ),
        ]),
      ),
    );
  }

  void _pushToChat(BuildContext context, TokenDto token) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChatScreen(
            chatRepository: ChatRepository(
              StudyJamClient().getAuthorizedClient(token.token),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final tokenData = await authRepository.signIn(
          login: _loginController.text, password: _passwordController.text);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', tokenData.token);
      _pushToChat(context, tokenData);
      print('Form is valid');
      print(tokenData);
    } else {
      _showMessage(message: 'Error: invalid Login or Password');
    }
  }

  void _showMessage({required String message}) {
    _scafoldKey.currentState!.showSnackBar(
      SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          )),
    );
  }
}
