import 'package:capyba_app/blocs/auth_bloc.dart';
import 'package:capyba_app/theme/colors.dart';
import 'package:capyba_app/utils/auth_validation.dart';
import 'package:capyba_app/widgets/button.dart';
import 'package:capyba_app/widgets/default_input.dart';
import 'package:capyba_app/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  User user = AuthBloc().getUser() as User;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isChangingPassword = false;
  final Toast toast = Toast();
  final AuthBloc authBloc = AuthBloc();
  final AuthValidation authValidation = AuthValidation();

  Future<void> onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await authBloc.changePassword(
            _currentPasswordController.text, _newPasswordController.text);
        toast.showSucess(context, 'Senha atualizada com sucesso!');
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          toast.showWarning(context, 'A senha atual digitada não confere');
        } else {
          toast.showWarning(context, 'Erro ao atualizar a senha!');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.PRIMARY_DARK,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Atualizar senha',
              style: TextStyle(fontSize: 30, color: AppColors.WHITE),
            ),
            centerTitle: true,
            leading: const BackButton()),
        body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Center(
                  child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 20,
                  children: <Widget>[
                    DefaultInput(
                      controller: _currentPasswordController,
                      label: 'Senha atual',
                      validator: (value) =>
                          authValidation.validateEmpty(value, 'senha'),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    DefaultInput(
                      controller: _newPasswordController,
                      label: 'Nova senha',
                      validator: authValidation.validatePassword,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Expanded(
                        child: Button(
                            text: 'Atualizar senha',
                            disabled: _isChangingPassword,
                            onPressed: () async {
                              setState(() => _isChangingPassword = true);
                              await onSubmit(context);
                              setState(() => _isChangingPassword = false);
                            }),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Button(
                          text: 'Voltar',
                          disabled: _isChangingPassword,
                          onPressed: () => Navigator.pop(context),
                        ),
                      )
                    ]),
                  ],
                ),
              )),
            )));
  }
}
