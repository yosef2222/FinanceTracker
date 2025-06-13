using System.ComponentModel.DataAnnotations;

namespace FinHelper.Models.Transaction;

public class TransactionDto
{
    public Guid? Id { get; set; }
    
    [Required, Range(0.01, double.MaxValue)]
    public decimal Amount { get; set; }
    
    [Required]
    public DateTime Date { get; set; }
    
    [MaxLength(100)]
    public string Merchant { get; set; }
    
    [MaxLength(200)]
    public string Description { get; set; }
    
    [Required]
    public Guid CategoryId { get; set; }
}