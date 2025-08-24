abstract class SocialStates {}

class SocialInitialState extends SocialStates {}


class SocialGetUserSuccessState extends SocialStates {}

class SocialGetUserLoadingState extends SocialStates {}

class SocialGetUserErrorState extends SocialStates {
  final String error;

  SocialGetUserErrorState(this.error);
}

class SocialGetAllUsersSuccessState extends SocialStates {}

class SocialGetAllUsersLoadingState extends SocialStates {}

class SocialGetAllUsersErrorState extends SocialStates {
  final String error;

  SocialGetAllUsersErrorState(this.error);
}

class SocialChangeBottomNavState extends SocialStates {}
class SocialNewPostState extends SocialStates {}



class SocialChangeModeState extends SocialStates {}

class SocialUpdateUserSuccessState extends SocialStates {}
class SocialUpdateUserLoadingState extends SocialStates {}
class SocialUpdateUserErrorState extends SocialStates {
  final String error;

  SocialUpdateUserErrorState(this.error);
}
class SocialProfileImagePickedSuccessState extends SocialStates {}
class SocialProfileImagePickedErrorState extends SocialStates {}
class SocialCoverImagePickedSuccessState extends SocialStates {}
class SocialCoverImagePickedErrorState extends SocialStates {}

class SocialUploadProfileImageLoadingState extends SocialStates {}

class SocialUploadProfileImageSuccessState extends SocialStates {
  final String imageUrl;
  SocialUploadProfileImageSuccessState(this.imageUrl);
}

class SocialUploadProfileImageErrorState extends SocialStates {
  final String error;
  SocialUploadProfileImageErrorState(this.error);
}
class SocialUploadCoverImageLoadingState extends SocialStates {}

class SocialUploadCoverImageSuccessState extends SocialStates {
  final String imageUrl;
  SocialUploadCoverImageSuccessState(this.imageUrl);
}

class SocialUploadCoverImageErrorState extends SocialStates {
  final String error;
  SocialUploadCoverImageErrorState(this.error);
}
class SocialCreatePostSuccessState extends SocialStates {}
class SocialCreatePostLoadingState extends SocialStates {}
class SocialCreatePostErrorState extends SocialStates {
  final String error;
  SocialCreatePostErrorState(this.error);
}
class SocialPostImagePickedSuccessState extends SocialStates {}
class SocialPostImagePickedLoadingState extends SocialStates {}
class SocialPostImagePickedErrorState extends SocialStates {
  final String error;
  SocialPostImagePickedErrorState(this.error);
}


class SocialRemovePostImagePickedState extends SocialStates {}
class SocialUploadPostImageLoadingState extends SocialStates {}

class SocialUploadPostImageSuccessState extends SocialStates {
  final String imageUrl;
  SocialUploadPostImageSuccessState(this.imageUrl);
}

class SocialUploadPostImageErrorState extends SocialStates {
  final String error;
  SocialUploadPostImageErrorState(this.error);
}

class SocialGetPostSuccessState extends SocialStates {}

class SocialGetPostLoadingState extends SocialStates {}

class SocialGetPostErrorState extends SocialStates {
  final String error;

  SocialGetPostErrorState(this.error);
}

class SocialLikePostSuccessState extends SocialStates {}

class SocialLikePostLoadingState extends SocialStates {}

class SocialLikePostErrorState extends SocialStates {
  final String error;

  SocialLikePostErrorState(this.error);
}

class SocialUnlikePostSuccessState extends SocialStates {}

class SocialUnlikePostLoadingState extends SocialStates {}

class SocialUnlikePostErrorState extends SocialStates {
  final String error;

  SocialUnlikePostErrorState(this.error);
}

class SocialAddCommentPostSuccessState extends SocialStates {}

class SocialAddCommentPostLoadingState extends SocialStates {}

class SocialAddCommentPostErrorState extends SocialStates {
  final String error;

  SocialAddCommentPostErrorState(this.error);
}
class SocialRemoveCommentPostSuccessState extends SocialStates {}

