using FinHelper.Models.Category;

namespace FinHelper.Models.Dashboard;

public class CategorySpendingDto
{
    public CategoryDto Category { get; set; }
    public decimal Spent { get; set; }
    public decimal Budget { get; set; }
}