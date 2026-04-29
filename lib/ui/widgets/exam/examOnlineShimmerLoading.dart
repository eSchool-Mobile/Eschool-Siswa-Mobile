import 'package:eschool/ui/widgets/system/shimmerLoaders/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/system/shimmerLoaders/shimmerLoadingContainer.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';

/// Renders a single shimmer placeholder card for the exam list loading state.
class ExamOnlineShimmerItem extends StatelessWidget {
  const ExamOnlineShimmerItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        horizontal: Utils.screenContentHorizontalPaddingInPercentage *
            MediaQuery.of(context).size.width,
      ),
      child: ShimmerLoadingContainer(
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 9,
                    width: boxConstraints.maxWidth * 0.3,
                  ),
                ),
                SizedBox(height: boxConstraints.maxWidth * 0.02),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 10,
                    width: boxConstraints.maxWidth * 0.8,
                  ),
                ),
                SizedBox(height: boxConstraints.maxWidth * 0.1),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Renders a full loading state column of [ExamOnlineShimmerItem] placeholders.
class ExamOnlineShimmerLoading extends StatelessWidget {
  const ExamOnlineShimmerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              Utils.defaultShimmerLoadingContentCount,
              (_) => const ExamOnlineShimmerItem(),
            ),
          ),
        ),
      ),
    );
  }
}
