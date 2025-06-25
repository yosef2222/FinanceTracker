namespace FinHelper.Services.Category;

public interface ICategoryService
{
    Task<IEnumerable<Models.Category.Category>> GetAllCategoriesAsync();
    Task<Models.Category.Category> GetCategoryByIdAsync(Guid id);
    Task<Models.Category.Category> CreateCategoryAsync(string name);
    Task<Models.Category.Category> UpdateCategoryAsync(Guid id, string name, string color, string icon);

}