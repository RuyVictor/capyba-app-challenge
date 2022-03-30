import 'dart:io';

import 'package:capyba_app/blocs/auth_bloc.dart';
import 'package:capyba_app/screens/home/home_screen.dart';
import 'package:capyba_app/theme/colors.dart';
import 'package:capyba_app/theme/icons.dart';
import 'package:capyba_app/utils/auth_validation.dart';
import 'package:capyba_app/widgets/button.dart';
import 'package:capyba_app/widgets/default_input.dart';
import 'package:capyba_app/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  final Toast toast = Toast();
  final AuthBloc authBloc = AuthBloc();
  final AuthValidation authValidation = AuthValidation();
  bool _isRegistering = false;

  Future<void> onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await authBloc.createAccount(_nameController.text,
            _emailController.text, _passwordController.text, _profileImage);
        toast.showSucess(context, 'Usuário cadastrado com sucesso!');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          toast.showWarning(context, 'Está conta de usuário já existe');
        } else {
          toast.showWarning(context, 'Falha ao criar novo usuário!');
        }
      }
    }
  }

  void pickImage() async {
    _profileImage = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.PRIMARY_DARK,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Cadastro',
              style: TextStyle(fontSize: 30, color: AppColors.WHITE),
            ),
            centerTitle: true,
            leading: const BackButton()),
        body: Form(
            key: _formKey,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                        alignment: WrapAlignment.center,
                        runSpacing: 20,
                        children: <Widget>[
                          Material(
                              elevation: 10,
                              shape: const CircleBorder(),
                              child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.blue[200],
                                  backgroundImage: _profileImage != null
                                      ? Image.file(
                                          File(_profileImage!.path),
                                          fit: BoxFit.cover,
                                        ).image
                                      : Image.asset(
                                          AppIcons.PROFILE,
                                          fit: BoxFit.cover,
                                        ).image,
                                  child: Material(
                                    shape: const CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: pickImage,
                                    ),
                                  ))),
                          DefaultInput(
                            controller: _nameController,
                            label: 'Nome',
                            validator: authValidation.validateName,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
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
                          DefaultInput(
                            controller: _passwordConfirmController,
                            label: 'Confirmar senha',
                            validator: (value) =>
                                authValidation.validateConfirmPassword(
                                    _passwordController.text, value),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Button(
                                    text: 'Registrar',
                                    disabled: _isRegistering,
                                    onPressed: () async {
                                      setState(() {
                                        _isRegistering = true;
                                      });
                                      await onSubmit(context);
                                      setState(() {
                                        _isRegistering = false;
                                      });
                                    }
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Button(
                                    text: 'Voltar',
                                    disabled: _isRegistering,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                )
                              ]),
                        ],
                      )),
                ))));
  }
}
