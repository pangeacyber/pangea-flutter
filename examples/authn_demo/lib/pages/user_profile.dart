import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:pangea_sdk/src/types.dart';
import '../utils/colors.dart';

class UserProfile extends StatelessWidget {
  final Session? userData;

  const UserProfile({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Text(
            'Welcome ${userData?.currentUser.firstName} ${userData?.currentUser.lastName}',
            maxLines: 4,
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(24),
          child: Image(image: AssetImage("lib/images/manidae-logo-white.png"), width: 100,)
        ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(color: Color.fromARGB(150, 0, 0, 0), borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Table(
                border: TableBorder.all(color: Colors.blue, width: .5),
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
              )
            )
          )
        ),
      ],
    );
  }
}
