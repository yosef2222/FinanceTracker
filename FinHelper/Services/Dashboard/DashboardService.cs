using FinHelper.Data;
using FinHelper.Models.Budget;
using FinHelper.Models.Dashboard;
using FinHelper.Models.Transaction;
using FinHelper.Models.User;
using Microsoft.EntityFrameworkCore;

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

        // Get user with loans
        var user = await _context.Users
            .Include(u => u.Loans)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
            throw new Exception("User not found");

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

        // Calculate loan summaries
        var loanSummaries = new List<LoanSummaryDto>();
        foreach (var loan in user.Loans)
        {
            // Calculate remaining months
            var monthsPassed = (now - loan.StartDate).Days / 30;
            var remainingMonths = loan.TermInMonths - monthsPassed;
            
            loanSummaries.Add(new LoanSummaryDto
            {
                Name = loan.Name,
                TotalAmount = loan.TotalAmount,
                PaidAmount = loan.PaidAmount,
                RemainingAmount = loan.TotalAmount - loan.PaidAmount,
                RemainingMonths = remainingMonths > 0 ? remainingMonths : 0,
                MonthlyPayment = loan.MonthlyPayment
            });
        }

        return new DashboardResponseDto
        {
            TotalSpent = transactions.Sum(t => t.Amount),
            TotalBudget = budgets.Sum(b => b.Amount),
            CategorySpendings = categorySpendings,
            LoanSummaries = loanSummaries,
            FinancialGoal = user.FinancialGoal,
            FinancialGoalAmount = user.FinancialGoalAmount,
            FinancialGoalProgress = user.FinancialGoalMonths > 0 ? 
                (decimal)monthsPassed / user.FinancialGoalMonths * 100 : 0,
            Cushion = user.Cushion,
            Salary = user.Salary
        };
    }
}