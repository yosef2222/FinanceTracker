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
    public List<Loan> Loans { get; set; } = new();
    
    public decimal Salary { get; set; } = 0;
    public decimal Cushion { get; set; } = 0;
    public string FinancialGoal { get; set; } = string.Empty;
    public string FinancialStrategy { get; set; } = string.Empty;
}