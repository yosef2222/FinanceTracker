namespace FinHelper.Models.User;


public class Loan
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public User User { get; set; } 
    
    public decimal Amount { get; set; }
    public int TermMonths { get; set; }
    public decimal MonthlyPayment { get; set; }
    public decimal InterestRate { get; set; }
    public string Type { get; set; }
    public DateTime StartDate { get; set; }
    public bool IsActive { get; set; } = true;
}