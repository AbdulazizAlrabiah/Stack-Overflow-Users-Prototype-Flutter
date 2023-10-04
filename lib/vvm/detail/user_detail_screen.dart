import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/networking_generic_response.dart';
import 'package:stack_overflow_users_prototype_flutter/shared_utilities/alertHelper.dart';
import 'package:stack_overflow_users_prototype_flutter/vvm/detail/user_detail_view_model.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key, required this.userId, required this.name});
  final int userId;
  final String name;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final viewModel = context.read<UserDetailViewModel>();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      viewModel.getUserDetailsWithLoader(userId: widget.userId);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        viewModel.getUserDetailsFromPaging(userId: widget.userId);
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
    return Consumer<UserDetailViewModel>(
      builder: (ctx, viewModel, child) {
        if ((viewModel.userDetailResponse?.status == Status.error)) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            AlertHelper.shared.showAlert(
                context,
                "Error",
                viewModel.userDetailResponse?.message ??
                    "General error please try again");
          });
          return Scaffold(
            body: UsersDetailsList(
              viewModel: viewModel,
              scrollController: _scrollController,
            ),
          );
        } else if (viewModel.userDetailResponse?.status == Status.loading) {
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
              title: Text(widget.name),
            ),
            body: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: (() async {
                      await viewModel.getUserDetailsWithLoader(
                          userId: widget.userId);
                    }),
                    child: UsersDetailsList(
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

class UsersDetailsList extends StatelessWidget {
  const UsersDetailsList({
    Key? key,
    required UserDetailViewModel viewModel,
    required ScrollController scrollController,
  })  : _viewModel = viewModel,
        _scrollController = scrollController,
        super(key: key);

  final UserDetailViewModel _viewModel;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(4),
      controller: _scrollController,
      itemCount: _viewModel.userDetails.length,
      itemBuilder: ((context, index) {
        final userDetail = _viewModel.userDetails[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: AutoSizeText(
                          "Reputation type: '${userDetail.reputationType}'",
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
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 8, end: 8, bottom: 8),
                        child: AutoSizeText(
                          "Date: ${userDetail.creationDate.year} - ${userDetail.creationDate.month} - ${userDetail.creationDate.day}",
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
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Column(
                children: [
                  AutoSizeText(
                    "Reputation change: ${userDetail.reputationChange}",
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
                      Flexible(
                        child: AutoSizeText(
                          "Post ID: ${userDetail.postId}",
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
        );
      }),
    );
  }
}
