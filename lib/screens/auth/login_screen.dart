import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/screens/auth/register_screen.dart';
import 'package:pro_services/screens/client/home_client_screen.dart';
import 'package:pro_services/screens/professional/home_professional_screen.dart';
import 'package:pro_services/services/auth_service.dart';
import 'package:pro_services/services/error_log_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedRole = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailError = false;
  bool _passwordError = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validación local
    final emailVacio = email.isEmpty;
    final passVacio = password.isEmpty;
    if (emailVacio || passVacio) {
      setState(() {
        _emailError = emailVacio;
        _passwordError = passVacio;
      });
      _mostrarError('Completa todos los campos.');
      return;
    }

    setState(() {
      _emailError = false;
      _passwordError = false;
      _loading = true;
    });

    try {
      final result = await AuthService.login(
        email,
        password,
        rol: _selectedRole == 0 ? 'cliente' : 'profesional',
      );
      ErrorLogService.configurar(
        token: result.token,
        email: email,
      );
      final rolSeleccionado = _selectedRole == 0 ? 'cliente' : 'profesional';
      if (result.rol != rolSeleccionado) {
        setState(() { _loading = false; });
        _mostrarError(
          result.rol == 'profesional'
              ? 'Esta cuenta es de profesional. Selecciona "Soy Profesional".'
              : 'Esta cuenta es de contratador. Selecciona "Soy Contratador".',
        );
        return;
      }
      final destination = result.rol == 'cliente'
          ? HomeClientScreen(token: result.token, nombre: result.nombre)
          : HomeProfessionalScreen(token: result.token, nombre: result.nombre);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().replaceFirst('Exception: ', '');
      final lower = raw.toLowerCase();
      final esCredenciales = lower.contains('401') ||
          lower.contains('unauthorized') ||
          lower.contains('contraseña') ||
          lower.contains('password') ||
          lower.contains('credentials');
      setState(() {
        _emailError = esCredenciales;
        _passwordError = esCredenciales;
        _loading = false;
      });
      _mostrarError(raw.isNotEmpty ? raw : 'Error al iniciar sesión. Intenta de nuevo.');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 32),
              _buildRoleSwitch(isDark),
              const SizedBox(height: 32),
              _buildLoginForm(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sección 1 ────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isDark
                      ? [const Color.fromARGB(255, 240, 240, 240), const Color.fromARGB(255, 208, 213, 215)]
                      : [const Color.fromARGB(255, 0, 0, 0), const Color.fromARGB(255, 1, 20, 61)],
                ).createShader(bounds),
                child: const Text(
                  'ProServicios',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.black26, offset: Offset(0, 3)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Conectamos profesionales con quienes necesitan sus servicios.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => MyApp.of(context).toggleTheme(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                key: ValueKey(isDark),
                size: 22,
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sección 2 ────────────────────────────────────────────────────────────
  Widget _buildRoleSwitch(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _roleTab(index: 0, label: 'Soy Contratador', icon: Icons.work_outline, isDark: isDark),
          _roleTab(index: 1, label: 'Soy Profesional', icon: Icons.person_outline, isDark: isDark),
        ],
      ),
    );
  }

  Widget _roleTab({required int index, required String label, required IconData icon, required bool isDark}) {
    final isSelected = _selectedRole == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF475569) : const Color(0xFF111827))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18,
                color: isSelected ? Colors.white : isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sección 3 ────────────────────────────────────────────────────────────
  Widget _buildLoginForm(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Align(
              key: ValueKey(_selectedRole),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedRole == 0 ? 'Iniciar Sesión — Contratador' : 'Iniciar Sesión — Profesional',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedRole == 0
                        ? 'Encuentra profesionales de confianza para tus proyectos.'
                        : 'Ofrece tus servicios a quienes los necesitan y consigue nuevos clientes.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _emailController,
            label: 'Correo electrónico',
            hint: 'ejemplo@correo.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            hasError: _emailError,
            onChanged: (_) => setState(() => _emailError = false),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: true,
            isDark: isDark,
            hasError: _passwordError,
            onChanged: (_) => setState(() => _passwordError = false),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF475569) : const Color(0xFF111827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Iniciar sesión',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(initialRole: _selectedRole))),
              child: Text.rich(
                TextSpan(
                  text: '¿No tienes cuenta?  ',
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  children: [
                    TextSpan(
                      text: 'Regístrate',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    final errorColor = const Color(0xFFEF4444);
    final borderColor = hasError
        ? errorColor
        : (isDark ? Colors.grey.shade700 : Colors.grey.shade200);
    final fillColor = hasError
        ? errorColor.withValues(alpha: 0.06)
        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError
                ? errorColor
                : (isDark ? Colors.grey.shade300 : const Color(0xFF374151)),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, size: 20,
                color: hasError ? errorColor : (isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
            suffixIcon: hasError
                ? Icon(Icons.error_outline_rounded, size: 18, color: errorColor)
                : null,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? errorColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF111827)),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
