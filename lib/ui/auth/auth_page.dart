import 'package:cucifikasi_laundry/ui/auth/auth_helper.dart';
import 'package:cucifikasi_laundry/ui/auth/auth_ui_utils.dart';
import 'package:cucifikasi_laundry/ui/auth/auth_validation.dart';
import 'package:cucifikasi_laundry/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late AuthHelper _authHelper;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoginForm = true;
  bool _emailFieldTouched = false;
  bool _passwordFieldTouched = false;
  bool _isPasswordVisible = false;
  bool _nameFieldTouched = false;
  bool _addressFieldTouched = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authHelper = AuthHelper();
    _checkLoggedInStatus();
  }

  void _checkLoggedInStatus() async {
    final isLoggedIn = await _authHelper.isLoggedIn();
    if (isLoggedIn) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final isAdmin = await _authHelper.adminManager.isAdmin();
        _navigateTo(isAdmin ? '/admin_home' : '/customer_home');
      }
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      validator: (value) => EmailValidator.validate(
        value,
        _emailFieldTouched,
      ),
      onChanged: (_) => setState(() => _emailFieldTouched = true),
      decoration: AuthUIUtils.buildInputDecoration(
        context,
        'Email',
        Icons.email,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      validator: (value) => PasswordValidator.validate(
        value,
        _passwordFieldTouched,
      ),
      onChanged: (_) => setState(() => _passwordFieldTouched = true),
      obscureText: !_isPasswordVisible,
      decoration: AuthUIUtils.buildPasswordInputDecoration(
        context,
        _isPasswordVisible,
        _togglePasswordVisibility,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      validator: (value) => NameValidator.validate(
        value,
        _isLoginForm,
        _nameFieldTouched,
      ),
      onChanged: (_) => setState(() => _nameFieldTouched = true),
      decoration: AuthUIUtils.buildInputDecoration(
        context,
        'Name',
        Icons.person,
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      validator: (value) => AddressValidator.validate(
        value,
        _isLoginForm,
        _addressFieldTouched,
      ),
      onChanged: (_) => setState(() => _addressFieldTouched = true),
      decoration: AuthUIUtils.buildInputDecoration(
        context,
        'Address',
        Icons.location_on,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AuthUIUtils.buildLoadingIndicator(context, _isLoading);
  }

  Widget _buildSubmitButton() {
    return AuthUIUtils.buildSubmitButton(
      context,
      _isLoading,
      _isLoginForm,
      _submitForm,
    );
  }

  Widget _buildToggleFormButton() {
    return AuthUIUtils.buildToggleFormButton(
      context,
      _isLoading,
      _isLoginForm,
      _toggleForm,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final name = _nameController.text.trim();
        final address = _addressController.text.trim();

        final emailExists =
            await _authHelper.userDataManager.doesEmailExist(email);

        if (_isLoginForm || !emailExists) {
          User? user;

          if (_isLoginForm) {
            user = await _authHelper.authManager.signInWithEmailAndPassword(
              email,
              password,
            );
          } else {
            user = await _authHelper.authManager.createUserWithEmailAndPassword(
              email,
              password,
            );

            await _authHelper.userDataManager.saveUserDataToFirestore(
              user!,
              email,
              name,
              address,
            );
          }

          if (await _authHelper.adminManager.isAdmin()) {
            await _authHelper.setLoggedIn(true);
            _navigateTo('/admin_home');
          } else {
            await _authHelper.setLoggedIn(true);
            _navigateTo('/customer_home');
          }

          Utils(context).showSnackbar(
            _isLoginForm ? 'Login Successful!' : 'Registration Successful!',
          );
        } else {
          Utils(context).showSnackbar(
            'Email is already registered. Please use a different email.',
          );
        }
      } catch (e) {
        UtilsLog.logger.e('Error: $e', error: e);
        Utils(context).showSnackbar('Error: Failed sign-up, please try again!');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleForm() {
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  void _navigateTo(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              AuthUIUtils.buildLogo(),
              const SizedBox(height: 16),
              AuthUIUtils.buildTitle(_isLoginForm),
              const SizedBox(height: 16),
              _buildForm(),
              const SizedBox(height: 16),
              _buildSubmitButton(),
              const SizedBox(height: 8),
              _buildToggleFormButton(),
              _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          if (!_isLoginForm) ...[
            const SizedBox(height: 16),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildAddressField(),
          ],
        ],
      ),
    );
  }
}
