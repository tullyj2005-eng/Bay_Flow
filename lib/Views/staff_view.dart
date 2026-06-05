import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bay_flow/ViewModels/staff_viewmodel.dart';
import 'package:bay_flow/Models/staff.dart';

class StaffView extends StatelessWidget {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StaffViewModel(),
      child: const _StaffContent(),
    );
  }
}

class _StaffContent extends StatelessWidget {
  const _StaffContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StaffViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.staffList.isEmpty) {
      return const Center(
        child: Text(
          'No staff found',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.staffList.length,
      itemBuilder: (context, index) {
        return _buildStaffCard(viewModel.staffList[index]);
      },
    );
  }

  Widget _buildStaffCard(Staff staff) {
    final bool isAvailable = staff.status == 'available';
    final Color statusColor = isAvailable
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    final String statusLabel = isAvailable ? 'Available' : 'Busy';

    return Card(
      color: const Color(0xFF12151C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            // avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2128),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  // initials
                  staff.name.isNotEmpty
                      ? staff.name
                          .split(' ')
                          .map((e) => e[0])
                          .take(2)
                          .join()
                          .toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // name + role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    staff.role == 'owner' ? 'Owner' : 'Technician',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),

            // status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
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