class SocialRemoveCommentPostLoadingState extends SocialStates {}

class SocialRemoveCommentPostErrorState extends SocialStates {
  final String error;

  SocialRemoveCommentPostErrorState(this.error);
}
class SocialSendMessegeSuccessState extends SocialStates {}

class SocialSendMessegeErrorState extends SocialStates {
  final String error;

  SocialSendMessegeErrorState(this.error);
}

class SocialGetMessegeSuccessState extends SocialStates {}

class SocialGetMessegeErrorState extends SocialStates {
  final String error;

  SocialGetMessegeErrorState(this.error);
}
class SocialGetCommentsPostSuccessState extends SocialStates {}

class SocialGetCommentsPostErrorState extends SocialStates {
  final String error;

  SocialGetCommentsPostErrorState(this.error);
}
class SocialDeletePostSuccessState extends SocialStates {}

class SocialDeletePostErrorState extends SocialStates {
  final String error;

  SocialDeletePostErrorState(this.error);
}
class SocialEditPostSuccessState extends SocialStates {}

class SocialEditPostErrorState extends SocialStates {
  final String error;

  SocialEditPostErrorState(this.error);
}
class SocialEditPostLoadingState extends SocialStates {}


class SocialLogoutSuccessState extends SocialStates {}

class SocialLogoutErrorState extends SocialStates {
  final String error;

  SocialLogoutErrorState(this.error);
}
class SocialArchivePostSuccessState extends SocialStates {}

class SocialArchivePostErrorState extends SocialStates {
  final String error;

  SocialArchivePostErrorState(this.error);
}
class SocialArchivePostLoadingState extends SocialStates {}

class SocialUnarchivePostSuccessState extends SocialStates {}

class SocialUnarchivePostErrorState extends SocialStates {
  final String error;

  SocialUnarchivePostErrorState(this.error);
}
class SocialAddTagsSuccessState extends SocialStates {}
class SocialSendEmailVerificationSuccessState extends SocialStates {}

class SocialAddTagsErrorState extends SocialStates {
  final String error;

  SocialAddTagsErrorState(this.error);
}
class SocialSendEmailVerificationErrorState extends SocialStates {
  final String error;

  SocialSendEmailVerificationErrorState(this.error);
}

// In your SocialStates file
class SocialLoadingState extends SocialStates {}

class SocialRefreshUserErrorState extends SocialStates {
  final String error;
  SocialRefreshUserErrorState(this.error);
}
class SocialRefreshUserSuccessState extends SocialStates {

}
class SocialEmailVerificationStatusSuccessState extends SocialStates {}
class SocialEmailVerificationStatusErrorState extends SocialStates {
  final String error;
  SocialEmailVerificationStatusErrorState(this.error);
}


class SocialSendEmailVerificationLoadingState extends SocialStates {}
class SocialSendImageMessageLoadingState extends SocialStates {}
class SocialSendImageMessageSuccessState extends SocialStates {
}
class SocialSendImageMessageErrorState extends SocialStates {
  final String error;
  SocialSendImageMessageErrorState(this.error);
}

class SocialGetImageMessageLoadingState extends SocialStates {}
class SocialGetImageMessageSuccessState extends SocialStates {}
class SocialGetImageMessageErrorState extends SocialStates {
  final String error;
  SocialGetImageMessageErrorState(this.error);
}
class SocialPickMessageImageSuccessState extends SocialStates {}
class SocialPickMessageImageErrorState extends SocialStates {}
class SocialClearMessageImageState extends SocialStates {}
class SocialClearMessageInputState extends SocialStates {}
class SocialSendMessageLoadingState extends SocialStates {}
class SocialGetMessegeLoadingState extends SocialStates {}


class SocialNavigationRequiredState extends SocialStates {
  final String userId;

  SocialNavigationRequiredState(this.userId);
}
class SocialPhotosUpdatedState extends SocialStates {}
