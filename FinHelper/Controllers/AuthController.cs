using System.Security.Claims;
using FinHelper.Models;
using FinHelper.Models.User;
using FinHelper.Services.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;


namespace FinHelper.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : BaseController
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [AllowAnonymous]
    [HttpPost("register")]
    public async Task<IActionResult> Register(UserDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState); 
        }

        try
        {
            var token = await _authService.Register(request);
            return Ok(new { Token = token });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto loginDto)
    {
        try
        {
            var token = await _authService.Login(loginDto);
            return Ok(new { Token = token });
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(ex.Message);
        }
    }

    [Authorize]
    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        try
        {
            var userId = GetUserIdFromClaims();
            var profile = await _authService.GetProfile(userId);
            return Ok(profile);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(ex.Message);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ex.Message);
        }
    }

    [Authorize]
    [HttpPut("profile")]
    public async Task<IActionResult> EditProfile(EditProfileDto request)
    {
        try
        {
            var userId = GetUserIdFromClaims();
            var profile = await _authService.EditProfile(userId, request);
            return Ok(profile);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(ex.Message);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ex.Message);
        }
    }

    private Guid GetUserIdFromClaims()
    {
        var claimValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
    
        if (string.IsNullOrEmpty(claimValue))
        {
            throw new UnauthorizedAccessException("User identifier claim is missing");
        }
    
        if (Guid.TryParse(claimValue, out Guid userId))
        {
            return userId;
        }
    
        // Log the invalid value for debugging
        Console.WriteLine($"Invalid GUID format: '{claimValue}'");
        throw new FormatException($"Invalid GUID format: '{claimValue}'");
    }
}