using FinHelper.Models.User;

namespace FinHelper.Models.Dashboard;

public class DashboardResponseDto
{
    public decimal TotalSpent { get; set; }
    public decimal TotalBudget { get; set; }
    public List<CategorySpendingDto> CategorySpendings { get; set; }
    public List<LoanSummaryDto> LoanSummaries { get; set; }
    public decimal Cushion { get; set; }
    public decimal Salary { get; set; }
    public string FinancialGoal { get; set; }
    public decimal FinancialGoalAmount { get; set; }
    public decimal FinancialGoalProgress { get; set; }
    public int FinancialGoalMonths { get; set; }
}