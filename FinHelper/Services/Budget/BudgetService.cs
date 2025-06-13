using FinHelper.Data;
using FinHelper.Models.Category;
using FinHelper.Models.Transaction;
using Microsoft.EntityFrameworkCore;

namespace FinHelper.Models.Budget;

public class BudgetService : IBudgetService
{
    private readonly ApplicationDbContext _context;
    private readonly ITransactionService _transactionService;

    public BudgetService(
        ApplicationDbContext context,
        ITransactionService transactionService)
    {
        _context = context;
        _transactionService = transactionService;
    }

    public async Task<BudgetResponseDto> CreateBudget(Guid userId, BudgetDto dto)
    {
        if (dto.StartDate >= dto.EndDate) throw new Exception("Invalid date range");
        
        var category = await _context.Categories.FindAsync(dto.CategoryId);
        if (category == null) throw new Exception("Invalid category");

        var existingBudget = await _context.Budgets
            .AnyAsync(b => b.UserId == userId && 
                          b.CategoryId == dto.CategoryId &&
                          b.StartDate <= dto.EndDate && 
                          b.EndDate >= dto.StartDate);
        
        if (existingBudget) throw new Exception("Budget already exists for this period");

        var budget = new Budget
        {
            Amount = dto.Amount,
            StartDate = dto.StartDate,
            EndDate = dto.EndDate,
            CategoryId = dto.CategoryId,
            UserId = userId
        };

        _context.Budgets.Add(budget);
        await _context.SaveChangesAsync();

        return await MapToResponseDto(budget);
    }

    public async Task<BudgetResponseDto> UpdateBudget(Guid userId, BudgetDto dto)
    {
        if (!dto.Id.HasValue) throw new Exception("Budget ID required");
        
        var budget = await _context.Budgets
            .FirstOrDefaultAsync(b => b.Id == dto.Id.Value && b.UserId == userId);
            
        if (budget == null) throw new Exception("Budget not found");
        
        if (dto.StartDate >= dto.EndDate) throw new Exception("Invalid date range");
        
        budget.Amount = dto.Amount;
        budget.StartDate = dto.StartDate;
        budget.EndDate = dto.EndDate;
        budget.CategoryId = dto.CategoryId;

        await _context.SaveChangesAsync();
        return await MapToResponseDto(budget);
    }

    public async Task DeleteBudget(Guid userId, Guid budgetId)
    {
        var budget = await _context.Budgets
            .FirstOrDefaultAsync(b => b.Id == budgetId && b.UserId == userId);
            
        if (budget == null) throw new Exception("Budget not found");
        
        _context.Budgets.Remove(budget);
        await _context.SaveChangesAsync();
    }

    public async Task<IEnumerable<BudgetResponseDto>> GetBudgets(Guid userId)
    {
        var budgets = await _context.Budgets
            .Include(b => b.Category)
            .Where(b => b.UserId == userId)
            .ToListAsync();

        var result = new List<BudgetResponseDto>();
        foreach (var budget in budgets)
        {
            result.Add(await MapToResponseDto(budget));
        }
        return result;
    }
    
    public async Task<BudgetResponseDto> GetBudget(Guid userId, Guid budgetId)
    {
        var budget = await _context.Budgets
            .Include(b => b.Category)
            .FirstOrDefaultAsync(b => b.Id == budgetId && b.UserId == userId);
    
        if (budget == null) throw new Exception("Budget not found");
    
        return await MapToResponseDto(budget);
    }

    private async Task<BudgetResponseDto> MapToResponseDto(Budget budget)
    {
        var transactions = await _transactionService.GetTransactions(
            budget.UserId, 
            budget.StartDate, 
            budget.EndDate);
    
        var categorySpending = transactions
            .Where(t => t.Category.Id == budget.CategoryId)
            .Sum(t => t.Amount);

        return new BudgetResponseDto
        {
            Id = budget.Id,
            Amount = budget.Amount,
            StartDate = budget.StartDate,
            EndDate = budget.EndDate,
            Category = new CategoryDto
            {
                Id = budget.Category.Id,
                Name = budget.Category.Name,
                Color = budget.Category.Color,
                Icon = budget.Category.Icon
            },
            CurrentSpending = categorySpending
        };
    }
}