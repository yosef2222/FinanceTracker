using System.ComponentModel.DataAnnotations;

namespace FinHelper.Models.Category;

public class Category
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required, MaxLength(50)]
    public string Name { get; set; }
    
    [Required, MaxLength(7)]
    public string Color { get; set; } = "#4CAF50";
    
    [MaxLength(100)]
    public string Icon { get; set; } = "shopping-cart";
    public List<Transaction.Transaction> Transactions { get; set; } = new();
    public List<Budget.Budget> Budgets { get; set; } = new();
}