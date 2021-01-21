class CustomResponse {
  static Map<String, Exception> exceptions = {
    'SYSTEM_ERROR': SystemErrorException(),
    'SIGN_IN_FAILED': SignInFailedException(),
    'SID_NOT_FOUND': SessionIdNotFoundException(),
    'API_METHOD_NOT_FOUND': ApiMethodNotFoundException(),
    'ENTITY_NOT_FOUND': EntityNotFoundException(),
    'UPDATE_NOT_APPLICABLE': UpdateNotApplicableException(),
    'UNKNOWN_FILTER': UnknownFilterException(),
    'FILE_IS_EMPTY': FileIsEmptyException(),
    //'FILE_TOO_LARGE': FileTooLargeException(),
    'FILE_CHUNK_SIZE_OUT_OF_RANGE': FileChunkSizeOutOfRangeException(),
    'FILE_CHUNK_OUT_OF_ORDER': FileChunkOutOfOrderException(),
    'FILE_FORMAT_UNKNOWN': FileFormatUnknownException(),
    'FILE_FORMAT_ERROR': FileFormatErrorException(),
    'FILE_HASH_SUM_ERROR': FileHashSumErrorException(),
    'FILE_HASH_VAL_ERROR': FileHashValErrorException(),
    'FILE_UPLOAD_ID_UNKNOWN': FileUploadIdUnknownException(),
    'FILE_UNKNOWN_USE_TYPE': FileUnknownUseTypeException(),
    'FILE_ACCESS_RESTRICTED': FileAccessRestrictedException(),
    'USER_NICKNAME_NOT_VALID': UserNicknameNotValidException(),
    'USER_NICKNAME_NOT_UNIQUE': UserNicknameNotUniqueException(),
    'USER_BIRTHDATE_OUT_OF_RANGE': UserBirthdayOutOfRangeException(),
    'USER_PRIMARY_ID_NOT_VALID': UserPrimaryIdNotValidException(),
    'USER_PRIMARY_ID_NOT_UNIQUE': UserPrimaryIdNotUniqueException(),
    'USER_SECRET_NOT_VALID': UserSecretNotValidException(),
    'USER_UNSUPPORTED_AUTH_TYPE': UserUnsupportedAuthTypeException(),
    'USER_LICENSE_AGREEMENT_NOT_ACCEPTED':
        UserLicenseAgreementNotAcceptedException(),
    'USER_AUTH_INACTIVE': UserAuthInactiveException(),
    'APPLICATION_NOT_UNIQUE': ChallengeApplicationNotUniqueException(),
    'CHALLENGE_NOT_APPLICABLE': ChallengeNotApplicableException(),
    'NOT_ENOUGH_BALANCE_AMOUNT': NotEnoughBalanceAmountException(),
    'APPLICATION_ALREADY_APPROVED': ApplicationAlreadyApproved(),
    'AUTH_CODE_TEMPORARY_BLOCKED': AuthCodeTemporaryBlocked(),
    'FILE_TOO_LARGE': MaxSizeException(),
  };
  static List<String> success = ['OK', 'FILE_UPLOAD_DONE'];
}

class SystemErrorException implements Exception {
  final message = 'Системная ошибка';
}

class SignInFailedException implements Exception {
  final message = 'Ошибка авторизации';
}

class SessionIdNotFoundException implements Exception {
  final message = '';
}

class ApiMethodNotFoundException implements Exception {
  final message = '';
}

class EntityNotFoundException implements Exception {
  final message = 'Запись не найдена';
}

class UpdateNotApplicableException implements Exception {
  final message = '';
}

class UnknownFilterException implements Exception {
  final message = 'Неизвестный фильтр';
}

class FileIsEmptyException implements Exception {
  final message = 'Файл пуст';
}

class FileTooLargeException implements Exception {
  final message = 'Файл слишком большой';
}

class FileChunkSizeOutOfRangeException implements Exception {
  final message = '';
}

class FileChunkOutOfOrderException implements Exception {
  final message = '';
}

class FileFormatUnknownException implements Exception {
  final message = 'Файл неизвестного формата';
}

class FileFormatErrorException implements Exception {
  final message = 'Ошибка в формате файла';
}

class FileHashSumErrorException implements Exception {
  final message = '';
}

class FileHashValErrorException implements Exception {
  final message = '';
}

class FileUploadIdUnknownException implements Exception {
  final message = '';
}

class FileUnknownUseTypeException implements Exception {
  final message = 'Неизвестный тип использования файла';
}

class FileAccessRestrictedException implements Exception {
  final message = 'Доступ к файлу запрещен';
}

class UserNicknameNotValidException implements Exception {
  final message = 'Невалидный никнейм';
}

class UserNicknameNotUniqueException implements Exception {
  final message = 'Никнейм не уникальный';
}

class UserBirthdayOutOfRangeException implements Exception {
  final message = 'Дата рождения не удовлетворяет требованиям';
}

class UserPrimaryIdNotValidException implements Exception {
  final message = '';
}

class UserPrimaryIdNotUniqueException implements Exception {
  final message = '';
}

class UserSecretNotValidException implements Exception {
  final message = '';
}

class UserUnsupportedAuthTypeException implements Exception {
  final message = '';
}

class UserLicenseAgreementNotAcceptedException implements Exception {
  final message = '';
}

class UserAuthInactiveException implements Exception {
  final message = '';
}

class ChallengeApplicationNotUniqueException implements Exception {
  final message = 'Заявка на челлендж уже существует';
}

class ChallengeNotApplicableException implements Exception {
  final message = 'Невозможно добавить заявку к челленжду';
}

class MaxSizeException implements Exception {}

class AuthCodeTemporaryBlocked implements Exception {}

class ApplicationAlreadyApproved implements Exception {}

class NotEnoughBalanceAmountException implements Exception {}

class CancelException implements Exception {}

class UnknownException implements Exception {
  final message = 'Неизвестная ошибка';
}
