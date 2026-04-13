import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/category.dart';
import 'package:border_po/state/app_state.dart';
import '../theme/dashboard_colors.dart';

/// Form dialog (bottom sheet) for adding and editing categories.
class CategoryEditorSheet {
  static Future<void> show(BuildContext context, {ProductCategory? existing}) async {
    final state = context.read<AppState>();
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DC.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final viewInsets = MediaQuery.of(ctx).viewInsets;

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: DC.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      isEdit ? 'Edit Kategori' : 'Tambah Kategori',
                      style: manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: DC.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name field
                    _StyledField(
                      controller: nameCtrl,
                      label: 'Nama Kategori',
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    GestureDetector(
                      onTap: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Nama wajib diisi',
                                style: manrope(color: Colors.white),
                              ),
                              backgroundColor: DC.error,
                            ),
                          );
                          return;
                        }
                        if (isEdit) {
                          await state.updateCategory(
                            existing.id,
                            name,
                          );
                        } else {
                          await state.addCategory(
                            name,
                          );
                        }
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [DC.primary, DC.primaryDim],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Kategori',
                            style: manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DC.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Styled text field ───────────────────────────────────────────────────────

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const _StyledField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DC.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textCapitalization: textCapitalization,
        style: manrope(fontSize: 14, color: DC.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: manrope(
            fontSize: 14,
            color: DC.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
