import 'package:flutter/material.dart';

import '../core/facades/library_facade.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.facade});

  final LibraryFacade facade;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _usernameController.text = 'admin';
    _passwordController.text = '12345678';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isRegisterMode) {
        await widget.facade.register(
          username: username,
          email: email,
          password: password,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario $username registrado correctamente'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      final userResponse = await widget.facade.login(username, password);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenido ${userResponse.user.username}'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _errorMessage = null;

      if (_isRegisterMode) {
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
      } else {
        _usernameController.text = 'admin';
        _emailController.clear();
        _passwordController.text = '12345678';
      }
    });
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }

    return null;
  }

  String? _usernameValidator(String? value) {
    final requiredError = _requiredValidator(value, 'El usuario');

    if (requiredError != null) {
      return requiredError;
    }

    final username = value!.trim();

    if (username.length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }

    if (username.length > 20) {
      return 'El usuario no debe superar 20 caracteres';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    if (!_isRegisterMode) {
      return null;
    }

    final requiredError = _requiredValidator(value, 'El correo');

    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();

    if (!email.contains('@') || !email.contains('.')) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final requiredError = _requiredValidator(value, 'La contraseña');

    if (requiredError != null) {
      return requiredError;
    }

    if (_isRegisterMode && value!.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF32145A), Color(0xFF6E45B8), Color(0xFFF4EFFA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 14,
                  shadowColor: const Color(0x33000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 30,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 28),
                          _buildUsernameField(),
                          if (_isRegisterMode) ...[
                            const SizedBox(height: 16),
                            _buildEmailField(),
                          ],
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildErrorBox(),
                          ],
                          const SizedBox(height: 24),
                          _buildSubmitButton(colorScheme),
                          const SizedBox(height: 14),
                          _buildSwitchModeButton(colorScheme),
                          const SizedBox(height: 12),
                          _buildFooterText(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E8FF),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: 50,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _isRegisterMode ? 'Crear cuenta' : 'Literatura Rusa',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E2243),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isRegisterMode
              ? 'Regístrate para publicar, comentar y reaccionar a libros'
              : 'Accede a tu biblioteca y comunidad literaria',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6E647D)),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      validator: _usernameValidator,
      decoration: InputDecoration(
        labelText: 'Usuario',
        hintText: 'Ingresa tu usuario',
        prefixIcon: const Icon(Icons.person_outline_rounded),
        filled: true,
        fillColor: const Color(0xFFFAF7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1D8F2)),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      enabled: !_isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: _emailValidator,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'ejemplo@correo.com',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: const Color(0xFFFAF7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1D8F2)),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      enabled: !_isLoading,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSubmit(),
      validator: _passwordValidator,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Ingresa tu contraseña',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscurePassword
              ? 'Mostrar contraseña'
              : 'Ocultar contraseña',
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: _isLoading
              ? null
              : () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
        ),
        filled: true,
        fillColor: const Color(0xFFFAF7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1D8F2)),
        ),
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB7B7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFC62828)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFF9F1D1D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isRegisterMode
                        ? Icons.person_add_alt_1_rounded
                        : Icons.login_rounded,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isRegisterMode ? 'Registrarme' : 'Iniciar sesión',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSwitchModeButton(ColorScheme colorScheme) {
    return TextButton(
      onPressed: _isLoading ? null : _toggleMode,
      style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      child: Text(
        _isRegisterMode
            ? 'Ya tengo cuenta, iniciar sesión'
            : 'Crear una cuenta nueva',
      ),
    );
  }

  Widget _buildFooterText(BuildContext context) {
    return Text(
      'Proyecto académico · Flutter + Spring Boot',
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: const Color(0xFF7B7289)),
    );
  }
}
