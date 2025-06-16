import 'package:flutter/material.dart';
import 'package:media_management_track/model/borrow_request.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<BorrowRequestViewmodel>(context, listen: false).fetchRequests();
  });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BorrowRequestViewmodel>(
      builder: (context, vm, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Menunggu'),
                  Tab(text: 'Diterima'),
                  Tab(text: 'Ditolak'),
                ],
              ),
            ),
            body: vm.isLoading
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
    return StreamBuilder<List<BorrowRequest>>(
      stream: vm.requestStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Terjadi kesalahan."));
        }

        final filteredRequests =
            snapshot.data!.where((req) => req.status == status).toList();

        if (filteredRequests.isEmpty) {
          return const Center(child: Text("Tidak ada data."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            final req = filteredRequests[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Nama", vm.getUserNameById(req.userId)),
                    _buildInfoRow("Media", vm.getMediaNameById(req.mediaId)),
                    const SizedBox(height: 4),
                    Text("Jumlah pcs: ${req.pcs}"),
                    _buildInfoRow("Sekolah", vm.getSchoolNameById(req.schoolId)),
                    const SizedBox(height: 4),
                    Text("Status: ${req.status}", style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text("Tanggal permintaan: ${_formatDateTime(req.requestAt)}"),
                    Text("Tanggal disetujui: ${req.acceptAt != null ? _formatDateTime(req.acceptAt!) : '-'}"),
                    const SizedBox(height: 12),
                    if (status == 'requested')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text("Setujui"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => vm.approveRequest(req, context),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text("Tolak"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => vm.declineRequest(req, context),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Widget untuk menampilkan baris informasi dengan FutureBuilder
  Widget _buildInfoRow(String label, Future<String> future) {
    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        String text = "Memuat...";
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          text = snapshot.data!;
        } else if (snapshot.hasError) {
          text = "Gagal mengambil data";
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: RichText(
            text: TextSpan(
              text: "$label: ",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: text,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _formatDateTime(DateTime? dt) {
    if (dt != null) {
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return null;
  }
}
