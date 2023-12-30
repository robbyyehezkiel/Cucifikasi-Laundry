// auth_validation.dart

class FieldValidator {
  static String? validateNonEmpty(
      String? value, bool isLoginForm, bool isFieldTouched) {
    if (!isLoginForm && isFieldTouched && (value == null || value.isEmpty)) {
      return 'This field cannot be empty';
    }
    return null;
  }
}

class EmailValidator {
  static String? validate(String? value, bool isFieldTouched) {
    if (!isFieldTouched) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}

class PasswordValidator {
  static const int minPasswordLength = 8;

  static String? validate(String? value, bool isFieldTouched) {
    if (!isFieldTouched) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    return null;
  }
}

class NameValidator {
  static String? validate(
      String? value, bool isLoginForm, bool isFieldTouched) {
    return FieldValidator.validateNonEmpty(value, isLoginForm, isFieldTouched);
  }
}

class AddressValidator {
  static String? validate(
      String? value, bool isLoginForm, bool isFieldTouched) {
    return FieldValidator.validateNonEmpty(value, isLoginForm, isFieldTouched);
  }
}
