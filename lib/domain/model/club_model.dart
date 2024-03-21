import 'package:mafia_board/data/entity/club_entity.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  List<ClubMemberModel> members;
  List<ClubMemberModel> admins;
  bool isAdmin;
  List<GameModel> games = [];
  double civilWinRate;
  double mafWinRate;
  DateTime createdAt;

  ClubModel({
    required this.id,
    required this.title,
    required this.description,
    required this.members,
    required this.admins,
    required this.isAdmin,
    required this.games,
    required this.civilWinRate,
    required this.mafWinRate,
    required this.createdAt,
  });

  ClubModel.empty()
      : id = '',
        title = '',
        description = '',
        civilWinRate = 0.0,
        mafWinRate = 0.0,
        createdAt = DateTime.fromMillisecondsSinceEpoch(0),
        isAdmin = false,
        members = [],
        admins = [];

  ClubModel.fromEntity(ClubEntity entity)
      : id = entity.id ?? '',
        title = entity.title ?? '',
        description = entity.description ?? '',
        civilWinRate = entity.civilWinRate ?? 0.0,
        mafWinRate = entity.mafWinRate ?? 0.0,
        createdAt = entity.createdAt != null
            ? DateTime.fromMillisecondsSinceEpoch(entity.createdAt!)
            : DateTime.fromMillisecondsSinceEpoch(0),
        isAdmin = entity.isAdmin ?? false,
        members = [],
        admins = [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'members': members.map((member) => member.toMap()).toList(),
        'admins': admins.map((admin) => admin.toMap()).toList(),
        'isAdmin': isAdmin,
        'games': games.map((game) => game.toMap()).toList(),
        'civilWinRate': civilWinRate,
        'mafWinRate': mafWinRate,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  static ClubModel fromMap(Map<String, dynamic> map) {
    return ClubModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      members: ClubMemberModel.fromListMap(map['members']),
      admins: ClubMemberModel.fromListMap(map['admins']),
      isAdmin: map['isAdmin'] ?? false,
      games: GameModel.fromListMap(map['games']),
      civilWinRate: map['civilWinRate'] ?? 0.0,
      mafWinRate: map['mafWinRate'] ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}
