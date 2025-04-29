import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/data_service.dart';
import '../services/emergency_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/section_header.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final DataService _dataService = DataService();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;
  bool _isSendingEmergency = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final contacts = await _dataService.getEmergencyContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomSnackBar.show(
        context: context,
        message: 'Error loading contacts: $e',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _makeEmergencyCall() async {
    try {
      final success = await EmergencyService.makeEmergencyCall('911');
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: success
            ? 'Initiating emergency call to 911'
            : 'Failed to initiate emergency call',
        type: success ? SnackBarType.success : SnackBarType.error,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Error making emergency call: $e',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _sendEmergencyAlert() async {
    if (_contacts.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'No emergency contacts available',
        type: SnackBarType.warning,
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSendingEmergency = true;
    });

    try {
      final message =
          'EMERGENCY ALERT: I need immediate assistance. This is an emergency.';
      final success =
          await EmergencyService.sendEmergencySMS(_contacts, message);

      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: success
            ? 'Emergency alert sent successfully'
            : 'Failed to send emergency alert',
        type: success ? SnackBarType.success : SnackBarType.error,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Error sending emergency alert: $e',
        type: SnackBarType.error,
      );
    } finally {
      setState(() {
        _isSendingEmergency = false;
      });
    }
  }

  Future<void> _addOrEditContact([EmergencyContact? contact]) async {
    final result = await showModalBottomSheet<EmergencyContact>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ContactFormSheet(contact: contact),
    );

    if (result != null) {
      try {
        if (contact == null) {
          await _dataService.addEmergencyContact(result);
        } else {
          await _dataService.updateEmergencyContact(result);
        }
        _loadContacts();
      } catch (e) {
        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: 'Error saving contact: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          CustomButton(
            text: 'CANCEL',
            onPressed: () => Navigator.pop(context, false),
            type: ButtonType.text,
          ),
          CustomButton(
            text: 'DELETE',
            onPressed: () => Navigator.pop(context, true),
            type: ButtonType.text,
            textColor: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dataService.deleteEmergencyContact(contact.id);
        _loadContacts();
        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: 'Contact deleted',
          type: SnackBarType.success,
        );
      } catch (e) {
        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: 'Error deleting contact: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _callContact(EmergencyContact contact) async {
    try {
      final success = await EmergencyService.makeEmergencyCall(contact.phoneNumber);
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: success
            ? 'Initiating call to ${contact.name}'
            : 'Failed to initiate call',
        type: success ? SnackBarType.success : SnackBarType.error,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Error making call: $e',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Emergency',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEmergencyActions(context),
              SectionHeader(
                title: 'Emergency Contacts',
                subtitle: 'Quick access to your emergency contacts',
                icon: Icons.person_add_alt_1,
                onIconPressed: () => _addOrEditContact(),
              ),
              _buildEmergencyContacts(context),
              const SectionHeader(
                title: 'Emergency Services',
                subtitle: 'Access emergency medical services',
              ),
              _buildEmergencyServices(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyActions(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmergencyButton(
                context,
                label: 'Call 911',
                icon: Icons.call,
                backgroundColor: theme.colorScheme.error,
                onPressed: _makeEmergencyCall,
              ),
              _buildEmergencyButton(
                context,
                label: 'SOS Alert',
                icon: Icons.warning_amber_rounded,
                backgroundColor: theme.colorScheme.secondary,
                onPressed: _sendEmergencyAlert,
              ),
              _buildEmergencyButton(
                context,
                label: 'Medical ID',
                icon: Icons.medical_information,
                backgroundColor: theme.colorScheme.tertiary,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    final bool isLoading = label == 'SOS Alert' && _isSendingEmergency;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(20.0),
        child: Ink(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor.withOpacity(0.15),
                backgroundColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: backgroundColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
                        ),
                      )
                    : Icon(
                        icon,
                        color: backgroundColor,
                        size: 28,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: backgroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No emergency contacts added yet',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your trusted contacts for emergency situations',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          ..._contacts.map((contact) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildContactCard(contact),
              )),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      contact.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (contact.isPrimaryContact) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Primary',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contact.relationship,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _callContact(contact),
            color: theme.colorScheme.primary,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _addOrEditContact(contact),
            color: theme.colorScheme.tertiary,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteContact(contact),
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyServices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildServiceCard(
            context,
            title: 'Nearby Hospitals',
            subtitle: 'Find the closest medical facilities',
            icon: Icons.local_hospital,
            onTap: () => Navigator.pushNamed(context, '/hospital-locator'),
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            context,
            title: 'First Aid Guide',
            subtitle: 'Step-by-step emergency care instructions',
            icon: Icons.medical_services,
            onTap: () => Navigator.pushNamed(context, '/first-aid'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactFormSheet extends StatefulWidget {
  final EmergencyContact? contact;

  const ContactFormSheet({super.key, this.contact});

  @override
  State<ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends State<ContactFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  bool _isPrimaryContact = false;
  bool _notifyInEmergency = true;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phoneNumber;
      _relationshipController.text = widget.contact!.relationship;
      _isPrimaryContact = widget.contact!.isPrimaryContact;
      _notifyInEmergency = widget.contact!.notifyInEmergency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final contact = EmergencyContact(
        id: widget.contact?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
        isPrimaryContact: _isPrimaryContact,
        notifyInEmergency: _notifyInEmergency,
      );
      Navigator.pop(context, contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.contact == null
                      ? 'Add Emergency Contact'
                      : 'Edit Emergency Contact',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextFormField(
              controller: _nameController,
              labelText: 'Name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _phoneController,
              labelText: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _relationshipController,
              labelText: 'Relationship',
              prefixIcon: Icons.people,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isPrimaryContact,
                        activeColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) {
                          setState(() {
                            _isPrimaryContact = value ?? false;
                          });
                        },
                      ),
                      Text('Primary Contact',
                          style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'MAIN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _notifyInEmergency,
                        activeColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) {
                          setState(() {
                            _notifyInEmergency = value ?? true;
                          });
                        },
                      ),
                      Text('Notify in Emergency',
                          style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: widget.contact == null ? 'ADD CONTACT' : 'UPDATE CONTACT',
                onPressed: _submitForm,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
