using FinHelper.Data;
using FinHelper.Models;
using FinHelper.Models.User;
using Microsoft.EntityFrameworkCore;

namespace FinHelper.Services.Auth;

public class AuthService : IAuthService
{
    private readonly ApplicationDbContext _context;
    private readonly JwtService _jwtService;

    public AuthService(ApplicationDbContext context, JwtService jwtService)
    {
        _context = context;
        _jwtService = jwtService;
    }

    public async Task<string> Register(UserDto request)
    {
        if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            throw new InvalidOperationException("User already exists.");
        
        var user = new User
        {
            Email = request.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            FullName = request.FullName,
            Birthday = request.Birthday
        };
        
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        
        return _jwtService.GenerateToken(user);
    }

    public async Task<string> Login(LoginDto loginDto)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == loginDto.Email);
        
        if (user == null || !BCrypt.Net.BCrypt.Verify(loginDto.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");
        
        return _jwtService.GenerateToken(user);
    }

    public async Task<UserProfileDto> GetProfile(Guid userId)
    {
        var user = await _context.Users.SingleOrDefaultAsync(u => u.Id == userId);
        
        if (user == null)
            throw new KeyNotFoundException("User not found.");
        
        return new UserProfileDto
        {
            FullName = user.FullName,
            Email = user.Email,
            BirthDate = user.Birthday,
        };
    }

    public async Task<UserProfileDto> EditProfile(Guid userId, EditProfileDto request)
    {
        var user = await _context.Users.SingleOrDefaultAsync(u => u.Id == userId);
        
        if (user == null)
            throw new KeyNotFoundException("User not found.");
        
        user.FullName = request.FullName;
        user.Birthday = request.BirthDate;
        
        _context.Users.Update(user);
        await _context.SaveChangesAsync();
        
        return new UserProfileDto
        {
            FullName = user.FullName,
            Email = user.Email,
            BirthDate = user.Birthday,
        };
    }
}