namespace FinHelper.Models.Dashboard;

public class DashboardResponseDto
{
    public decimal TotalSpent { get; set; }
    public decimal TotalBudget { get; set; }
    public IEnumerable<CategorySpendingDto> CategorySpendings { get; set; }
}