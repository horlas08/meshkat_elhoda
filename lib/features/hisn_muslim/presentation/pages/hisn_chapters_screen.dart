
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import '../../presentation/bloc/hisn_muslim_bloc.dart';
import 'hisn_dhikr_screen.dart';

class HisnChaptersScreen extends StatelessWidget {
  const HisnChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HisnMuslimBloc>()..add(LoadHisnChapters()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hisn al-Muslim'),
        ),
        body: BlocBuilder<HisnMuslimBloc, HisnMuslimState>(
          builder: (context, state) {
            if (state is HisnMuslimLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HisnMuslimError) {
              return Center(child: Text(state.message));
            } else if (state is HisnMuslimLoaded) {
              return ListView.separated(
                itemCount: state.chapters.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final chapter = state.chapters[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${chapter.id}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HisnDhikrScreen(chapter: chapter),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
