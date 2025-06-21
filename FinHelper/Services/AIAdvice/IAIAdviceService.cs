namespace FinHelper.Services.AIAdvice;

public interface IAIAdviceService
{
    Task<string?> GenerateFinancialAdviceAsync(Guid userId);
}