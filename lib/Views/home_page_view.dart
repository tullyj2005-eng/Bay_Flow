import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bay_flow/ViewModels/home_page_viewmodel.dart';
import 'package:bay_flow/ViewModels/staff_viewmodel.dart';
import 'package:bay_flow/Models/bay.dart';
import 'package:bay_flow/Models/job.dart';
import 'package:bay_flow/Models/staff.dart';
import 'package:bay_flow/Views/checklist_view.dart';
import 'package:bay_flow/Views/staff_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageViewModel(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  int _selectedIndex = 0;

  Widget _getBody(HomePageViewModel viewModel) {
    switch (_selectedIndex) {
      case 0:
        return _buildFloorView(viewModel);
      case 1:
        return const ChecklistView();
      case 2:
        return const StaffView();
      default:
        return _buildFloorView(viewModel);
    }
  }

  void _showAddBaySheet(BuildContext context) {
    final viewModel = context.read<HomePageViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12151C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const _AddBaySheet(),
      ),
    );
  }

  void _showAssignSheet(BuildContext context, Bay bay) {
    final viewModel = context.read<HomePageViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12151C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: _AssignJobSheet(bay: bay),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BayFlow'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.garage,
              color: _selectedIndex == 0
                  ? const Color(0xFFF59E0B)
                  : Colors.grey,
            ),
            tooltip: 'Floor',
            onPressed: () => setState(() => _selectedIndex = 0),
          ),
          IconButton(
            icon: Icon(
              Icons.checklist,
              color: _selectedIndex == 1
                  ? const Color(0xFFF59E0B)
                  : Colors.grey,
            ),
            tooltip: 'Jobs',
            onPressed: () => setState(() => _selectedIndex = 1),
          ),
          IconButton(
            icon: Icon(
              Icons.people,
              color: _selectedIndex == 2
                  ? const Color(0xFFF59E0B)
                  : Colors.grey,
            ),
            tooltip: 'Staff',
            onPressed: () => setState(() => _selectedIndex = 2),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _getBody(viewModel),
    );
  }

  // ── FLOOR VIEW ───────────────────────────────────────
  Widget _buildFloorView(HomePageViewModel viewModel) {
    return Stack(
      fit: StackFit.expand,
      children: [
        viewModel.bays.isEmpty
            ? const Center(
                child: Text(
                  'No bays found — tap + to add one',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: viewModel.bays.length,
                itemBuilder: (context, index) {
                  return _buildBayCard(context, viewModel.bays[index]);
                },
              ),

        // + add bay button
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.black,
            onPressed: () => _showAddBaySheet(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  // ── BAY CARD ─────────────────────────────────────────
  Widget _buildBayCard(BuildContext context, Bay bay) {
    return GestureDetector(
      onTap: bay.status == 'available'
          ? () => _showAssignSheet(context, bay)
          : null,
      child: Card(
        color: const Color(0xFF12151C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: bay.status == 'available'
                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                : bay.status == 'in_progress'
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                    : Colors.transparent,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bay.bayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  _buildStatusBadge(bay.status),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                bay.type,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF)),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                children: bay.equipment.map((eq) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2128),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: const Color(0xFF2A2D35)),
                    ),
                    child: Text(
                      eq,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // available — tap to assign
              if (bay.status == 'available')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle_outline,
                        color: Color(0xFF10B981), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Tap to assign a job',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

              // in progress — show tech + mark done
              if (bay.status == 'in_progress') ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0C10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E2128)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person,
                          size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(
                        bay.assignedTechName ?? 'Unknown Tech',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (bay.assignedJobId != null &&
                          bay.assignedTechId != null) {
                        context
                            .read<HomePageViewModel>()
                            .markJobDone(
                              bayId: bay.id,
                              jobId: bay.assignedJobId!,
                              techId: bay.assignedTechId!,
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mark Done ✓',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
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

  Widget _buildStatusBadge(String status) {
    Color color = status == 'in_progress'
        ? const Color(0xFFF59E0B)
        : status == 'done'
            ? const Color(0xFF6366F1)
            : const Color(0xFF10B981);

    String label = status == 'in_progress'
        ? 'In Progress'
        : status == 'done'
            ? 'Complete'
            : 'Available';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── ADD BAY SHEET ─────────────────────────────────────────────────────────────

class _AddBaySheet extends StatefulWidget {
  const _AddBaySheet();

  @override
  _AddBaySheetState createState() => _AddBaySheetState();
}

class _AddBaySheetState extends State<_AddBaySheet> {
  final _nameController = TextEditingController();
  final _equipmentController = TextEditingController();
  String _selectedType = 'Standard Lift';
  bool _isSaving = false;

  final List<String> _bayTypes = [
    'Standard Lift',
    'Heavy Lift',
    'Specialty',
    'Flat Floor',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a bay name'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final equipment = _equipmentController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    await context.read<HomePageViewModel>().addBay(
          bayName: _nameController.text.trim(),
          type: _selectedType,
          equipment: equipment,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Add New Bay',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel('Bay Name'),
            const SizedBox(height: 6),
            _buildTextField(
                controller: _nameController, hint: 'e.g. Bay 4'),

            const SizedBox(height: 16),

            _buildLabel('Bay Type'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2128),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2D35)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E2128),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14),
                  items: _bayTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedType = val);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildLabel('Equipment (comma separated)'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _equipmentController,
              hint: 'e.g. 2-Post Lift, Alignment Rack',
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Add Bay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9CA3AF),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1E2128),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2D35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2D35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF59E0B)),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ── ASSIGN JOB SHEET ─────────────────────────────────────────────────────────

class _AssignJobSheet extends StatefulWidget {
  final Bay bay;
  const _AssignJobSheet({required this.bay});

  @override
  _AssignJobSheetState createState() => _AssignJobSheetState();
}

class _AssignJobSheetState extends State<_AssignJobSheet> {
  Job? _selectedJob;
  Staff? _selectedTech;
  bool _isAssigning = false;

  Future<void> _assign() async {
    if (_selectedJob == null || _selectedTech == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a job and a tech'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isAssigning = true);

    await context.read<HomePageViewModel>().assignJob(
          bayId: widget.bay.id,
          jobId: _selectedJob!.id,
          techId: _selectedTech!.id,
          techName: _selectedTech!.name,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageViewModel>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Assign Job — ${widget.bay.bayName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'SELECT JOB',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            viewModel.queue.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2128),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'No jobs in queue',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: viewModel.queue.map((job) {
                      final isSelected = _selectedJob?.id == job.id;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedJob = job),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.15)
                                : const Color(0xFF1E2128),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF2A2D35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.customerName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.vehicle,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.jobType,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFFF59E0B),
                                    size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 20),

            const Text(
              'SELECT TECH',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            ChangeNotifierProvider(
              create: (_) => StaffViewModel(),
              child: Builder(
                builder: (context) {
                  final staffViewModel =
                      context.watch<StaffViewModel>();
                  final availableStaff = staffViewModel.staffList
                      .where((s) => s.status == 'available')
                      .toList();

                  if (staffViewModel.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (availableStaff.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2128),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'No techs available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: availableStaff.map((staff) {
                      final isSelected =
                          _selectedTech?.id == staff.id;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedTech = staff),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                    .withValues(alpha: 0.15)
                                : const Color(0xFF1E2128),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF2A2D35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2D35),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    staff.name.isNotEmpty
                                        ? staff.name
                                            .split(' ')
                                            .map((e) => e[0])
                                            .take(2)
                                            .join()
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  staff.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF10B981),
                                    size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAssigning ? null : _assign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isAssigning
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Assign Job',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}