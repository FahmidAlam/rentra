import 'package:flutter/material.dart';
import 'package:rentra/core/theme/app_theme.dart';

// ============================================================================
// RESPONSIVE SIZED BOXES - For Spacing & Responsiveness
// ============================================================================

/// Responsive horizontal spacing
class HSpace extends StatelessWidget {
  final double value; // Base value (scales on responsive devices)
  
  const HSpace(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth > 600 ? 1.2 : 1.0; // Scale up on tablets
    return SizedBox(width: value * scale);
  }
}

/// Responsive vertical spacing
class VSpace extends StatelessWidget {
  final double value; // Base value (scales on responsive devices)
  
  const VSpace(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = screenHeight > 800 ? 1.1 : 1.0; // Scale up on tall screens
    return SizedBox(height: value * scale);
  }
}

// ============================================================================
// CUSTOM BUTTONS - Reusable Button Components
// ============================================================================

/// Primary Action Button with Gradient
class RentraPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;

  const RentraPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        icon: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                ),
              )
            : icon != null
                ? Icon(icon)
                : const SizedBox.shrink(),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: RentraColors.darkTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 4 : 0,
        ),
      ),
    );
  }
}

/// Secondary Action Button
class RentraSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;

  const RentraSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = RentraColors.limeGreen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, color: color) : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Danger Action Button (Red)
class RentraDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const RentraDangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: RentraColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM CARDS - Reusable Card Components
// ============================================================================

/// Property Card
class RentraPropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const RentraPropertyCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Favorite Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: RentraColors.background,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: RentraColors.error,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: RentraColors.darkText,
                    ),
                  ),
                  const VSpace(4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: RentraColors.lightText),
                      const HSpace(4),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: RentraColors.lightText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const VSpace(8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: RentraColors.darkTeal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status Badge
class RentraStatusBadge extends StatelessWidget {
  final String label;
  final String status; // pending, approved, rejected
  final IconData? icon;

  const RentraStatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.icon,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return RentraColors.success;
      case 'rejected':
        return RentraColors.error;
      case 'pending':
      default:
        return RentraColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const HSpace(4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Row Widget
class RentraInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const RentraInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: RentraColors.darkTeal),
              const HSpace(8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: RentraColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: RentraColors.darkText,
          ),
        ),
      ],
    );
  }
}

/// Loading Skeleton
class RentraSkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const RentraSkeletonLoader({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: RentraColors.background,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const LinearProgressIndicator(
        backgroundColor: RentraColors.background,
        valueColor: AlwaysStoppedAnimation<Color>(RentraColors.divider),
      ),
    );
  }
}

/// Empty State Widget
class RentraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? actionButton;
  final String? actionLabel;

  const RentraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionButton,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: RentraColors.lightText.withOpacity(0.3),
          ),
          const VSpace(16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RentraColors.darkText,
            ),
          ),
          const VSpace(8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: RentraColors.lightText,
            ),
          ),
          if (actionButton != null && actionLabel != null) ...[
            const VSpace(24),
            RentraPrimaryButton(
              label: actionLabel!,
              onPressed: actionButton!,
            ),
          ],
        ],
      ),
    );
  }
}