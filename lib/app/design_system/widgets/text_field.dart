import 'package:ezwork/app/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom text form field widget that provides enhanced functionality including:
/// - Character counter
/// - Custom styling
/// - Error handling
/// - Description text
class EzWorkTextFormField extends StatefulWidget {
  const EzWorkTextFormField({
    required this.labelText,
    this.autoFocus,
    this.controller,
    this.initialValue,
    this.focusNode,
    super.key,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.readOnly = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.maxLines = 1,
    this.expands = false,
    this.maxLengthEnforcement,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.hintText,
    this.errorText,
    this.descriptionText,
    this.showCounter = false,
    this.inputFormatters,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.sentences,
  });

  /// The text displayed above the input field.
  final String labelText;

  /// Whether the field should automatically focus when the widget is built.
  final bool? autoFocus;

  /// The controller for the text input.
  final TextEditingController? controller;

  /// The focus node for managing the focus of the input field.
  final FocusNode? focusNode;

  /// The initial value of the text input.
  final String? initialValue;

  /// The type of keyboard to use for the input.
  final TextInputType? keyboardType;

  /// The capitalization strategy for the input text.
  final TextCapitalization textCapitalization;

  /// The action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Whether the input field is enabled.
  final bool enabled;

  /// The alignment of the text within the input field.
  final TextAlign textAlign;

  /// The vertical alignment of the text within the input field.
  final TextAlignVertical? textAlignVertical;

  /// Whether the input field is read-only.
  final bool readOnly;

  /// Whether to obscure the text input (for passwords).
  final bool obscureText;

  /// Whether to enable autocorrect for the input.
  final bool autocorrect;

  /// The enforcement of the maximum length of the input.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// The maximum number of lines for the input.
  final int? maxLines;

  /// The minimum number of lines for the input.
  final int? minLines;

  /// Whether the input field expands to fill available space.
  final bool expands;

  /// The maximum length of the input.
  final int? maxLength;

  /// Callback for when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback for when the field is submitted.
  final ValueChanged<String>? onFieldSubmitted;

  /// Callback for when the input field is tapped.
  final VoidCallback? onTap;

  /// The hint text displayed when the input is empty.
  final String? hintText;

  /// The error message displayed when validation fails.
  final String? errorText;

  /// Additional description text displayed below the input field.
  final String? descriptionText;

  /// Whether to show a character counter below the input field.
  final bool showCounter;

  /// A function for validating the input.
  final String? Function(String?)? validator;

  /// A list of formatters to apply to the input text.
  final List<TextInputFormatter>? inputFormatters;

  /// An optional widget displayed before the input field.
  final Widget? prefixIcon;

  /// An optional widget displayed after the input field.
  final Widget? suffixIcon;

  @override
  State<EzWorkTextFormField> createState() => _EzWorkTextFormFieldState();
}

class _EzWorkTextFormFieldState extends State<EzWorkTextFormField> {
  /// Tracks remaining characters when maxLength is set
  int remainingCharacters = 0;

  /// Controller for the text input, either provided by parent or created internally
  late TextEditingController _innerController;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _innerController = widget.controller ?? TextEditingController();

    // Set initial text if provided
    if (widget.initialValue != null) {
      _innerController.text = widget.initialValue!;
    }

    // Calculate initial remaining characters
    remainingCharacters =
        (widget.maxLength ?? 0) - _innerController.text.length;
    _innerController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant EzWorkTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (widget.controller != null &&
        widget.controller != oldWidget.controller) {
      _innerController.removeListener(_onTextChanged);
      _innerController = widget.controller!;
      _innerController.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    // Clean up controller
    if (widget.controller != _innerController) {
      _innerController
        ..removeListener(_onTextChanged)
        ..dispose();
    }

    super.dispose();
  }

  /// Updates the remaining characters count when text changes
  void _onTextChanged() {
    if (mounted) {
      setState(() {
        remainingCharacters =
            (widget.maxLength ?? 0) - _innerController.text.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledColor = theme.hintColor;
    final normalColor = theme.colorScheme.onSurface;
    final focusedColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText.isNotEmpty)
          Text(
            widget.labelText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.enabled ? normalColor : disabledColor,
            ),
          ),
        TextFormField(
          autofocus: widget.autoFocus ?? false,
          controller: _innerController,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          readOnly: widget.readOnly,
          obscureText: widget.obscureText,
          autocorrect: widget.autocorrect,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          maxLines: widget.maxLines,
          expands: widget.expands,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: widget.enabled ? normalColor : disabledColor,
          ),
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: normalColor, width: 2),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: normalColor, width: 2),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: disabledColor, width: 2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: focusedColor, width: 2),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            enabled: widget.enabled,
            hintStyle: theme.textTheme.bodyLarge,
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.symmetric(
              vertical: EzWorkSpacing.spacing12,
            ),
            counterText: '',
            error: widget.errorText == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: EzWorkSpacing.medium),
                    child: Row(
                      children: [
                        RotatedBox(
                          quarterTurns: 2,
                          child: Icon(
                            Icons.info,
                            color: theme.colorScheme.errorContainer,
                          ),
                        ),
                        const SizedBox(width: EzWorkSpacing.small),
                        Expanded(
                          child: Text(
                            widget.errorText!,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints: const BoxConstraints(
              maxWidth: 32,
              maxHeight: 32,
            ),
            suffixIcon: widget.suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              maxWidth: 32,
              maxHeight: 32,
            ),
          ),
        ),
        if (widget.showCounter && widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: EzWorkSpacing.medium),
            child: Text(
              remainingCharacters > 1
                  ? '$remainingCharacters characters left'
                  : '$remainingCharacters character left',
              style: theme.textTheme.labelMedium?.copyWith(
                color: widget.enabled ? normalColor : disabledColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (widget.descriptionText != null)
          Padding(
            padding: const EdgeInsets.only(top: EzWorkSpacing.medium),
            child: Text(
              widget.descriptionText!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: widget.enabled ? normalColor : disabledColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
