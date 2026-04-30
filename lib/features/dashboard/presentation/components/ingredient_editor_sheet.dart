import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:border_po/models/ingredient.dart';
import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

class IngredientEditorSheet extends StatefulWidget {
  final Ingredient? existing;

  const IngredientEditorSheet({super.key, this.existing});

  static Future<void> show(BuildContext context, {Ingredient? existing}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => IngredientEditorSheet._withScroll(
          existing: existing,
          scrollController: scrollController,
        ),
      ),
    );
  }

  factory IngredientEditorSheet._withScroll({
    Ingredient? existing,
    required ScrollController scrollController,
  }) {
    return IngredientEditorSheet(existing: existing, key: ValueKey(scrollController));
  }

  @override
  State<IngredientEditorSheet> createState() => _IngredientEditorSheetState();
}

class _IngredientEditorSheetState extends State<IngredientEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _stockCtrl;
  
  late TextEditingController _buyPriceCtrl;
  late TextEditingController _buyQtyCtrl;

  String _formatInitial(int value) {
    if (value == 0) return '';
    return NumberFormat('#,###', 'id_ID').format(value);
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _unitCtrl = TextEditingController(text: widget.existing?.unit ?? 'gram');
    _stockCtrl = TextEditingController(text: widget.existing != null ? _formatInitial(widget.existing!.stock) : '');
    
    // Reverse calculate for display if existing
    if (widget.existing != null) {
      _buyPriceCtrl = TextEditingController(text: _formatInitial(widget.existing!.costPerUnit * 100));
      _buyQtyCtrl = TextEditingController(text: '100'); // Dummy 100 to show the math
    } else {
      _buyPriceCtrl = TextEditingController();
      _buyQtyCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _stockCtrl.dispose();
    _buyPriceCtrl.dispose();
    _buyQtyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text;
    final unit = _unitCtrl.text;
    final stock = parseFormattedNumber(_stockCtrl.text);
    
    final buyPrice = parseFormattedNumber(_buyPriceCtrl.text);
    final buyQty = parseFormattedNumber(_buyQtyCtrl.text);
    
    // Calculate cost per unit
    final costPerUnit = (buyPrice / (buyQty == 0 ? 1 : buyQty)).round();

    final state = context.read<AppState>();
    if (widget.existing == null) {
      state.addIngredient(
        name: name,
        unit: unit,
        costPerUnit: costPerUnit,
        stock: stock,
      );
    } else {
      state.updateIngredient(
        id: widget.existing!.id,
        name: name,
        unit: unit,
        costPerUnit: costPerUnit,
        stock: stock,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: DC.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              children: [
                Text(
                  widget.existing == null ? 'Tambah Bahan Baku' : 'Edit Bahan Baku',
                  style: manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: DC.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: DC.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nama Bahan
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDeco('Nama Bahan (Contoh: Gula Aren)'),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // Unit & Sisa Stok
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _unitCtrl,
                        decoration: _inputDeco('Satuan (gram, ml, pcs)'),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 8),
                      // Quick select chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ['gram', 'ml', 'pcs'].map((u) => 
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _unitCtrl.text = u;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: DC.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                u, 
                                style: manrope(fontSize: 11, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant)
                              ),
                            ),
                          )
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    decoration: _inputDeco('Stok Saat Ini'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ThousandSeparatorFormatter(),
                    ],
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text(
              'Hitung Modal per Satuan',
              style: manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DC.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Contoh: Beli gula Rp 25.000, isinya 500 gram → modal Rp 50/gram',
              style: manrope(
                fontSize: 11,
                color: DC.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Harga Beli & Isi per Beli
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buyPriceCtrl,
                    decoration: _inputDeco('Harga Beli (Rp)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ThousandSeparatorFormatter(),
                    ],
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    onChanged: (_) => setState((){}), // trigger re-render for cost preview
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _buyQtyCtrl,
                    decoration: _inputDeco('Isi / Dapat Berapa?'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ThousandSeparatorFormatter(),
                    ],
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    onChanged: (_) => setState((){}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Preview Modal per satuan
            Builder(
              builder: (ctx) {
                final bp = parseFormattedNumber(_buyPriceCtrl.text);
                final bq = parseFormattedNumber(_buyQtyCtrl.text);
                final unit = _unitCtrl.text.isEmpty ? 'satuan' : _unitCtrl.text;
                final cost = (bp / (bq == 0 ? 1 : bq)).round();

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DC.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Jadi modal: ${formatRupiah(cost)} per $unit',
                    style: manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DC.onPrimaryContainer,
                    ),
                  ),
                );
              }
            ),

            const SizedBox(height: 32),

            // Save btn
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: DC.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Simpan Bahan Baku',
                style: manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: manrope(color: DC.onSurfaceVariant),
      filled: true,
      fillColor: DC.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DC.outlineVariant.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DC.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DC.primary, width: 2),
      ),
    );
  }
}
