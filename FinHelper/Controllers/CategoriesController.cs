using System.ComponentModel.DataAnnotations;
using FinHelper.Models.Category;
using FinHelper.Services.Category;
using Microsoft.AspNetCore.Mvc;

namespace FinHelper.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly ICategoryService _categoryService;

        public CategoriesController(ICategoryService categoryService)
        {
            _categoryService = categoryService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Category>>> GetCategories()
        {
            return Ok(await _categoryService.GetAllCategoriesAsync());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Category>> GetCategory(Guid id)
        {
            var category = await _categoryService.GetCategoryByIdAsync(id);

            if (category == null)
            {
                return NotFound();
            }

            return category;
        }

        [HttpPost]
        public async Task<ActionResult<Category>> CreateCategory([FromBody] CategoryCreateDto categoryDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var category = await _categoryService.CreateCategoryAsync(categoryDto.Name);
                return CreatedAtAction(nameof(GetCategory), new { id = category.Id }, category);
            }
            catch (ValidationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCategory(Guid id, [FromBody] CategoryUpdateDto categoryDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var category = await _categoryService.UpdateCategoryAsync(
                id, 
                categoryDto.Name,
                categoryDto.Color,
                categoryDto.Icon);

            if (category == null)
            {
                return NotFound();
            }

            return NoContent();
        }
    }

    public class CategoryCreateDto
    {
        [Required(ErrorMessage = "Category name is required")]
        [MaxLength(50, ErrorMessage = "Category name cannot exceed 50 characters")]
        public string Name { get; set; }
    }

    public class CategoryUpdateDto
    {
        [Required(ErrorMessage = "Category name is required")]
        [MaxLength(50, ErrorMessage = "Category name cannot exceed 50 characters")]
        public string Name { get; set; }

        [Required(ErrorMessage = "Color is required")]
        [MaxLength(7, ErrorMessage = "Color must be in #RRGGBB format")]
        [RegularExpression("^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$", ErrorMessage = "Invalid color format")]
        public string Color { get; set; }

        [Required(ErrorMessage = "Icon is required")]
        [MaxLength(100, ErrorMessage = "Icon name cannot exceed 100 characters")]
        public string Icon { get; set; }
    }