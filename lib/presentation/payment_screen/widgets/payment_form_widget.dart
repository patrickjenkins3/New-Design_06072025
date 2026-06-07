import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/subscription_models.dart';
import '../../../theme/app_theme.dart';

class PaymentFormWidget extends StatefulWidget {
  final SubscriptionPlan selectedPlan;
  final bool isAnnualBilling;
  final Function(String) onPaymentMethodSelected;
  final String? selectedPaymentMethod;

  const PaymentFormWidget({
    super.key,
    required this.selectedPlan,
    required this.isAnnualBilling,
    required this.onPaymentMethodSelected,
    this.selectedPaymentMethod,
  });

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  bool _saveCard = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 2.h),

        // Payment method selection
        _buildPaymentMethodSelection(),
        SizedBox(height: 3.h),

        // Card form (if card payment selected)
        if (widget.selectedPaymentMethod == 'card') ...[
          _buildCardForm(),
          SizedBox(height: 2.h),
        ],

        // Billing address section (only if payment method selected)
        if (widget.selectedPaymentMethod != null) _buildBillingAddressSection(),
      ],
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      children: [
        _buildPaymentOption(
          'card',
          'Credit/Debit Card',
          Icons.credit_card,
          'Visa, Mastercard, American Express',
        ),
        SizedBox(height: 1.h),
        _buildPaymentOption(
          'apple_pay',
          'Apple Pay',
          Icons.apple,
          'Touch ID or Face ID',
          enabled: Theme.of(context).platform == TargetPlatform.iOS,
        ),
        SizedBox(height: 1.h),
        _buildPaymentOption(
          'google_pay',
          'Google Pay',
          Icons.android,
          'Quick and secure',
          enabled: Theme.of(context).platform == TargetPlatform.android,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
    String subtitle, {
    bool enabled = true,
  }) {
    final isSelected = widget.selectedPaymentMethod == value;

    return GestureDetector(
      onTap: enabled ? () => widget.onPaymentMethodSelected(value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight
                : enabled
                    ? Colors.grey[300]!
                    : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: enabled ? Colors.white : Colors.grey[100],
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: widget.selectedPaymentMethod,
              onChanged: enabled
                  ? (val) => widget.onPaymentMethodSelected(val!)
                  : null,
              activeColor: AppTheme.primaryLight,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            SizedBox(width: 2.w),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enabled
                    ? AppTheme.primaryLight.withAlpha(26)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 6.w,
                color: enabled ? AppTheme.primaryLight : Colors.grey,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: enabled ? AppTheme.textPrimaryLight : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: enabled ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryLight,
                size: 5.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 2.h),

          // Card number
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty == true) {
                return 'Please enter card number';
              }
              return null;
            },
            onChanged: _formatCardNumber,
          ),
          SizedBox(height: 2.h),

          // Expiry and CVV row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    hintText: '12/25',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Required';
                    }
                    return null;
                  },
                  onChanged: _formatExpiry,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Card holder name
          TextFormField(
            controller: _cardHolderController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value?.isEmpty == true) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),

          // Save card checkbox
          CheckboxListTile(
            title: const Text('Save card for future payments'),
            subtitle: const Text('Your card will be stored securely'),
            value: _saveCard,
            onChanged: (value) => setState(() => _saveCard = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppTheme.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddressSection() {
    return ExpansionTile(
      title: Text(
        'Billing Address',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryLight,
        ),
      ),
      subtitle: const Text('Required for tax calculation'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ZIP Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'US', child: Text('United States')),
                        DropdownMenuItem(value: 'CA', child: Text('Canada')),
                        DropdownMenuItem(
                            value: 'UK', child: Text('United Kingdom')),
                        DropdownMenuItem(value: 'AU', child: Text('Australia')),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ],
    );
  }

  void _formatCardNumber(String value) {
    final text = value.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    _cardNumberController.value = TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }

  void _formatExpiry(String value) {
    final text = value.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 4; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }

    _expiryController.value = TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
