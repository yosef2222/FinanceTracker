using System.Security.Claims;
using FinHelper.Services.AIAdvice;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinHelper.Controllers;

[Authorize]
[ApiController]
[Route("api/ai")]
public class AIAdviceController : BaseController
{
    private readonly IAIAdviceService _adviceService;
    private readonly ILogger<AIAdviceController> _logger;

    public AIAdviceController(
        IAIAdviceService adviceService,
        ILogger<AIAdviceController> logger)
    {
        _adviceService = adviceService;
        _logger = logger;
    }

    [HttpGet("advice")]
    public async Task<IActionResult> GetFinancialAdvice()
    {
        try
        {
            // Add cache key (user ID + date to regenerate weekly)
            var cacheKey = $"{UserId}-{DateTime.UtcNow:yyyy-MM}";
            
            var advice = await _adviceService.GenerateFinancialAdviceAsync(UserId);
            
            // Log successful generation
            _logger.LogInformation($"Generated AI advice for user {UserId}");
            
            return Ok(new { Advice = advice });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating AI advice");
            return StatusCode(500, new { 
                Error = "Ошибка при генерации финансового совета",
                Details = ex.Message 
            });
        }
    }
}