import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_journal_entry.dart';
import '../services/health_journal_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/screen_header.dart';

class HealthJournalScreen extends StatefulWidget {
  const HealthJournalScreen({super.key});

  @override
  State<HealthJournalScreen> createState() => _HealthJournalScreenState();
}

class _HealthJournalScreenState extends State<HealthJournalScreen> {
  List<HealthJournalEntry> _entries = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedTimeFilter = 'All';

  final List<String> _timeFilters = [
    'All',
    'Last 7 days',
    'Last 30 days',
    'Custom range'
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await HealthJournalService.getAllJournalEntries();
      if (!mounted) return;
      setState(() {
        _entries = entries;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading journal entries: $e')),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchEntries(String keyword) async {
    if (keyword.isEmpty) {
      await _loadEntries();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await HealthJournalService.searchEntries(keyword);
      if (!mounted) return;
      setState(() {
        _entries = entries;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching entries: $e')),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Health Journal',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _loadEntries,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
        children: [
          ScreenHeader(
            title: 'Health Journal',
            subtitle: 'Track your health and symptoms',
            icon: Icons.note_alt_outlined,
            cardTitle: 'Health Tracking',
            cardSubtitle: 'Record your symptoms, medications, and health metrics for better care',
            cardIcon: Icons.health_and_safety,
          ),
          CustomSearchBar(
            hintText: 'Search journal entries...',
            onChanged: _searchEntries,
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          ),
          _buildFilterSection(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildEntriesList(theme),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your journal is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your health by adding entries',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add First Entry',
            onPressed: () => _showAddEntryDialog(context),
            type: ButtonType.primary,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return _buildJournalEntryCard(entry, theme);
      },
    );
  }

  Widget _buildJournalEntryCard(HealthJournalEntry entry, ThemeData theme) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showEntryDetails(entry),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(entry.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    timeFormat.format(entry.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (entry.symptoms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.symptoms.map((symptom) => Chip(
                    label: Text(symptom),
                    backgroundColor: theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onErrorContainer),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEntryDetails(entry),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showEditEntryDialog(entry),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Time Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _timeFilters.map((filter) {
                final isSelected = filter == _selectedTimeFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTimeFilter = filter;
                        });

                        if (filter == 'All') {
                          _loadEntries();
                        } else if (filter == 'Last 7 days') {
                          _filterByDateRange(
                            DateTime.now().subtract(const Duration(days: 7)),
                            DateTime.now(),
                          );
                        } else if (filter == 'Last 30 days') {
                          _filterByDateRange(
                            DateTime.now().subtract(const Duration(days: 30)),
                            DateTime.now(),
                          );
                        } else if (filter == 'Custom range') {
                          _showDateRangePicker();
                        }
                      }
                    },
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _filterByDateRange(DateTime startDate, DateTime endDate) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await HealthJournalService.getEntriesByDateRange(startDate, endDate);
      if (!mounted) return;
      setState(() {
        _entries = entries;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error filtering entries: $e')),
      );
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _showDateRangePicker() async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (pickedDateRange != null) {
      _filterByDateRange(pickedDateRange.start, pickedDateRange.end);
    }
  }

  void _showAddEntryDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final symptomsController = TextEditingController();
    final medicationsController = TextEditingController();
    final treatmentsController = TextEditingController();
    final temperatureController = TextEditingController();
    final heartRateController = TextEditingController();
    final bpSystolicController = TextEditingController();
    final bpDiastolicController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Journal Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                controller: titleController,
                labelText: 'Title',
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: descriptionController,
                labelText: 'Description',
                maxLines: 3,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: symptomsController,
                labelText: 'Symptoms (comma separated)',
                prefixIcon: Icons.sick,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: medicationsController,
                labelText: 'Medications (comma separated)',
                prefixIcon: Icons.medication,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: treatmentsController,
                labelText: 'Treatments (comma separated)',
                prefixIcon: Icons.healing,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: temperatureController,
                      labelText: 'Temperature (°C)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      controller: heartRateController,
                      labelText: 'Heart Rate (BPM)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: bpSystolicController,
                      labelText: 'BP Systolic',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      controller: bpDiastolicController,
                      labelText: 'BP Diastolic',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                CustomSnackBar.show(
                  context: dialogContext,
                  message: 'Title and description are required',
                  type: SnackBarType.warning,
                );
                return;
              }

              // Parse values
              final symptoms = symptomsController.text.isEmpty
                  ? <String>[]
                  : symptomsController.text.split(',').map((e) => e.trim()).toList().cast<String>();

              final medications = medicationsController.text.isEmpty
                  ? <String>[]
                  : medicationsController.text.split(',').map((e) => e.trim()).toList().cast<String>();

              final treatments = treatmentsController.text.isEmpty
                  ? <String>[]
                  : treatmentsController.text.split(',').map((e) => e.trim()).toList().cast<String>();

              double? temperature;
              if (temperatureController.text.isNotEmpty) {
                temperature = double.tryParse(temperatureController.text);
              }

              int? heartRate;
              if (heartRateController.text.isNotEmpty) {
                heartRate = int.tryParse(heartRateController.text);
              }

              int? bpSystolic;
              if (bpSystolicController.text.isNotEmpty) {
                bpSystolic = int.tryParse(bpSystolicController.text);
              }

              int? bpDiastolic;
              if (bpDiastolicController.text.isNotEmpty) {
                bpDiastolic = int.tryParse(bpDiastolicController.text);
              }

              try {
                await HealthJournalService.addJournalEntry(
                  title: titleController.text,
                  description: descriptionController.text,
                  symptoms: symptoms,
                  medications: medications,
                  treatments: treatments,
                  temperature: temperature,
                  heartRate: heartRate,
                  bloodPressureSystolic: bpSystolic,
                  bloodPressureDiastolic: bpDiastolic,
                );

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                _loadEntries();

                CustomSnackBar.show(
                  context: dialogContext,
                  message: 'Journal entry added successfully',
                  type: SnackBarType.success,
                );
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Error adding entry: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditEntryDialog(HealthJournalEntry entry) {
    final titleController = TextEditingController(text: entry.title);
    final descriptionController = TextEditingController(text: entry.description);
    final symptomsController = TextEditingController(text: entry.symptoms.join(', '));
    final medicationsController = TextEditingController(text: entry.medications.join(', '));
    final treatmentsController = TextEditingController(text: entry.treatments.join(', '));
    final temperatureController = TextEditingController(
      text: entry.temperature != null ? entry.temperature.toString() : '',
    );
    final heartRateController = TextEditingController(
      text: entry.heartRate != null ? entry.heartRate.toString() : '',
    );
    final bpSystolicController = TextEditingController(
      text: entry.bloodPressureSystolic != null ? entry.bloodPressureSystolic.toString() : '',
    );
    final bpDiastolicController = TextEditingController(
      text: entry.bloodPressureDiastolic != null ? entry.bloodPressureDiastolic.toString() : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Journal Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                controller: titleController,
                labelText: 'Title',
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: descriptionController,
                labelText: 'Description',
                maxLines: 3,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: symptomsController,
                labelText: 'Symptoms (comma separated)',
                prefixIcon: Icons.sick,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: medicationsController,
                labelText: 'Medications (comma separated)',
                prefixIcon: Icons.medication,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: treatmentsController,
                labelText: 'Treatments (comma separated)',
                prefixIcon: Icons.healing,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: temperatureController,
                      labelText: 'Temperature (°C)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      controller: heartRateController,
                      labelText: 'Heart Rate (BPM)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: bpSystolicController,
                      labelText: 'BP Systolic',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      controller: bpDiastolicController,
                      labelText: 'BP Diastolic',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _confirmDeleteEntry(entry),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                CustomSnackBar.show(
                  context: dialogContext,
                  message: 'Title and description are required',
                  type: SnackBarType.warning,
                );
                return;
              }

              // Parse values
              final symptoms = symptomsController.text.isEmpty
                  ? <String>[]
                  : symptomsController.text.split(',').map((e) => e.trim()).toList().cast<String>();

              final medications = medicationsController.text.isEmpty
                  ? <String>[]
                  : medicationsController.text.split(',').map((e) => e.trim()).toList().cast<String>();

              final treatments = treatmentsController.text.isEmpty
                  ? <String>[]
                  : treatmentsController.text.split(',').map((e) => e.trim()).toList().cast<String>();

              double? temperature;
              if (temperatureController.text.isNotEmpty) {
                temperature = double.tryParse(temperatureController.text);
              }

              int? heartRate;
              if (heartRateController.text.isNotEmpty) {
                heartRate = int.tryParse(heartRateController.text);
              }

              int? bpSystolic;
              if (bpSystolicController.text.isNotEmpty) {
                bpSystolic = int.tryParse(bpSystolicController.text);
              }

              int? bpDiastolic;
              if (bpDiastolicController.text.isNotEmpty) {
                bpDiastolic = int.tryParse(bpDiastolicController.text);
              }

              try {
                final updatedEntry = entry.copyWith(
                  title: titleController.text,
                  description: descriptionController.text,
                  symptoms: symptoms,
                  medications: medications,
                  treatments: treatments,
                  temperature: temperature,
                  heartRate: heartRate,
                  bloodPressureSystolic: bpSystolic,
                  bloodPressureDiastolic: bpDiastolic,
                );

                await HealthJournalService.updateJournalEntry(updatedEntry);

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                _loadEntries();

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Journal entry updated successfully')),
                );
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Error updating entry: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEntry(HealthJournalEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await HealthJournalService.deleteJournalEntry(entry.id);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext); // Close confirmation dialog
                Navigator.pop(dialogContext); // Close edit dialog
                _loadEntries();

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Journal entry deleted successfully')),
                );
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Error deleting entry: $e')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEntryDetails(HealthJournalEntry entry) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Journal Entry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                entry.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${dateFormat.format(entry.date)} at ${timeFormat.format(entry.date)}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.description,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (entry.symptoms.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Symptoms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.symptoms.map((symptom) => Chip(
                    label: Text(symptom),
                    backgroundColor: theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onErrorContainer),
                  )).toList(),
                ),
              ],
              if (entry.medications.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Medications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.medications.map((medication) => Chip(
                    label: Text(medication),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  )).toList(),
                ),
              ],
              if (entry.treatments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Treatments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.treatments.map((treatment) => Chip(
                    label: Text(treatment),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Vital Signs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (entry.temperature != null) ...[
                    _buildVitalSign(
                      theme,
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      value: '${entry.temperature}°C',
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (entry.heartRate != null) ...[
                    _buildVitalSign(
                      theme,
                      icon: Icons.favorite,
                      label: 'Heart Rate',
                      value: '${entry.heartRate} BPM',
                    ),
                  ],
                ],
              ),
              if (entry.bloodPressureSystolic != null && entry.bloodPressureDiastolic != null) ...[
                const SizedBox(height: 8),
                _buildVitalSign(
                  theme,
                  icon: Icons.speed,
                  label: 'Blood Pressure',
                  value: '${entry.bloodPressureSystolic}/${entry.bloodPressureDiastolic} mmHg',
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Edit',
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _showEditEntryDialog(entry);
                    },
                    type: ButtonType.outline,
                    icon: Icons.edit,
                  ),
                  const SizedBox(width: 16),
                  CustomButton(
                    text: 'Close',
                    onPressed: () => Navigator.pop(dialogContext),
                    type: ButtonType.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalSign(ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
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