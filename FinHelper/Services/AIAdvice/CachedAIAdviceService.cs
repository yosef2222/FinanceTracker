using Microsoft.Extensions.Caching.Memory;

namespace FinHelper.Services.AIAdvice;

public class CachedAIAdviceService : IAIAdviceService
{
    private readonly IAIAdviceService _innerService;
    private readonly IMemoryCache _cache;

    public CachedAIAdviceService(
        IAIAdviceService innerService,  // Changed to IAIAdviceService
        IMemoryCache cache)
    {
        _innerService = innerService;
        _cache = cache;
    }

    public async Task<string?> GenerateFinancialAdviceAsync(Guid userId)
    {
        var cacheKey = $"ai-advice-{userId}-{DateTime.UtcNow:yyyy-MM}";
        
        return await _cache.GetOrCreateAsync(cacheKey, async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromDays(7);
            return await _innerService.GenerateFinancialAdviceAsync(userId);
        });
    }
}