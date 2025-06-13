using FinHelper.Models.Category;

namespace FinHelper.Models.Budget;

public class BudgetResponseDto
{
    public Guid Id { get; set; }
    public decimal Amount { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public CategoryDto Category { get; set; }
    public decimal CurrentSpending { get; set; }
}