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

    // Calculate category spendings by grouping transactions
    var categorySpendings = new List<CategorySpendingDto>();
    
    // Group transactions by category
    var spendingByCategory = transactions
        .GroupBy(t => t.Category.Id)
        .Select(g => new {
            CategoryId = g.Key,
            Spent = g.Sum(t => t.Amount),
            Category = g.First().Category // All transactions in group have same category
        })
        .ToList();
    
    // Create spending DTOs for each category group
    foreach (var spending in spendingByCategory)
    {
        // Find budget for this category if it exists
        var budget = budgets.FirstOrDefault(b => b.Category.Id == spending.CategoryId);
        
        categorySpendings.Add(new CategorySpendingDto
        {
            Category = spending.Category,
            Spent = spending.Spent,
            Budget = budget?.Amount ?? 0
        });
    }
    
    // Add categories that have budgets but no transactions
    var budgetedCategories = budgets.Select(b => b.Category.Id).ToList();
    var spentCategories = spendingByCategory.Select(s => s.CategoryId).ToList();
    var missingCategories = budgetedCategories.Except(spentCategories).ToList();
    
    foreach (var categoryId in missingCategories)
    {
        var budget = budgets.First(b => b.Category.Id == categoryId);
        var category = budget.Category;
        
        categorySpendings.Add(new CategorySpendingDto
        {
            Category = category,
            Spent = 0,
            Budget = budget.Amount
        });
    }


        // Calculate loan summaries for active loans
        var loanSummaries = new List<LoanSummaryDto>();
        foreach (var loan in user.Loans.Where(l => l.IsActive))
        {
            // Calculate months passed and remaining
            var monthsPassed = (int)Math.Floor((now - loan.StartDate).TotalDays / 30.436875); // Average days per month
            var remainingMonths = loan.TermMonths - monthsPassed;
            
            // Calculate total paid (assuming monthly payments are consistent)
            var totalPaid = monthsPassed * loan.MonthlyPayment;
            
            // Calculate remaining amount
            var remainingAmount = loan.Amount - totalPaid;
            
            loanSummaries.Add(new LoanSummaryDto
            {
                LoanId = loan.Id,
                LoanType = loan.Type,
                TotalAmount = loan.Amount,
                PaidAmount = totalPaid,
                RemainingAmount = remainingAmount > 0 ? remainingAmount : 0,
                RemainingMonths = remainingMonths > 0 ? remainingMonths : 0,
                MonthlyPayment = loan.MonthlyPayment,
                InterestRate = loan.InterestRate
            });
        }

        // Calculate financial goal progress
        decimal goalProgress = 0;
        if (user.FinancialGoalAmount > 0)
        {
            goalProgress = (user.Cushion / user.FinancialGoalAmount) * 100;
            if (goalProgress > 100) goalProgress = 100;
        }

        return new DashboardResponseDto
        {
            TotalSpent = transactions.Sum(t => t.Amount),
            TotalBudget = budgets.Sum(b => b.Amount),
            CategorySpendings = categorySpendings,
            LoanSummaries = loanSummaries,
            Cushion = user.Cushion,
            Salary = user.Salary,
            FinancialGoal = user.FinancialGoal,
            FinancialGoalAmount = user.FinancialGoalAmount,
            FinancialGoalProgress = goalProgress,
            FinancialGoalMonths = user.FinancialGoalMonths
        };
    }
}