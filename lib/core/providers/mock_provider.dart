import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global toggle for mock mode vs remote API mode
final isMockModeProvider = StateProvider<bool>((ref) => true);
