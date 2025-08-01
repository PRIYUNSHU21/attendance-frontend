import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../utils/app_theme.dart';

class OrganizationSearchField extends StatefulWidget {
  final List<Organization> organizations;
  final Organization? selectedOrganization;
  final Function(Organization?) onSelectionChanged;
  final String? hintText;
  final String? labelText;
  final bool isLoading;

  const OrganizationSearchField({
    super.key,
    required this.organizations,
    required this.onSelectionChanged,
    this.selectedOrganization,
    this.hintText = 'Search for your organization...',
    this.labelText = 'Organization',
    this.isLoading = false,
  });

  @override
  State<OrganizationSearchField> createState() =>
      _OrganizationSearchFieldState();
}

class _OrganizationSearchFieldState extends State<OrganizationSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(OrganizationSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOrganization != oldWidget.selectedOrganization) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final text = widget.selectedOrganization?.name ?? '';
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Organization>(
      validator: (value) {
        if (widget.selectedOrganization == null) {
          return 'Please select an organization';
        }
        return null;
      },
      builder: (FormFieldState<Organization> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<Organization>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return widget.organizations;
                }
                return widget.organizations.where((Organization organization) {
                  return organization.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              displayStringForOption: (Organization option) => option.name,
              onSelected: (Organization selection) {
                widget.onSelectionChanged(selection);
                field.didChange(selection);
              },
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    // Sync the autocomplete controller with our internal controller
                    if (widget.selectedOrganization != null &&
                        textEditingController.text !=
                            widget.selectedOrganization!.name) {
                      textEditingController.text =
                          widget.selectedOrganization!.name;
                    }

                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: widget.labelText,
                        hintText: widget.hintText,
                        prefixIcon: Icon(
                          Icons.business_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        suffixIcon: widget.selectedOrganization != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  textEditingController.clear();
                                  widget.onSelectionChanged(null);
                                  field.didChange(null);
                                },
                              )
                            : Icon(Icons.search, color: AppTheme.textMedium),
                        border: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadiusMedium,
                        ),
                        errorText: field.errorText,
                      ),
                      onChanged: (value) {
                        // If user clears the text or types something that doesn't match
                        // the selected organization, clear the selection
                        if (value.isEmpty ||
                            (widget.selectedOrganization != null &&
                                value != widget.selectedOrganization!.name)) {
                          widget.onSelectionChanged(null);
                          field.didChange(null);
                        }
                      },
                      onFieldSubmitted: (value) => onFieldSubmitted(),
                    );
                  },
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<Organization> onSelected,
                    Iterable<Organization> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        borderRadius: AppTheme.borderRadiusMedium,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Organization option = options.elementAt(
                                index,
                              );
                              final bool isSelected =
                                  widget.selectedOrganization?.orgId ==
                                  option.orgId;

                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor.withOpacity(0.1)
                                        : null,
                                    border: index < options.length - 1
                                        ? Border(
                                            bottom: BorderSide(
                                              color: AppTheme.dividerColor,
                                              width: 0.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option.name,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: AppTheme.primaryColor,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
            ),
          ],
        );
      },
    );
  }
}
