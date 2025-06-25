using System.ComponentModel.DataAnnotations;

namespace FinHelper.Models.User;

public class EditProfileDto
{
    [Required]
    public string FullName { get; set; }

    [Required]
    [DataType(DataType.Date)]
    [BirthDateValidation(ErrorMessage = "Birthday cannot be in the future.")]
    public DateTime BirthDate { get; set; }
    
    [Range(0, double.MaxValue, ErrorMessage = "Salary must be non-negative")]
    public decimal Salary { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Cushion must be non-negative")]
    public decimal Cushion { get; set; }

    [StringLength(200, ErrorMessage = "Financial goal too long (max 200 chars)")]
    public string FinancialGoal { get; set; }

    [StringLength(100, ErrorMessage = "Strategy too long (max 100 chars)")]
    public string FinancialStrategy { get; set; }
}

