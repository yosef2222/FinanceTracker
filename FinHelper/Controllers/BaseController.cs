using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinHelper.Controllers;

[Authorize]
[ApiController]
public class BaseController : ControllerBase
{
    protected Guid UserId
    {
        get
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
            
            throw new FormatException($"Invalid GUID format: '{claimValue}'");
        }
    }
    
    protected string UserEmail => User.FindFirstValue(ClaimTypes.Email) 
                                  ?? throw new UnauthorizedAccessException("Email claim is missing");
}