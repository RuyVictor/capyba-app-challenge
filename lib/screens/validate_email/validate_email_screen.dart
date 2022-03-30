import 'dart:async';

import 'package:capyba_app/blocs/auth_bloc.dart';
import 'package:capyba_app/screens/home/home_screen.dart';
import 'package:capyba_app/theme/colors.dart';
import 'package:capyba_app/widgets/button.dart';
import 'package:capyba_app/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ValidateEmailScreen extends StatefulWidget {
  @override
  State<ValidateEmailScreen> createState() => _ValidateEmailScreenState();
}

class _ValidateEmailScreenState extends State<ValidateEmailScreen> {
  User user = AuthBloc().getUser() as User;
  final Toast toast = Toast();
  final AuthBloc authBloc = AuthBloc();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (!user.emailVerified) {
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        checkEmailVerified();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await authBloc.reloadUser();
    user = AuthBloc().getUser() as User;

    setState(() => user.emailVerified);

    if (user.emailVerified) {
      timer?.cancel();
    }
  }

  void onSubmit(BuildContext context) async {
    try {
      authBloc.sendVerificationEmail();
      toast.showSucess(context,
          'O link de verificação foi enviado ao seu email com sucesso!');
    } catch (e) {
      toast.showWarning(context, 'Erro ao enviar o link de verificação!');
    }
  }

  void resetHomeState(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.PRIMARY_DARK,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Validar email',
            style: TextStyle(fontSize: 30, color: AppColors.WHITE),
          ),
          centerTitle: true,
          leading: BackButton(onPressed: () => resetHomeState(context))),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Center(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 20,
              children: <Widget>[
                Text(
                  'Email verificado: ' + (user.emailVerified ? 'Sim' : 'Não'),
                  style: TextStyle(color: AppColors.WHITE),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    child: Button(
                      text: 'Enviar link',
                      disabled: user.emailVerified,
                      onPressed: () => onSubmit(context),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Button(
                      text: 'Voltar',
                      onPressed: () => resetHomeState(context),
                    ),
                  )
                ]),
              ],
            ),
          )),
    ));
  }
}
