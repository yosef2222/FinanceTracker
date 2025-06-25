namespace FinHelper.Models.User;

public class LoanDto
{
    public decimal Amount { get; set; }
    public int TermMonths { get; set; }
    public decimal MonthlyPayment { get; set; }
    public string Type { get; set; }
    public DateTime StartDate { get; set; }
    public bool IsActive { get; set; }
}