import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetClubDetailsUseCase extends BaseUseCase<ClubModel, ClubModel> {
  final AuthRepo authRepo;
  final ClubsRepo clubsRepo;

  GetClubDetailsUseCase({
    required this.authRepo,
    required this.clubsRepo,
  });

  @override
  Future<ClubModel> execute({ClubModel? params}) async {
    if(params == null){
      throw InvalidDataError('Club does not exist');
    }
    final members = <ClubMemberModel>[];
    return params..members = members;
  }
}
