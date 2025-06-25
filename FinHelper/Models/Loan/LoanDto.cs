using System;
using System.ComponentModel.DataAnnotations;

namespace FinHelper.Models.User;

public class LoanDto
{
    [Required]
    [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be positive")]
    public decimal Amount { get; set; }

    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "Term must be at least 1 month")]
    public int TermMonths { get; set; }

    [Required]
    [Range(0.01, double.MaxValue, ErrorMessage = "Payment must be positive")]
    public decimal MonthlyPayment { get; set; }

    [Required]
    [StringLength(50, ErrorMessage = "Type too long (max 50 chars)")]
    public string Type { get; set; }

    public DateTime StartDate { get; set; } = DateTime.Today;
    
    public bool IsActive { get; set; } = true;
}