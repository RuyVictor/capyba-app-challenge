// Regex

final RegExp alphabetAndSpace = RegExp("[A-zÀ-ú\ \s]");
final RegExp alphabetAndNumbers = RegExp("[^A-zÀ-úa-z0-9]");

String emailRegexPattern =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
    r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
    r"{0,253}[a-zA-Z0-9])?)*$";
final RegExp emailRegex = RegExp(emailRegexPattern);
final RegExp emailInvalidCharacters = RegExp("[ ]");

class AuthValidation {
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu nome';
    }
  }

  String? validateEmail(String? value) {
    if (value == null || !emailRegex.hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  String? validateConfirmEmail(String email, confirmEmail) {
    if (email != confirmEmail) {
      return 'Email não confere';
    }
    return null;
  }

  String? validateEmpty(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Digite a $label';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite a senha';
    } else if (value.length < 6) {
      return 'Deve conter no mínimo 6 caracteres';
    } else if (alphabetAndNumbers.hasMatch(value)) {
      return 'Deve conter apenas caracteres alfabéticos e números';
    }
    return null;
  }

  String? validateConfirmPassword(String password, confirmPassword) {
    if (password != confirmPassword) {
      return 'Senha não confere';
    }
    return null;
  }
}