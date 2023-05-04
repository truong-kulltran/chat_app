import 'package:chat_app/widgets/app_image.dart';
import 'package:flutter/material.dart';

import '../../../network/model/user_info_model.dart';

class ContactTab extends StatefulWidget {
  final List<UserInfoModel>? listUser;

  const ContactTab({Key? key, this.listUser}) : super(key: key);

  @override
  State<ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<ContactTab> {
  final _searchController = TextEditingController();

  bool _showSearchResult = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _searchBox(context),
        Expanded(
          child: _showSearchResult ? _searchResult() : Container(),
        ),
      ],
    );
  }

  Widget _listView() {
    return ListView.builder(
      itemCount: widget.listUser?.length,
      itemBuilder: (context, index) => _createItemUser(widget.listUser?[index]),
    );
  }

  Widget _createItemUser(UserInfoModel? item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 70,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: AppImage(
                          isOnline: true,
                          localPathOrUrl: item?.fileUrl,
                          boxFit: BoxFit.cover,
                          errorWidget: Image.asset(
                            'assets/images/ic_account_circle.png',
                            color: Colors.grey.withOpacity(0.6),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Icon(
                            Icons.message_outlined,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Icon(
                            Icons.call,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: SizedBox(
        height: 40,
        child: TextField(
          onTap: () {
            setState(() {
              _showSearchResult = !_showSearchResult;
            });
          },
          controller: _searchController,
          onSubmitted: (_) {
            if (_searchController.text.isEmpty) {
              setState(() {
                _showSearchResult = false;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Search',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                width: 1,
                color: Theme.of(context).primaryColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(
                width: 1,
                color: Color.fromARGB(128, 130, 130, 130),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchResult() {
    return Container(color: Colors.blue);
  }
}