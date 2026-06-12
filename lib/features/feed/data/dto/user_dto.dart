import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed // Generates the immutable class boilerplate
class UserDto with _$UserDto {
  const factory UserDto({
    required String username,
    @JsonKey(name: 'profile_image') // Renames the JSON key
    required String profileImage,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
