namespace FinHelper.Models.Budget;

public class BudgetDto
{
    public Guid? Id { get; set; }
    public decimal Amount { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public Guid CategoryId { get; set; }
}