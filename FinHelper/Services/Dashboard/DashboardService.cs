using FinHelper.Data;
using FinHelper.Models.Budget;
using FinHelper.Models.Dashboard;
using FinHelper.Models.Transaction;

namespace FinHelper.Services.Dashboard;

public class DashboardService : IDashboardService
{
    private readonly ApplicationDbContext _context;
    private readonly ITransactionService _transactionService;
    private readonly IBudgetService _budgetService;

    public DashboardService(
        ApplicationDbContext context,
        ITransactionService transactionService,
        IBudgetService budgetService)
    {
        _context = context;
        _transactionService = transactionService;
        _budgetService = budgetService;
    }

    public async Task<DashboardResponseDto> GetDashboard(Guid userId)
    {
        var now = DateTime.UtcNow;
        var startOfMonth = new DateTime(now.Year, now.Month, 1);
        var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);

        // Get current month transactions
        var transactions = (await _transactionService.GetTransactions(userId, startOfMonth, endOfMonth))
            .ToList();

        // Get current budgets
        var budgets = (await _budgetService.GetBudgets(userId))
            .Where(b => b.StartDate <= endOfMonth && b.EndDate >= startOfMonth)
            .ToList();

        // Calculate category spendings
        var categorySpendings = new List<CategorySpendingDto>();
        foreach (var budget in budgets)
        {
            var spent = transactions
                .Where(t => t.Category.Id == budget.Category.Id)
                .Sum(t => t.Amount);
            
            categorySpendings.Add(new CategorySpendingDto
            {
                Category = budget.Category,
                Spent = spent,
                Budget = budget.Amount
            });
        }

        return new DashboardResponseDto
        {
            TotalSpent = transactions.Sum(t => t.Amount),
            TotalBudget = budgets.Sum(b => b.Amount),
            CategorySpendings = categorySpendings
        };
    }
}