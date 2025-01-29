import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/navigation_bar.dart';
import '../viewmodels/home_viewmodel.dart';
import 'widgets/party_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadParties();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<HomeViewModel>().loadParties();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return RefreshIndicator(
            onRefresh: () => viewModel.loadParties(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.parties.length + (viewModel.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == viewModel.parties.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final party = viewModel.parties[index];
                return PartyCard(party: party);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 모임 개설 페이지로 이동
        },
        backgroundColor: const Color(0xFF4B3FD8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
