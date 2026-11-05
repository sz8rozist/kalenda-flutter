import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/simple_viewmodels.dart';

/// A kezdőképernyő kiválasztott füle (új foglalás / foglalásaim / fiókom).
final homeTabProvider = NotifierProvider<TabIndexViewModel, int>(TabIndexViewModel.new);
