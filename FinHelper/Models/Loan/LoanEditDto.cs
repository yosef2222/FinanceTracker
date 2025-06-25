using System.ComponentModel.DataAnnotations;

namespace FinHelper.Models.User;

public class LoanEditDto
{
    [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be positive")]
    public decimal Amount { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Term must be at least 1 month")]
    public int TermMonths { get; set; }

    [Range(0, 100, ErrorMessage = "Interest rate must be between 0 and 100")]
    public decimal InterestRate { get; set; }

    [Required]
    [StringLength(50, ErrorMessage = "Type too long (max 50 chars)")]
    public string Type { get; set; }

    [DataType(DataType.Date)]
    public DateTime StartDate { get; set; } = DateTime.Today;
}