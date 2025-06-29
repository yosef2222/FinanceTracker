namespace FinHelper.Models.Transaction;

public class TransactionParseResult
{
    public decimal Amount { get; set; }
    public string Merchant { get; set; }
    public string Description { get; set; }
    public Guid CategoryId { get; set; }
    public DateTime Date { get; set; } = DateTime.UtcNow;
    public bool IsFallback { get; set; } = false;
}