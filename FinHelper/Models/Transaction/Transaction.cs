using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using FinHelper.Models;

namespace FinHelper.Models.Transaction;

public class Transaction
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required, Range(0.01, double.MaxValue)]
    public decimal Amount { get; set; }
    
    [Required]
    public DateTime Date { get; set; } = DateTime.UtcNow;
    
    [MaxLength(100)]
    public string Merchant { get; set; }
    
    [MaxLength(200)]
    public string Description { get; set; }
    
    [Required]
    public Guid UserId { get; set; }
    
    [Required]
    public Guid CategoryId { get; set; }
    
    [ForeignKey("UserId")]
    public User.User User { get; set; }
    
    [ForeignKey("CategoryId")]
    public Category.Category Category { get; set; }
}