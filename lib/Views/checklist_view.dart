import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bay_flow/ViewModels/checklist_viewmodel.dart';
import 'package:bay_flow/Models/job.dart';

class ChecklistView extends StatelessWidget {
  const ChecklistView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChecklistViewModel(),
      child: const _ChecklistContent(),
    );
  }
}

class _ChecklistContent extends StatelessWidget {
  const _ChecklistContent();

  void _showAddJobSheet(BuildContext context) {
  // grab the viewmodel before opening the sheet
  final viewModel = context.read<ChecklistViewModel>();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Color(0xFF12151C),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ChangeNotifierProvider.value(
      value: viewModel,
      child: _AddJobSheet(), // ← pass it in
      ), 
  );
}

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChecklistViewModel>();

    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [

        viewModel.queue.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.checklist, size: 48, color: Colors.grey[700]),
                    SizedBox(height: 12),
                    Text(
                      'No jobs in queue',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap + to add a job',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              )
            : Column(
                children: [

                  // header
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${viewModel.queue.length} jobs in queue',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.drag_indicator,
                              color: Color(0xFF6B7280),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'drag to reorder',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // draggable list
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: viewModel.queue.length,
                      onReorder: (oldIndex, newIndex) {
                        context
                            .read<ChecklistViewModel>()
                            .reorderQueue(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final job = viewModel.queue[index];
                        return _buildJobCard(job, index, key: ValueKey(job.id));
                      },
                    ),
                  ),

                ],
              ),

        // floating add button
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            backgroundColor: Color(0xFFF59E0B),
            foregroundColor: Colors.black,
            onPressed: () => _showAddJobSheet(context),
            child: Icon(Icons.add),
          ),
        ),

      ],
    );
  }

  Widget _buildJobCard(Job job, int index, {required Key key}) {
    return Card(
      key: key,
      color: Color(0xFF12151C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [

            // position number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: index == 0
                    ? Color(0xFFF59E0B).withValues(alpha: 0.15)
                    : Color(0xFF1E2128),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: index == 0
                        ? Color(0xFFF59E0B)
                        : Color(0xFF6B7280),
                  ),
                ),
              ),
            ),

            SizedBox(width: 12),

            // job info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.customerName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    job.vehicle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    job.jobType,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (job.notes.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      job.notes,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 8),

            // drag handle
            Icon(
              Icons.drag_handle,
              color: Color(0xFF4B5563),
              size: 20,
            ),

          ],
        ),
      ),
    );
  }
}

// ── ADD JOB BOTTOM SHEET ─────────────────────────────────────────────────────

class _AddJobSheet extends StatefulWidget {
  const _AddJobSheet();

  @override
  _AddJobSheetState createState() => _AddJobSheetState();
}

class _AddJobSheetState extends State<_AddJobSheet> {
  final _customerController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _customerController.dispose();
    _vehicleController.dispose();
    _jobTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
  if (_customerController.text.trim().isEmpty ||
      _vehicleController.text.trim().isEmpty ||
      _jobTypeController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill in customer, vehicle and job type'),
        backgroundColor: Color(0xFFEF4444),
      ),
    );
    return;
  }

  setState(() => _isSaving = true);

  await context.read<ChecklistViewModel>().addJob( // ← use widget.viewModel instead of context.read
    customerName: _customerController.text.trim(),
    vehicle: _vehicleController.text.trim(),
    jobType: _jobTypeController.text.trim(),
    notes: _notesController.text.trim(),
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
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // sheet handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFF2A2D35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              'New Job',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 20),

            _buildField('Customer Name', _customerController, 'e.g. John Dietrich'),
            SizedBox(height: 14),
            _buildField('Vehicle', _vehicleController, 'e.g. 2019 Ford F-150'),
            SizedBox(height: 14),
            _buildField('Job Type', _jobTypeController, 'e.g. Full Brake Service'),
            SizedBox(height: 14),
            _buildField('Notes', _notesController, 'Any special instructions...', maxLines: 3),

            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'Add to Queue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 12),

          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFF4B5563), fontSize: 13),
            filled: true,
            fillColor: Color(0xFF1E2128),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF2A2D35)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF2A2D35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFF59E0B)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}