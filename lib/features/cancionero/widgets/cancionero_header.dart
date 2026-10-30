// lib/features/cancionero/widgets/cancionero_header.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

class CancioneroHeader extends StatelessWidget {
  final int totalCanciones;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const CancioneroHeader({
    super.key,
    required this.totalCanciones,
    required this.searchCtrl,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, Sp.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.granateOscuro, AppColors.granate],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.granate.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Cancionero', style: AppText.h1.copyWith(color: AppColors.dorado, fontSize: 28)),
                const SizedBox(width: Sp.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.2),
                    borderRadius: Rad.rPill,
                  ),
                  child: Text('$totalCanciones', style: AppText.caption.copyWith(color: AppColors.dorado, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: Sp.lg),
            
            // Buscador
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: Rad.rMd,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: searchCtrl,
                onChanged: onSearchChanged,
                style: AppText.body.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar canción, autor o ritmo...',
                  hintStyle: AppText.body.copyWith(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: onClearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: Sp.lg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}