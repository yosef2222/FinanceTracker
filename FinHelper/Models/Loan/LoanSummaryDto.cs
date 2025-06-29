namespace FinHelper.Models.User;

public class LoanSummaryDto
{
    public Guid LoanId { get; set; }
    public string LoanType { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public decimal RemainingAmount { get; set; }
    public int RemainingMonths { get; set; }
    public decimal MonthlyPayment { get; set; }
    public decimal InterestRate { get; set; }
}