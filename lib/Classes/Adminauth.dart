import 'package:shared_preferences/shared_preferences.dart';

// Serviço para autenticação de administrador
class AdminAuthService {
  static const String adminPassword = "adminwial";
  static const String adminAuthKey = "admin_authenticated";
  
  // Verificar se a senha está correta
  bool verificarSenha(String senha) {
    return senha == adminPassword;
  }
  
  // Salvar estado de autenticação
  Future<void> salvarAutenticacao(bool autenticado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(adminAuthKey, autenticado);
  }
  
  // Verificar se está autenticado
  Future<bool> isAutenticado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(adminAuthKey) ?? false;
  }
  
  // Fazer logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(adminAuthKey, false);
  }
}