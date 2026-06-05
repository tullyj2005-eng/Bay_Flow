import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bay_flow/ViewModels/home_page_viewmodel.dart';
import 'package:bay_flow/Models/bay.dart';
import 'package:bay_flow/Views/checklist_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // 0 = floor, 1 = checklist, 2 = staff
  int _selectedIndex = 0;

  Widget _getBody(HomePageViewModel viewModel) {
    switch (_selectedIndex) {
      case 0:
        return _buildFloorView(viewModel);
      case 1:
        return ChecklistView();
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
        title: Text('BayFlow'),
        actions: [

          // floor icon
          IconButton(
            icon: Icon(
              Icons.garage,
              color: _selectedIndex == 0
                  ? Color(0xFFF59E0B)
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
                  ? Color(0xFFF59E0B)
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
                  ? Color(0xFFF59E0B)
                  : Colors.grey,
            ),
            tooltip: 'Staff',
            onPressed: () => setState(() => _selectedIndex = 2),
          ),

        ],
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : _getBody(viewModel),
    );
  }

  // ── FLOOR VIEW ──────────────────────────────────────
  Widget _buildFloorView(HomePageViewModel viewModel) {
    if (viewModel.bays.isEmpty) {
      return Center(
        child: Text('No bays found', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: viewModel.bays.length,
      itemBuilder: (context, index) {
        return _buildBayCard(viewModel.bays[index]);
      },
    );
  }

  // ── STAFF VIEW ───────────────────────────────────────
  Widget _buildStaffView() {
    return Center(
      child: Text(
        'Staff — Coming Soon',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  // ── BAY CARD ─────────────────────────────────────────
  Widget _buildBayCard(Bay bay) {
    return Card(
      color: Color(0xFF12151C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bay.bayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                _buildStatusBadge(bay.status),
              ],
            ),

            SizedBox(height: 6),

            Text(
              bay.type,
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),

            SizedBox(height: 8),

            Wrap(
              spacing: 6,
              children: bay.equipment.map((eq) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E2128),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Color(0xFF2A2D35)),
                  ),
                  child: Text(
                    eq,
                    style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 12),

            bay.status == 'available'
                ? Center(
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
                        backgroundColor: Color(0xFF1E2128),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Mark Done ✓'),
                    ),
                  ),

          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'in_progress'
        ? Color(0xFFF59E0B)
        : status == 'done'
            ? Color(0xFF6366F1)
            : Color(0xFF10B981);

    String label = status == 'in_progress'
        ? 'In Progress'
        : status == 'done'
            ? 'Complete'
            : 'Available';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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