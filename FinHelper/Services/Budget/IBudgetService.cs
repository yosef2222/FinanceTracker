namespace FinHelper.Models.Budget;

public interface IBudgetService
{
    Task<BudgetResponseDto> CreateBudget(Guid userId, BudgetDto budgetDto);
    Task<BudgetResponseDto> UpdateBudget(Guid userId, BudgetDto budgetDto);
    Task DeleteBudget(Guid userId, Guid budgetId);
    Task<IEnumerable<BudgetResponseDto>> GetBudgets(Guid userId);
    Task<BudgetResponseDto> GetBudget(Guid userId, Guid budgetId);
}