import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/responsive_utils.dart';

/// Custom error widget that provides user-friendly error messages
/// instead of technical error details
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? title;
  final bool showRetryButton;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.title,
    this.showRetryButton = true,
  });

  /// Factory constructor for common network errors
  factory CustomErrorWidget.network({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Connection Issue',
      message: AppStrings.networkError,
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }

  /// Factory constructor for authentication errors
  factory CustomErrorWidget.authentication({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Sign In Required',
      message: AppStrings.authenticationError,
      icon: Icons.lock_outline,
      onRetry: onRetry,
      showRetryButton: false,
    );
  }

  /// Factory constructor for permission errors
  factory CustomErrorWidget.permission({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Access Restricted',
      message: AppStrings.permissionDenied,
      icon: Icons.block,
      onRetry: onRetry,
      showRetryButton: false,
    );
  }

  /// Factory constructor for server errors
  factory CustomErrorWidget.server({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Service Issue',
      message: AppStrings.serverError,
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }

  /// Factory constructor for data loading errors
  factory CustomErrorWidget.dataLoading({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Loading Error',
      message: AppStrings.loadingDataError,
      icon: Icons.refresh,
      onRetry: onRetry,
    );
  }

  /// Factory constructor for payment errors
  factory CustomErrorWidget.payment({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Payment Issue',
      message: AppStrings.paymentFailed,
      icon: Icons.payment,
      onRetry: onRetry,
    );
  }

  /// Factory constructor for general errors
  factory CustomErrorWidget.general({
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Something went wrong',
      message: customMessage ?? AppStrings.unknownError,
      icon: Icons.error_outline,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding(horizontal: 24.0, vertical: 32.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.maxContentWidth,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Icon(
                icon,
                size: context.iconSize(baseSize: 64.0),
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: 3.h),

              // Error Title
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: context.responsiveFontSize(24),
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
              ],

              // Error Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: context.responsiveFontSize(16),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              // Retry Button
              if (onRetry != null && showRetryButton) ...[
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: context.buttonHeight(),
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(
                      Icons.refresh,
                      size: context.iconSize(baseSize: 20),
                    ),
                    label: Text(
                      AppStrings.tryAgain,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading widget with consistent styling
class CustomLoadingWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;

  const CustomLoadingWidget({
    super.key,
    this.message,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: context.iconSize(baseSize: 48),
              height: context.iconSize(baseSize: 48),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (showMessage) ...[
              SizedBox(height: 3.h),
              Text(
                message ?? AppStrings.loading,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: context.responsiveFontSize(16),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget for when there's no data to display
class CustomEmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const CustomEmptyWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding(horizontal: 24.0, vertical: 32.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.maxContentWidth,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: context.iconSize(baseSize: 64.0),
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withAlpha(128),
              ),
              SizedBox(height: 3.h),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: context.responsiveFontSize(22),
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: context.responsiveFontSize(16),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              if (onAction != null && actionText != null) ...[
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: context.buttonHeight(),
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(),
                        ),
                      ),
                    ),
                    child: Text(
                      actionText!,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
