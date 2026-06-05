import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bay_flow/ViewModels/home_page_viewmodel.dart';
import 'package:bay_flow/Models/bay.dart';
import 'package:bay_flow/Views/checklist_view.dart';

// HomePage now just wraps the content in its own Provider
// so HomePageViewModel initializes AFTER the user is logged in
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

  // 0 = floor, 1 = checklist, 2 = staff
  int _selectedIndex = 0;

  Widget _getBody(HomePageViewModel viewModel) {
    switch (_selectedIndex) {
      case 0:
        return _buildFloorView(viewModel);
      case 1:
        return const ChecklistView();
      case 2:
        return _buildStaffView();
      default:
        return _buildFloorView(viewModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BayFlow'),
        actions: [

          // floor icon
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

          // checklist icon
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

          // staff icon
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

  // ── FLOOR VIEW ──────────────────────────────────────
  Widget _buildFloorView(HomePageViewModel viewModel) {
    if (viewModel.bays.isEmpty) {
      return const Center(
        child: Text('No bays found', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.bays.length,
      itemBuilder: (context, index) {
        return _buildBayCard(viewModel.bays[index]);
      },
    );
  }

  // ── STAFF VIEW ───────────────────────────────────────
  Widget _buildStaffView() {
    return const Center(
      child: Text(
        'Staff — Coming Soon',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  // ── BAY CARD ─────────────────────────────────────────
  Widget _buildBayCard(Bay bay) {
    return Card(
      color: const Color(0xFF12151C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 6,
              children: bay.equipment.map((eq) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2128),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF2A2D35)),
                  ),
                  child: Text(
                    eq,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            bay.status == 'available'
                ? const Center(
                    child: Text(
                      'Bay Available — Assign a Job',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2128),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Mark Done ✓'),
                    ),
                  ),

          ],
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