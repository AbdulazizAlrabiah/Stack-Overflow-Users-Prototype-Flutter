import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/networking_generic_response.dart';
import 'package:stack_overflow_users_prototype_flutter/route_name.dart';
import 'package:stack_overflow_users_prototype_flutter/shared_utilities/alertHelper.dart';
import 'package:stack_overflow_users_prototype_flutter/vvm/home/users_view_model.dart';
import 'package:auto_size_text/auto_size_text.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final viewModel = context.read<UsersViewModel>();

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        viewModel.getUsersFromPaging();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersViewModel>(
      builder: (ctx, viewModel, child) {
        if ((viewModel.usersResponse?.status == Status.error)) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            AlertHelper.shared.showAlert(
                context,
                "Error",
                viewModel.usersResponse?.message ??
                    "General error please try again");
          });
          return Scaffold(
            body: UsersList(
              viewModel: viewModel,
              scrollController: _scrollController,
            ),
          );
        } else if (viewModel.usersResponse?.status == Status.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.grey,
              title: const Text("SOF Users"),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await viewModel.toggleBookmarkedUsersMode();
              },
              backgroundColor: Colors.lightBlue,
              child: Icon(
                viewModel.isBookmarkMode
                    ? Icons.bookmark_border
                    : Icons.bookmark,
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: (() async {
                      await viewModel.getUsersWithLoader();
                    }),
                    child: UsersList(
                      viewModel: viewModel,
                      scrollController: _scrollController,
                    ),
                  ),
                ),
                if (viewModel.isLoadingPaignation)
                  Transform.scale(
                    scale: 0.5,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}

class UsersList extends StatelessWidget {
  const UsersList({
    Key? key,
    required UsersViewModel viewModel,
    required ScrollController scrollController,
  })  : _viewModel = viewModel,
        _scrollController = scrollController,
        super(key: key);

  final UsersViewModel _viewModel;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(4),
      controller: _scrollController,
      itemCount: _viewModel.users.length,
      itemBuilder: ((context, index) {
        final user = _viewModel.users[index];
        return GestureDetector(
          onTap: (() {
            Navigator.of(context).pushNamed(
              RouteName.detailRouteName,
              arguments: user.userId,
            );
          }),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22.5),
                        child: Image.network(
                          user.profileImageURL,
                          fit: BoxFit.fill,
                          width: 45,
                          height: 45,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (frame != null) {
                              return child;
                            }

                            return Container(
                              width: 45,
                              height: 45,
                              color: Colors.grey,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 45,
                              height: 45,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 6),
                          child: AutoSizeText(
                            user.name,
                            minFontSize: 9,
                            stepGranularity: 0.5,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        AutoSizeText(
                          "Join date: ${user.creationDate.year} - ${user.creationDate.month} - ${user.creationDate.day}",
                          minFontSize: 8,
                          stepGranularity: 0.5,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: 4,
                        start: 4,
                        end: 6,
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        child: IconButton(
                          onPressed: () {
                            _viewModel.toggleBookMarkUser(user);
                          },
                          icon: Icon(
                            user.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            size: 16,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Column(
                  children: [
                    AutoSizeText(
                      "Reputation: ${user.reputation}",
                      minFontSize: 8,
                      stepGranularity: 0.5,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 4,
                            left: 4,
                          ),
                          child: Icon(
                            Icons.location_pin,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Flexible(
                          child: AutoSizeText(
                            user.location,
                            minFontSize: 7,
                            stepGranularity: 0.5,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
