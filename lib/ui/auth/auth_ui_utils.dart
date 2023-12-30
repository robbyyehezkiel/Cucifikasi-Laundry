import 'package:flutter/material.dart';

class AuthUIUtils {
  static InputDecoration buildInputDecoration(
      BuildContext context, String labelText, IconData prefixIcon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon),
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  static InputDecoration buildPasswordInputDecoration(BuildContext context,
      bool isPasswordVisible, Function() togglePasswordVisibility) {
    return InputDecoration(
      labelText: 'Password',
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: togglePasswordVisibility,
      ),
      border: const OutlineInputBorder(),
    );
  }

  // New method for building the loading indicator
  static Widget buildLoadingIndicator(BuildContext context, bool isLoading) {
    return isLoading
        ? const Column(
            children: [
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          )
        : const SizedBox.shrink();
  }

  static Widget buildLogo() {
    return Center(
      child: Image.asset(
        'assets/app_logo.jpg',
        width: 240,
        height: 240,
      ),
    );
  }

  static Widget buildTitle(isLoginForm) {
    return Text(
      isLoginForm ? 'Login' : 'Register',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  // New method for building the submit button
  static Widget buildSubmitButton(BuildContext context, bool isLoading,
      bool isLoginForm, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: Text(
        isLoginForm ? 'Login' : 'Register',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  // New method for building the toggle form button
  static Widget buildToggleFormButton(BuildContext context, bool isLoading,
      bool isLoginForm, VoidCallback onPressed) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(
        isLoginForm
            ? 'Don\'t have an account? Register'
            : 'Already have an account? Login',
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }
}
