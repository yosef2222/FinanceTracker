using FinHelper.Models.Category;

namespace FinHelper.Models.Transaction;

public class TransactionResponseDto
{
    public Guid Id { get; set; }
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
    public string Merchant { get; set; }
    public string Description { get; set; }
    public CategoryDto Category { get; set; }
}