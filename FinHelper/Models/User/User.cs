namespace FinHelper.Models.User;

public class User
{
    public Guid Id { get; set; }
    public string FullName { get; set; }
    public DateTime Birthday { get; set; }
    public string Email { get; set; }
    public string PasswordHash { get; set; }
    public List<Transaction.Transaction> Transactions { get; set; } = new();
    public List<Budget.Budget> Budgets { get; set; } = new();
    // public List<Receipt> Receipts { get; set; } = new();

}