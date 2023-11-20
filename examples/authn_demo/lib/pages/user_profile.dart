import 'package:flutter/material.dart';
import 'package:pangea_sdk/src/types.dart';

class UserProfile extends StatelessWidget {
  final Session? userData;

  const UserProfile({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
          child: Text(
            'This is a sample user profile page so you have successfully logged in. See the details of your session below',
            maxLines: 4,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
        ),
        Table(
          border: TableBorder.all(color: Colors.green, width: .5),
          columnWidths: const {
            0: FlexColumnWidth(6),
            1: FlexColumnWidth(18),
          },
          children: [
            TableRow(children: [
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: const Text('User Id'),
              ),
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: Text(userData?.currentUser.id),
              ),
            ]),
            TableRow(children: [
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: const Text('Email'),
              ),
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: Text(userData?.currentUser.email),
              ),
            ]),
            TableRow(children: [
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: const Text('Name'),
              ),
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: Text(
                    '${userData?.currentUser.firstName} ${userData?.currentUser.lastName}'),
              ),
            ]),
            TableRow(children: [
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: const Text('Last Login'),
              ),
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: Text('${userData?.currentUser.lastLoginTime}'),
              ),
            ]),
            TableRow(children: [
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: const Text('Refresh Token Exp'),
              ),
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: Text('${userData?.refreshToken.expire}'),
              ),
            ]),
            TableRow(children: [
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: const Text('User Token Exp'),
              ),
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                child: Text('${userData?.userToken.expire}'),
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
