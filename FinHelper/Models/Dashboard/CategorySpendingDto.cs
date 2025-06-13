using FinHelper.Models.Category;

namespace FinHelper.Models.Dashboard;

public class CategorySpendingDto
{
    public CategoryDto Category { get; set; }
    public decimal Spent { get; set; }
    public decimal Budget { get; set; }
    public decimal Percentage => Budget > 0 ? (Spent / Budget) * 100 : 0;
}