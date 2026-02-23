import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/data/controller/withdraw/withdraw_history_controller.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/screens/withdraw/withdraw_log/widget/withdraw_history_card.dart';

class WithdrawListItem extends StatefulWidget {

  final WithdrawHistoryController controller;

  const WithdrawListItem({Key? key, required this.controller}) : super(key: key);

  @override
  State<WithdrawListItem> createState() => _WithdrawListItemState();
}

class _WithdrawListItemState extends State<WithdrawListItem> {

  final ScrollController _controller = ScrollController();

  fetchData() {
    Get.find<WithdrawHistoryController>().fetchNewList();
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      if(widget.controller.hasNext()){
        fetchData();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addListener(_scrollListener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
            itemCount: widget.controller.historyList.length+1,
            shrinkWrap: true,
            controller: _controller,
            itemBuilder: (builder, index) {
              if (index == widget.controller.historyList.length) {
                return widget.controller.hasNext()
                    ? const CustomLoader(isPagination: true,)
                    : const SizedBox();
              }
              return GestureDetector(
                onTap: (){},
                child: WithdrawHistoryCard(index,controller: widget.controller),
              );
            }),

    );
  }
}




