import 'package:capyba_app/blocs/auth_bloc.dart';
import 'package:capyba_app/screens/home/home_screen.dart';
import 'package:capyba_app/screens/register/register_screen.dart';
import 'package:capyba_app/theme/colors.dart';
import 'package:capyba_app/utils/auth_validation.dart';
import 'package:capyba_app/widgets/button.dart';
import 'package:capyba_app/widgets/default_input.dart';
import 'package:capyba_app/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Toast toast = Toast();
  final AuthBloc authBloc = AuthBloc();
  final AuthValidation authValidation = AuthValidation();
  bool _isSigningIn = false;

  void defaultSignIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await authBloc.signIn(_emailController.text, _passwordController.text);
        toast.showSucess(context, 'Usuário logado com sucesso!');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          toast.showWarning(context, 'Nenhum usuário encontrado neste email');
        } else if (e.code == 'wrong-password') {
          toast.showWarning(context, 'Email ou senha incorretos!');
        }
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await authBloc.signInWithGoogle();
      User? user = authBloc.getUser();
      if (user != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      toast.showWarning(context, 'Erro ao fazer login com Google!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.PRIMARY_DARK,
        body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Center(
                  child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  runSpacing: 20.0,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, color: AppColors.WHITE),
                    ),
                    DefaultInput(
                      controller: _emailController,
                      label: 'Email',
                      validator: authValidation.validateEmail,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                    DefaultInput(
                      controller: _passwordController,
                      label: 'Senha',
                      validator: authValidation.validatePassword,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Expanded(
                        child: Button(
                          text: 'Entrar',
                          disabled: _isSigningIn,
                          onPressed: () => defaultSignIn(context),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Button(
                          text: 'Registrar',
                          disabled: _isSigningIn,
                          onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            )
                          },
                        ),
                      )
                    ]),
                    Row(children: const [
                      Expanded(
                          child: Divider(
                        color: AppColors.SECONDARY,
                        thickness: 1,
                      )),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'ou',
                            style: TextStyle(color: AppColors.WHITE),
                          )),
                      Expanded(
                          child: Divider(
                        color: AppColors.SECONDARY,
                        thickness: 1,
                      ))
                    ]),
                    Row(children: [
                      Expanded(
                          child: Button(
                              text: 'Entrar com Google',
                              leftIcon: MdiIcons.google,
                              disabled: _isSigningIn,
                              onPressed: () async {
                                setState(() {
                                  _isSigningIn = true;
                                });
                                await signInWithGoogle(context);
                                setState(() {
                                  _isSigningIn = false;
                                });
                              }))
                    ]),
                  ],
                ),
              )),
            )));
  }
}
