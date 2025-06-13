using FinHelper.Models;
using FinHelper.Models.User;

namespace FinHelper.Services.Auth;

public interface IAuthService
{
    Task<string> Register(UserDto request);
    Task<string> Login(LoginDto loginDto);
    Task<UserProfileDto> GetProfile(Guid userId);
    Task<UserProfileDto> EditProfile(Guid userId, EditProfileDto request);
}