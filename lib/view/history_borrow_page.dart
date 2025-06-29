import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/borrow_request.dart';
import 'package:media_management_track/model/history.dart';
import 'package:media_management_track/model/user.dart';
import 'package:media_management_track/storage/prefs.dart';
import 'package:media_management_track/view/widget/loading_widget.dart';
import 'package:media_management_track/viewmodel/history_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryBorrowPage extends StatefulWidget {
  final String userRole;
  const HistoryBorrowPage({super.key, required this.userRole});

  @override
  State<HistoryBorrowPage> createState() => _HistoryBorrowPageState();
}

class _HistoryBorrowPageState extends State<HistoryBorrowPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _tabLength;

  late Prefs _prefs;
  User? _currentUser;

  late HistoryViewmodel vm;

  @override
  void initState() {
    super.initState();
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/login');
    }

    _tabLength = widget.userRole == 'admin' ? 2 : 3;
    _tabController = TabController(length: _tabLength, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm = Provider.of<HistoryViewmodel>(context, listen: false);

    SharedPreferences.getInstance().then((sp) {
      _prefs = Prefs(sp);
      User? user = _prefs.getUser();
      setState(() {
        _currentUser = user;
      });
    });
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
        final accAt =
            history.acceptAt != null
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
                trailing:
                    (userRole == 'trainer' && history.status == 'requested')
                        ? ElevatedButton(
                          onPressed: () async {
                            bool success = await viewModel.cancelRequest(
                              history.id,
                            );
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Permintaan berhasil dibatalkan'
                                      : 'Gagal membatalkan permintaan: ${viewModel.errorMsg}',
                                ),
                              ),
                            );
                          },
                          child: const Text('Batal'),
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

    if (_currentUser == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
  
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs:
                widget.userRole == 'admin'
                    ? const [Tab(text: "Dipinjam"), Tab(text: "Dikembalikan")]
                    : const [
                      Tab(text: "Diminta"),
                      Tab(text: "Dipinjam"),
                      Tab(text: "Dikembalikan"),
                    ],
          ),
        ),
        body: Column(
          children: [
            const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        "UNTUK MENGEMBALIKAN SET HARAP BERIKAN KE ADMIN UNTUK DI SCAN BARCODE YANG ADA PADA MEDIA.",
        textAlign: TextAlign.center,
      ),
    ),
            Expanded(child: TabBarView(
              controller: _tabController,
              children:
                  widget.userRole == 'admin'
                      ? [
                        StreamBuilder<List<History>>(
                          stream: vm.streamBorrowList(
                            id: auth.FirebaseAuth.instance.currentUser?.uid,
                            userRole: _currentUser!.role,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingWidget("Memuat data peminjaman");
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Text('Tidak ada data peminjaman.'),
                              );
                            }

                            final borrowList = snapshot.data!;
                            return ListView.builder(
                              itemCount: borrowList.length,
                              itemBuilder: (context, index) {
                                final item = borrowList[index];
                                return buildHistoryItem(
                                  item,
                                  widget.userRole,
                                  vm,
                                );
                              },
                            );
                          },
                        ),
                        StreamBuilder<List<History>>(
                          stream: vm.streamReturnList(
                            id: auth.FirebaseAuth.instance.currentUser?.uid,
                            userRole: _currentUser!.role,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingWidget("Memuat data pengembalian");
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Text('Tidak ada data pengembalian.'),
                              );
                            }

                            final returnList = snapshot.data!;
                            return ListView.builder(
                              itemCount: returnList.length,
                              itemBuilder: (context, index) {
                                final item = returnList[index];
                                return buildHistoryItem(
                                  item,
                                  widget.userRole,
                                  vm,
                                );
                              },
                            );
                          },
                        ),
                      ]
                      : [
                        StreamBuilder<List<BorrowRequest>>(
                          stream: vm.streamRequestedList(
                            id: auth.FirebaseAuth.instance.currentUser?.uid,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingWidget("Memuat data permintaan");
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Text('Tidak ada data permintaan.'),
                              );
                            }

                            final requestedList = snapshot.data!;
                            return ListView.builder(
                              itemCount: requestedList.length,
                              itemBuilder: (context, index) {
                                final item = requestedList[index];
                                return buildRequestBorrowItem(
                                  item,
                                  widget.userRole,
                                  vm,
                                );
                              },
                            );
                          },
                        ),
                        StreamBuilder<List<History>>(
                          stream: vm.streamBorrowList(
                            id: auth.FirebaseAuth.instance.currentUser?.uid,
                            userRole: _currentUser!.role,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingWidget("Memuat data peminjaman");
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Text('Tidak ada data peminjaman.'),
                              );
                            }

                            final borrowList = snapshot.data!;
                            return ListView.builder(
                              itemCount: borrowList.length,
                              itemBuilder: (context, index) {
                                final item = borrowList[index];
                                return buildHistoryItem(
                                  item,
                                  widget.userRole,
                                  vm,
                                );
                              },
                            );
                          },
                        ),
                        StreamBuilder<List<History>>(
                          stream: vm.streamReturnList(
                            id: auth.FirebaseAuth.instance.currentUser?.uid,
                            userRole: _currentUser!.role,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingWidget("Memuat data pengembalian");
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Text('Tidak ada data pengembalian.'),
                              );
                            }

                            final returnList = snapshot.data!;
                            return ListView.builder(
                              itemCount: returnList.length,
                              itemBuilder: (context, index) {
                                final item = returnList[index];
                                return buildHistoryItem(
                                  item,
                                  widget.userRole,
                                  vm,
                                );
                              },
                            );
                          },
                        ),
                      ],
            ),)
          ],
        ),
      ),
    );
  }
}
