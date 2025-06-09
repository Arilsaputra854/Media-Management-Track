import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_management_track/viewmodel/borrow_request_viewmodel.dart';

class BorrowRequestPage extends StatefulWidget {
  const BorrowRequestPage({super.key});

  @override
  State<BorrowRequestPage> createState() => _BorrowRequestPageState();
}

class _BorrowRequestPageState extends State<BorrowRequestPage> {
  late BorrowRequestViewmodel vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm = Provider.of<BorrowRequestViewmodel>(context, listen: false);
    vm.fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BorrowRequestViewmodel>(
      builder: (context, vm, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Permintaan Peminjaman'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Menunggu'),
                  Tab(text: 'Diterima'),
                  Tab(text: 'Ditolak'),
                ],
              ),
            ),
            body:
                vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      children: [
                        _buildRequestList(vm, 'requested'),
                        _buildRequestList(vm, 'approved'),
                        _buildRequestList(vm, 'declined'),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _buildRequestList(BorrowRequestViewmodel vm, String status) {
    final filteredRequests =
        vm.requests.where((req) => req.status == status).toList();

    if (filteredRequests.isEmpty) {
      return const Center(child: Text("Tidak ada data."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final req = filteredRequests[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            title: Text(req.mediaName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID Media: ${req.mediaId}"),
                FutureBuilder<String>(
                  future: vm.getUserNameById(req.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Memuat nama...");
                    }
                    if (snapshot.hasError) {
                      return const Text("Gagal ambil nama");
                    }
                    return Text("Nama: ${snapshot.data}");
                  },
                ),

                FutureBuilder<String>(
                  future: vm.getSchoolNameById(req.schoolId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Memuat sekolah...");
                    }
                    if (snapshot.hasError) {
                      return const Text("Gagal ambil sekolah");
                    }
                    return Text("Sekolah: ${snapshot.data}");
                  },
                ),
                Text("Status: ${req.status}"),
                Text("Tanggal: ${_formatDateTime(req.requestAt)}"),
                Text(
                  "Tanggal disetujui : ${req.acceptAt != null ? _formatDateTime(req.acceptAt!) : '-'}",
                ),
              ],
            ),
            trailing:
                status == 'requested'
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            vm.approveRequest(req);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            vm.declineRequest(req);
                          },
                        ),
                      ],
                    )
                    : null,
          ),
        );
      },
    );
  }

  String? _formatDateTime(DateTime? dt) {
    if (dt != null) {
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
  }
}
