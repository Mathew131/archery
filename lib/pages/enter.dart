import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:archery/data/data.dart';
import 'package:archery/data/di.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Enter extends StatefulWidget {
  const Enter({Key? key}) : super(key: key);

  @override
  State<Enter> createState() => _EnterState();
}

class _EnterState extends State<Enter> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Align(
        alignment: Alignment(0, 0),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Электронная почта',
                      hintText: 'Введите электронную почту',
                      prefixIcon: Icon(Icons.email, color: Colors.lightBlue),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: MultiValidator([
                      EmailValidator(errorText: 'Введите корректную электронную почту'),
                    ]),
                  ),
                ),
                SizedBox(height: 12),

                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      hintText: 'Введите пароль',
                      prefixIcon: Icon(Icons.lock, color: Colors.orange),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: MinLengthValidator(8, errorText: 'Минимум 8 символов'),
                  ),
                ),

                SizedBox(height: 30),

                SizedBox(
                  width: 160,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black38,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      final auth = FirebaseAuth.instance;

                      try {
                        final result = await auth.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        final user = result.user;

                        if (user != null) { // user.emailVerified
                          await sl<Data>().searchAndSaveTokenByEmail(emailController.text);
                          await Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false,);
                        }
                      } on FirebaseAuthException catch (e) {
                        String msg = 'Ошибка входа';

                        if (e.code == 'invalid-credential') msg = 'Неверный email или пароль';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                      }
                    },
                    child: Text('Войти'),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
