import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:border_po/models/category.dart';
import '../theme/dashboard_colors.dart';

class CategoryGridCard extends StatelessWidget {
  final ProductCategory category;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: DC.primary.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Info area ───────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: DC.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$productCount Produk',
                            style: manrope(
                              fontSize: 12,
                              color: DC.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action button
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: DC.onSurfaceVariant,
                        size: 20,
                      ),
                      color: DC.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (val) {
                        if (val == 'edit') {
                          onEdit();
                        } else if (val == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: manrope(
                              fontWeight: FontWeight.w600,
                              color: DC.onSurface,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Hapus',
                            style: manrope(
                              fontWeight: FontWeight.w700,
                              color: DC.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
