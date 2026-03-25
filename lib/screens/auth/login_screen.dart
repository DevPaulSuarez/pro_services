import 'package:flutter/material.dart';
import 'package:pro_services/main.dart';
import 'package:pro_services/screens/auth/register_screen.dart';
import 'package:pro_services/screens/client/home_client_screen.dart';
import 'package:pro_services/screens/professional/home_professional_screen.dart';
import 'package:pro_services/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedRole = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    try {
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      final destination = result.rol == 'cliente'
          ? const HomeClientScreen()
          : const HomeProfessionalScreen();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
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
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: true,
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF475569) : const Color(0xFF111827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Iniciar sesión', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF111827),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
