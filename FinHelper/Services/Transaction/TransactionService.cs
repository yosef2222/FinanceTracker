using FinHelper.Data;
using FinHelper.Models.Category;
using Microsoft.EntityFrameworkCore;

namespace FinHelper.Models.Transaction;

public class TransactionService : ITransactionService
{
    private readonly ApplicationDbContext _context;

    public TransactionService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<TransactionResponseDto> CreateTransaction(Guid userId, TransactionDto dto)
    {
        var category = await _context.Categories.FindAsync(dto.CategoryId);
        if (category == null) throw new Exception("Invalid category");

        var transaction = new Transaction
        {
            Amount = dto.Amount,
            Date = dto.Date,
            Merchant = dto.Merchant,
            Description = dto.Description,
            CategoryId = dto.CategoryId,
            UserId = userId
        };

        _context.Transactions.Add(transaction);
        await _context.SaveChangesAsync();

        return MapToResponseDto(transaction, category);
    }

    
    public async Task<TransactionResponseDto> UpdateTransaction(Guid userId, TransactionDto dto)
    {
        if (!dto.Id.HasValue) throw new Exception("Transaction ID required");

        var transaction = await _context.Transactions
            .Include(t => t.Category)
            .FirstOrDefaultAsync(t => t.Id == dto.Id.Value && t.UserId == userId);

        if (transaction == null) throw new Exception("Transaction not found");

        transaction.Amount = dto.Amount;
        transaction.Date = dto.Date;
        transaction.Merchant = dto.Merchant;
        transaction.Description = dto.Description;
        
        if (transaction.CategoryId != dto.CategoryId)
        {
            var category = await _context.Categories.FindAsync(dto.CategoryId);
            if (category == null) throw new Exception("Invalid category");
            transaction.CategoryId = dto.CategoryId;
            transaction.Category = category;
        }

        await _context.SaveChangesAsync();
        return MapToResponseDto(transaction, transaction.Category);
    }

    public async Task DeleteTransaction(Guid userId, Guid transactionId)
    {
        var transaction = await _context.Transactions
            .FirstOrDefaultAsync(t => t.Id == transactionId && t.UserId == userId);

        if (transaction == null) throw new Exception("Transaction not found");

        _context.Transactions.Remove(transaction);
        await _context.SaveChangesAsync();
    }

    public async Task<IEnumerable<TransactionResponseDto>> GetTransactions(
        Guid userId, 
        DateTime? startDate, 
        DateTime? endDate)
    {
        var query = _context.Transactions
            .Include(t => t.Category)
            .Where(t => t.UserId == userId);

        if (startDate.HasValue) query = query.Where(t => t.Date >= startDate.Value);
        if (endDate.HasValue) query = query.Where(t => t.Date <= endDate.Value);

        var transactions = await query.OrderByDescending(t => t.Date).ToListAsync();
        return transactions.Select(t => MapToResponseDto(t, t.Category));
    }
    
    public async Task<TransactionResponseDto> GetTransaction(Guid userId, Guid transactionId)
    {
        var transaction = await _context.Transactions
            .Include(t => t.Category)
            .FirstOrDefaultAsync(t => t.Id == transactionId && t.UserId == userId);
    
        if (transaction == null) return null;
    
        return MapToResponseDto(transaction, transaction.Category);
    }

    private TransactionResponseDto MapToResponseDto(Transaction transaction, Category.Category category)
    {
        return new TransactionResponseDto
        {
            Id = transaction.Id,
            Amount = transaction.Amount,
            Date = transaction.Date,
            Merchant = transaction.Merchant,
            Description = transaction.Description,
            Category = new CategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                Color = category.Color,
                Icon = category.Icon
            }
        };
    }
}