namespace FinHelper.Models.Budget;

public class Budget
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public decimal Amount { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public Guid UserId { get; set; }
    public Guid CategoryId { get; set; }
    public User.User User { get; set; }
    public Category.Category Category { get; set; }
}