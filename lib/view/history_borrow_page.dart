import 'package:flutter/material.dart';
import 'package:media_management_track/model/history.dart';
import 'package:media_management_track/viewmodel/history_viewmodel.dart';
import 'package:provider/provider.dart';

class HistoryBorrowPage extends StatefulWidget {
  const HistoryBorrowPage({super.key});

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm = Provider.of<HistoryViewmodel>(context, listen: false);
  }

  Future<Map<String, String>> getNames(String userId, String schoolId) async {
  final userName = await vm.getUserName(userId);
  final schoolName = await vm.getSchoolName(schoolId);
  return {
    'user': userName,
    'school': schoolName,
  };
}


  Widget buildHistoryItem(History history) {
  return FutureBuilder<Map<String, String>>(
    future: getNames(history.userId, history.schoolId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final names = snapshot.data!;
      final userName = names['user']!;
      final schoolName = names['school']!;

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
              Text("Jam Pinjam: ${history.borrowAt}"),
              Text("Jam Kembali: ${history.returnAt ?? "-"}"),
            ],
          ),
        ),
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
          title: const Text("Riwayat Peminjaman"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: "Dipinjam"), Tab(text: "Dikembalikan")],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            FutureBuilder<List<History>>(
              future: vm.getBorrowList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data Peminjaman'),
                  );
                } else {
                  final borrowList = snapshot.data!;

                  return ListView.builder(
                    itemCount: borrowList.length,
                    itemBuilder: (context, index) {
                      final item = borrowList[index];
                      return buildHistoryItem(item);
                    },
                  );
                }
              },
            ),

            FutureBuilder<List<History>>(
              future: vm.getReturnList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data pengembalian'),
                  );
                } else {
                  final returnList = snapshot.data!;

                  return ListView.builder(
                    itemCount: returnList.length,
                    itemBuilder: (context, index) {
                      final item = returnList[index];
                      return buildHistoryItem(item);
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
