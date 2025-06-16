import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/borrow_request.dart';
import 'package:media_management_track/model/history.dart';
import 'package:media_management_track/view/widget/loading_widget.dart';
import 'package:media_management_track/viewmodel/history_viewmodel.dart';
import 'package:provider/provider.dart';

class HistoryBorrowPage extends StatefulWidget {
  final String userRole;
  const HistoryBorrowPage({super.key, required this.userRole});

  @override
  State<HistoryBorrowPage> createState() => _HistoryBorrowPageState();
}

class _HistoryBorrowPageState extends State<HistoryBorrowPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late HistoryViewmodel vm;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/login');
    }

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm = Provider.of<HistoryViewmodel>(context, listen: false);
  }

  Future<Map<String, String>> getNames(String userId, String schoolId) async {
    final userName = await vm.getUserName(userId);
    final schoolName = await vm.getSchoolName(schoolId);
    return {'user': userName, 'school': schoolName};
  }

  Widget buildHistoryItem(
    History history,
    String userRole,
    HistoryViewmodel viewModel,
  ) {
    return FutureBuilder<Map<String, String>>(
      future: getNames(history.userId, history.schoolId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final names = snapshot.data!;
        final userName = names['user']!;
        final schoolName = names['school']!;

        return FutureBuilder<String>(
          future: viewModel.getMediaName(history.mediaId),
          builder: (context, mediaSnapshot) {
            if (!mediaSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final mediaName = mediaSnapshot.data!;
            final borrowAt = history.borrowAt.toString();
            final returnAt = history.returnAt?.toString() ?? "-";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sekolah: $schoolName"),
                    Text("Nama Set: $mediaName"),
                    Text("Jumlah pcs: ${history.pcs}"),
                    Text("Jam Pinjam: $borrowAt"),
                    Text("Jam Kembali: $returnAt"),
                  ],
                ),
                trailing:
                    (userRole == 'trainer' && history.status == 'borrow')
                        ? ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            bool success = await viewModel.returnItem(
                              history.id,
                            );

                            Navigator.of(context).pop(); // Tutup loading dialog

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Item berhasil dikembalikan'
                                      : 'Gagal mengembalikan item: ${viewModel.errorMsg}',
                                ),
                              ),
                            );
                          },
                          child: const Text('Kembalikan'),
                        )
                        : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget buildRequestBorrowItem(
  BorrowRequest history,
  String userRole,
  HistoryViewmodel viewModel,
) {
  return FutureBuilder<Map<String, String>>(
    future: getNames(history.userId, history.schoolId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final names = snapshot.data!;
      final userName = names['user']!;
      final schoolName = names['school']!;
      final accAt = history.acceptAt != null
          ? history.acceptAt!.toLocal().toString()
          : "-";

      return FutureBuilder<String>(
        future: viewModel.getMediaName(history.mediaId),
        builder: (context, mediaSnapshot) {
          if (!mediaSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mediaName = mediaSnapshot.data!;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sekolah: $schoolName"),
                  Text("Jam diminta: ${history.requestAt.toLocal()}"),
                  Text("Jumlah pcs: ${history.pcs}"),
                  Text("Nama Set: $mediaName"),
                  Text("Di-ACC pada: $accAt"),
                ],
              ),
              trailing: (userRole == 'trainer' && history.status == 'borrow')
                  ? ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        bool success = await viewModel.returnItem(history.id);

                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Item berhasil dikembalikan'
                                  : 'Gagal mengembalikan item: ${viewModel.errorMsg}',
                            ),
                          ),
                        );
                      },
                      child: const Text('Kembalikan'),
                    )
                  : null,
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Diminta"),
              Tab(text: "Dipinjam"),
              Tab(text: "Dikembalikan"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            StreamBuilder<List<BorrowRequest>>(
              stream: vm.streamRequestedList(
                id: FirebaseAuth.instance.currentUser?.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingWidget("Memuat data permintaan");
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Tidak ada data permintaan.');
                }

                final requestedList = snapshot.data!;
                return ListView.builder(
                  itemCount: requestedList.length,
                  itemBuilder: (context, index) {
                    final item = requestedList[index];
                    return buildRequestBorrowItem(item, widget.userRole, vm);
                  },
                );
              },
            ),
            StreamBuilder<List<History>>(
              stream: vm.streamBorrowList(
                id: FirebaseAuth.instance.currentUser?.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingWidget("Memuat data peminjaman");
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Tidak ada data peminjaman.');
                }

                final borrowList = snapshot.data!;
                return ListView.builder(
                  itemCount: borrowList.length,
                  itemBuilder: (context, index) {
                    final item = borrowList[index];
                    return buildHistoryItem(item, widget.userRole, vm);
                  },
                );
              },
            ),
            StreamBuilder<List<History>>(
              stream: vm.streamReturnList(
                id: FirebaseAuth.instance.currentUser?.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingWidget("Memuat data pengembalian");
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Tidak ada data pengembalian.');
                }

                final returnList = snapshot.data!;
                return ListView.builder(
                  itemCount: returnList.length,
                  itemBuilder: (context, index) {
                    final item = returnList[index];
                    return buildHistoryItem(item, widget.userRole, vm);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
