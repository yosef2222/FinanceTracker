using FinHelper.Data;
using Microsoft.EntityFrameworkCore;

namespace FinHelper.Services.Category;

public class CategoryService : ICategoryService
{
    private readonly ApplicationDbContext _context;
    private const string DefaultColor = "#4CAF50";
    private const string DefaultIcon = "shopping-cart";

    public CategoryService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Models.Category.Category>> GetAllCategoriesAsync()
    {
        return await _context.Categories.ToListAsync();
    }

    public async Task<Models.Category.Category> GetCategoryByIdAsync(Guid id)
    {
        return await _context.Categories.FindAsync(id);
    }

    public async Task<Models.Category.Category> CreateCategoryAsync(string name)
    {
        var category = new Models.Category.Category
        {
            Name = name,
            Color = DefaultColor,
            Icon = DefaultIcon
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync();
        return category;
    }

    public async Task<Models.Category.Category> UpdateCategoryAsync(Guid id, string name, string color, string icon)
    {
        var category = await _context.Categories.FindAsync(id);
        if (category == null) return null;

        category.Name = name;
        category.Color = color;
        category.Icon = icon;

        await _context.SaveChangesAsync();
        return category;
    }
}
