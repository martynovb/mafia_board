import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class RequestClubMembershipUseCase extends BaseUseCase<Future<bool>, String> {
  final ClubsRepo clubsRepo;
  final AuthRepo authRepo;

  RequestClubMembershipUseCase({
    required this.clubsRepo,
    required this.authRepo,
  });

  @override
  Future<bool> execute({String? params}) async {
    final currentUser = await authRepo.me();
    return clubsRepo.sendRequestToJoinClub(
      clubId: params!,
      currentUserId: currentUser.id ?? '',
    );
  }
}
